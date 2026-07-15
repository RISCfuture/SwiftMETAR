import Foundation
import NumberKit
import RegexBuilder

final class VisibilityParser: WarmableParser, @unchecked Sendable {
  private static let integerRx = LockedRegex(
    Regex {
      Anchor.startOfSubject
      IntegerDistanceParser.rx
      Anchor.endOfSubject
    }
  )

  private static let notRecordedRx = LockedRegex(
    Regex {
      Anchor.startOfSubject
      Repeat("/", 2...)
      ChoiceOf {
        "SM"
        "FT"
        "M"
      }
      Anchor.endOfSubject
    }
  )

  private let integerParser = IntegerDistanceParser()
  private let fractionParser = FractionalDistanceParser()
  // `FractionalDistanceParser.rx` embeds the shared, non-`Sendable` `FractionParser`, so it (and
  // this anchored wrapper) stays instance `lazy var` storage; the other regexes are hoisted to
  // `static let`.
  private lazy var fractionRx = LockedRegex(
    Regex {
      Anchor.startOfSubject
      fractionParser.rx
      Anchor.endOfSubject
    }
  )

  func warmUp() {
    _ = try? fractionRx.wholeMatch(in: "")
  }

  func parse(_ parts: inout [String.SubSequence]) throws -> Visibility? {
    guard !parts.isEmpty else { return nil }

    if parts.count >= 2 {
      if let visibility = try parse("\(parts[0]) \(parts[1])") {
        parts.removeFirst(2)
        return visibility
      }
    }

    if let visibility = try parse(String(parts[0])) {
      parts.removeFirst()
      return visibility
    }

    return nil
  }

  private func parse(_ vizStr: String) throws -> Visibility? {
    if vizStr == "CAVOK" {
      return .greaterThan(.meters(9999))
    }
    if vizStr == "10SM" {
      return .greaterThan(.statuteMiles(10))
    }
    if vizStr == "9999" {
      return .greaterThan(.meters(9999))
    }

    if try Self.notRecordedRx.wholeMatch(in: vizStr) != nil {
      return .notRecorded
    }

    if let match = try fractionRx.wholeMatch(in: vizStr) {
      return fractionParser.parse(match)
    }

    if let match = try Self.integerRx.wholeMatch(in: vizStr) {
      return integerParser.parse(match)
    }

    return nil
  }

  enum OpenRange: String, RegexCases {
    case greaterThan = "P"
    case lessThan = "M"
    case equal = ""
  }

  class OpenRangeParser {
    private static let boundRef = Reference<OpenRange>()

    // swiftlint:disable force_try
    static let rx = Regex {
      Capture(as: boundRef) {
        try! OpenRange.rx
      } transform: {
        .init(rawValue: String($0))!
      }
    }
    // swiftlint:enable force_try

    func parse<T>(_ match: Regex<T>.Match) -> OpenRange {
      match[Self.boundRef]
    }
  }

  enum VisibilityDistanceUnit: String, RegexCases {
    case statuteMiles = "SM"
    case feet = "FT"
    case meters = "M"

    static func from(raw: String) -> Self? {
      if raw.isEmpty { return .meters }
      return .init(rawValue: raw)
    }
  }

  class IntegerDistanceParser {
    private static let valueRef = Reference<UInt16>()
    private static let unitRef = Reference<VisibilityDistanceUnit>()

    // swiftlint:disable force_try
    static let rx = Regex {
      OpenRangeParser.rx
      Capture(as: valueRef) {
        Repeat(.digit, 1...4)
      } transform: {
        .init($0)!
      }
      Capture(as: unitRef) {
        try! Optionally(VisibilityDistanceUnit.rx)
      } transform: {
        .from(raw: String($0))!
      }
    }
    // swiftlint:enable force_try

    private let openRangeParser = OpenRangeParser()

    func parse<T>(_ match: Regex<T>.Match) -> Visibility {
      let distance: Visibility.Value =
        switch match[Self.unitRef] {
          case .feet: .feet(match[Self.valueRef])
          case .meters: .meters(match[Self.valueRef])
          case .statuteMiles: .statuteMiles(Ratio(Int(match[Self.valueRef])))
        }

      switch openRangeParser.parse(match) {
        case .greaterThan: return .greaterThan(distance)
        case .lessThan: return .lessThan(distance)
        case .equal: return .equal(distance)
      }
    }
  }

  class FractionalDistanceParser {
    private let openRangeParser = OpenRangeParser()
    private let fractionParser = FractionParser()

    lazy var rx = Regex {
      OpenRangeParser.rx
      fractionParser.rx
      "SM"
    }

    func parse<T>(_ match: Regex<T>.Match) -> Visibility {
      let value = fractionParser.parse(match)
      let distance = Visibility.Value.statuteMiles(value)

      switch openRangeParser.parse(match) {
        case .greaterThan: return .greaterThan(distance)
        case .lessThan: return .lessThan(distance)
        case .equal: return .equal(distance)
      }
    }
  }
}
