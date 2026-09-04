import Foundation
import RegexBuilder

final class PeriodParser: WarmableParser, @unchecked Sendable {
  private let fromParser = FromPeriodParser()
  private let rangeParser = RangePeriodParser()
  private lazy var temporaryParser = TemporaryPeriodParser(rangeParser: rangeParser)
  private lazy var becomingParser = BecomingPeriodParser(rangeParser: rangeParser)
  private lazy var probabilityParser = ProbabilityPeriodParser(rangeParser: rangeParser)

  // `rangeParser` comes last: it matches a bare period range, which several of the other
  // subparsers consume after their own prefix, so they must get first refusal.
  private lazy var subparsers: [any Subparser] = [
    fromParser, temporaryParser, becomingParser, probabilityParser, rangeParser
  ]

  func warmUp() {
    for subparser in subparsers { subparser.warmUp() }
  }

  func parse(_ parts: inout [String.SubSequence], referenceDate: Date? = nil) throws -> TAF.Group
    .Period?
  {
    for subparser in subparsers {
      if let period = try subparser.parse(&parts, referenceDate: referenceDate ?? Date()) {
        return period
      }
    }

    return nil
  }

  private protocol Subparser: AnyObject {
    func warmUp()
    func parse(_ parts: inout [String.SubSequence], referenceDate: Date) throws -> TAF.Group.Period?
  }

  private final class FromPeriodParser: Subparser {
    private let dateParser = DayHourMinuteParser()
    private lazy var rx = LockedRegex(
      Regex {
        Anchor.startOfSubject
        "FM"
        dateParser.rx
        Anchor.endOfSubject
      }
    )

    func warmUp() {
      _ = try? rx.wholeMatch(in: "")
    }

    func parse(_ parts: inout [String.SubSequence], referenceDate: Date) throws -> TAF.Group.Period?
    {
      guard !parts.isEmpty else { return nil }

      let periodStr = String(parts[0])
      guard let match = try rx.wholeMatch(in: periodStr) else { return nil }
      parts.removeFirst()

      let date = try dateParser.parse(
        match: match,
        referenceDate: referenceDate,
        originalString: periodStr
      )
      return .from(date)
    }
  }

  private final class RangePeriodParser: Subparser {
    private let periodStart = DayHourParser()
    private let periodEnd = DayHourParser()

    private lazy var rx = LockedRegex(
      Regex {
        Anchor.startOfSubject
        periodStart.rx
        "/"
        periodEnd.rx
        Anchor.endOfSubject
      }
    )

    func warmUp() {
      _ = try? rx.wholeMatch(in: "")
    }

    func parse(_ parts: inout [String.SubSequence], referenceDate: Date) throws -> TAF.Group.Period?
    {
      guard let period = try parseRange(&parts, referenceDate: referenceDate) else {
        return nil
      }
      return .range(period)
    }

    func parseRange(_ parts: inout [String.SubSequence], referenceDate: Date) throws
      -> DateComponentsInterval?
    {
      guard !parts.isEmpty else { return nil }
      let periodStr = String(parts[0])
      guard let match = try rx.wholeMatch(in: periodStr) else { return nil }
      parts.removeFirst()

      let start = try periodStart.parse(
        match: match,
        referenceDate: referenceDate,
        originalString: periodStr
      )
      let end = try periodEnd.parse(
        match: match,
        referenceDate: referenceDate,
        afterDate: start,
        originalString: periodStr
      )

      guard let startDate = start.date,
        let endDate = end.date,
        endDate >= startDate
      else {
        throw Error.invalidPeriod(periodStr)
      }

      return .init(start: start, end: end)
    }
  }

  private final class TemporaryPeriodParser: Subparser {
    private let rangeParser: RangePeriodParser

    init(rangeParser: RangePeriodParser) {
      self.rangeParser = rangeParser
    }

    func warmUp() {}

    func parse(_ parts: inout [String.SubSequence], referenceDate: Date) throws -> TAF.Group.Period?
    {
      guard !parts.isEmpty else { return nil }
      guard parts[0] == "TEMPO" else { return nil }
      parts.removeFirst()

      guard let period = try rangeParser.parseRange(&parts, referenceDate: referenceDate)
      else {
        throw Error.invalidPeriod(String(parts[0]))
      }
      return .temporary(period)
    }
  }

  private final class BecomingPeriodParser: Subparser {
    private let rangeParser: RangePeriodParser

    init(rangeParser: RangePeriodParser) {
      self.rangeParser = rangeParser
    }

    func warmUp() {}

    func parse(_ parts: inout [String.SubSequence], referenceDate: Date) throws -> TAF.Group.Period?
    {
      guard !parts.isEmpty else { return nil }
      guard parts[0] == "BECMG" else { return nil }
      parts.removeFirst()

      guard let period = try rangeParser.parseRange(&parts, referenceDate: referenceDate)
      else {
        throw Error.invalidPeriod(String(parts[0]))
      }
      return .becoming(period)
    }
  }

  private final class ProbabilityPeriodParser: Subparser {
    private let rangeParser: RangePeriodParser
    private let probabilityRef = Reference<UInt8>()
    private lazy var rx = LockedRegex(
      Regex {
        Anchor.startOfSubject
        "PROB"
        Capture(as: probabilityRef) {
          Repeat(.digit, count: 2)
        } transform: {
          .init($0)!
        }
        Anchor.endOfSubject
      }
    )

    init(rangeParser: RangePeriodParser) {
      self.rangeParser = rangeParser
    }

    func warmUp() {
      _ = try? rx.wholeMatch(in: "")
    }

    func parse(_ parts: inout [String.SubSequence], referenceDate: Date) throws -> TAF.Group.Period?
    {
      guard !parts.isEmpty else { return nil }

      let probStr = String(parts[0])
      guard let match = try rx.wholeMatch(in: probStr) else { return nil }
      parts.removeFirst()

      let probability = match[probabilityRef]
      guard let period = try rangeParser.parseRange(&parts, referenceDate: referenceDate)
      else {
        throw Error.invalidPeriod(String(parts[0]))
      }

      return .probability(probability, period: period)
    }
  }
}
