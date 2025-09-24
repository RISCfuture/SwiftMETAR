import Foundation
@preconcurrency import RegexBuilder

class PeriodParser {
  func parse(_ parts: inout [String.SubSequence], referenceDate: Date? = nil) throws -> TAF.Group
    .Period?
  {
    let parsers: [PeriodParser.Type] = [
      FromPeriodParser.self,
      TemporaryPeriodParser.self,
      BecomingPeriodParser.self,
      ProbabilityPeriodParser.self,
      RangePeriodParser.self
    ]

    for parser in parsers {
      if let period = try parser.init().parse(&parts, referenceDate: referenceDate ?? Date()) {
        return period
      }
    }

    return nil
  }

  private protocol PeriodParser {
    init()
    func parse(_ parts: inout [String.SubSequence], referenceDate: Date) throws -> TAF.Group.Period?
  }

  private final class FromPeriodParser: PeriodParser {
    private let dateParser = DayHourMinuteParser()
    private lazy var rx = Regex {
      Anchor.startOfSubject
      "FM"
      dateParser.rx
      Anchor.endOfSubject
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

  private final class RangePeriodParser: PeriodParser {
    private let periodStart = DayHourParser()
    private let periodEnd = DayHourParser()

    private lazy var rx = Regex {
      Anchor.startOfSubject
      periodStart.rx
      "/"
      periodEnd.rx
      Anchor.endOfSubject
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

  private final class TemporaryPeriodParser: PeriodParser {
    func parse(_ parts: inout [String.SubSequence], referenceDate: Date) throws -> TAF.Group.Period?
    {
      guard !parts.isEmpty else { return nil }
      guard parts[0] == "TEMPO" else { return nil }
      parts.removeFirst()

      guard let period = try RangePeriodParser().parseRange(&parts, referenceDate: referenceDate)
      else {
        throw Error.invalidPeriod(String(parts[0]))
      }
      return .temporary(period)
    }
  }

  private final class BecomingPeriodParser: PeriodParser {
    func parse(_ parts: inout [String.SubSequence], referenceDate: Date) throws -> TAF.Group.Period?
    {
      guard !parts.isEmpty else { return nil }
      guard parts[0] == "BECMG" else { return nil }
      parts.removeFirst()

      guard let period = try RangePeriodParser().parseRange(&parts, referenceDate: referenceDate)
      else {
        throw Error.invalidPeriod(String(parts[0]))
      }
      return .becoming(period)
    }
  }

  private final class ProbabilityPeriodParser: PeriodParser {
    private let probabilityRef = Reference<UInt8>()
    private lazy var rx = Regex {
      Anchor.startOfSubject
      "PROB"
      Capture(as: probabilityRef) {
        Repeat(.digit, count: 2)
      } transform: {
        .init($0)!
      }
      Anchor.endOfSubject
    }

    func parse(_ parts: inout [String.SubSequence], referenceDate: Date) throws -> TAF.Group.Period?
    {
      guard !parts.isEmpty else { return nil }

      let probStr = String(parts[0])
      guard let match = try rx.wholeMatch(in: probStr) else { return nil }
      parts.removeFirst()

      let probability = match[probabilityRef]
      guard let period = try RangePeriodParser().parseRange(&parts, referenceDate: referenceDate)
      else {
        throw Error.invalidPeriod(String(parts[0]))
      }

      return .probability(probability, period: period)
    }
  }
}
