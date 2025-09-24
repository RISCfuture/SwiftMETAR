import Foundation
import NumberKit
@preconcurrency import RegexBuilder

class VisibilityParser {
  private let integerParser = IntegerDistanceParser()
  private let fractionParser = FractionalDistanceParser()
  private let visibilityRef = Reference<Substring>()

  private lazy var integerRx = Regex {
    Anchor.startOfSubject
    integerParser.rx
    Anchor.endOfSubject
  }
  private lazy var fractionRx = Regex {
    Anchor.startOfSubject
    fractionParser.rx
    Anchor.endOfSubject
  }

  private lazy var notRecordedRx = Regex {
    Anchor.startOfSubject
    Repeat("/", 2...)
    ChoiceOf {
      "SM"
      "FT"
      "M"
    }
    Anchor.endOfSubject
  }

  lazy var rx = Regex {
    Capture(as: visibilityRef) {
      ChoiceOf {
        ChoiceOf {
          "10SM"
          "9999"
        }
        notRecordedRx
        fractionRx
        integerRx
      }
    }
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

  func parse<T>(_ match: Regex<T>.Match) throws -> Visibility? {
    let visStr = match[visibilityRef]
    guard let visibility = try parse(String(visStr)) else {
      preconditionFailure("Visibility rx should have captured parseable substring")
    }
    return visibility
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

    if try notRecordedRx.wholeMatch(in: vizStr) != nil {
      return .notRecorded
    }

    if let match = try fractionRx.wholeMatch(in: vizStr) {
      return fractionParser.parse(match)
    }

    if let match = try integerRx.wholeMatch(in: vizStr) {
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
    private let boundRef = Reference<OpenRange>()

    // swiftlint:disable force_try
    lazy var rx = Regex {
      Capture(as: boundRef) {
        try! OpenRange.rx
      } transform: {
        .init(rawValue: String($0))!
      }
    }
    // swiftlint:enable force_try

    func parse<T>(_ match: Regex<T>.Match) -> OpenRange {
      match[boundRef]
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
    private let openRangeParser = OpenRangeParser()

    private let valueRef = Reference<UInt16>()
    private let unitRef = Reference<VisibilityDistanceUnit>()

    // swiftlint:disable force_try
    lazy var rx = Regex {
      openRangeParser.rx
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

    func parse<T>(_ match: Regex<T>.Match) -> Visibility {
      let distance: Visibility.Value =
        switch match[unitRef] {
          case .feet: .feet(match[valueRef])
          case .meters: .meters(match[valueRef])
          case .statuteMiles: .statuteMiles(Ratio(Int(match[valueRef])))
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
      openRangeParser.rx
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
