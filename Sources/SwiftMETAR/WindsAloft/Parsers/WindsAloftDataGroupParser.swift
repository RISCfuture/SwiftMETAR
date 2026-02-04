import Foundation
@preconcurrency import RegexBuilder

class WindsAloftDataGroupParser {

  // MARK: - Regex references

  private let ddRef = Reference<UInt16>()
  private let ffRef = Reference<UInt16>()
  private let signedTempRef = Reference<Int8>()
  private let unsignedTempRef = Reference<UInt8>()

  // MARK: - Signed format: "3209+02", "3209-02"

  private lazy var signedRx = Regex {
    Anchor.startOfSubject
    Capture(as: ddRef) {
      Repeat(.digit, count: 2)
    } transform: {
      UInt16($0)!
    }
    Capture(as: ffRef) {
      Repeat(.digit, count: 2)
    } transform: {
      UInt16($0)!
    }
    Capture(as: signedTempRef) {
      ChoiceOf {
        "+"; "-"
      }
      OneOrMore(.digit)
    } transform: {
      Int8($0)!
    }
    Anchor.endOfSubject
  }

  // MARK: - 4-digit format: "3214"

  private lazy var fourDigitRx = Regex {
    Anchor.startOfSubject
    Capture(as: ddRef) {
      Repeat(.digit, count: 2)
    } transform: {
      UInt16($0)!
    }
    Capture(as: ffRef) {
      Repeat(.digit, count: 2)
    } transform: {
      UInt16($0)!
    }
    Anchor.endOfSubject
  }

  // MARK: - 6-digit unsigned format: "295947"

  private lazy var sixDigitRx = Regex {
    Anchor.startOfSubject
    Capture(as: ddRef) {
      Repeat(.digit, count: 2)
    } transform: {
      UInt16($0)!
    }
    Capture(as: ffRef) {
      Repeat(.digit, count: 2)
    } transform: {
      UInt16($0)!
    }
    Capture(as: unsignedTempRef) {
      Repeat(.digit, count: 2)
    } transform: {
      UInt8($0)!
    }
    Anchor.endOfSubject
  }

  /// Decodes a single winds aloft data group string into a
  /// ``WindsAloftEntry``, or `nil` if the group is blank (missing data).
  ///
  /// Encoding rules:
  /// - Empty/whitespace: missing data → `nil`
  /// - `9900`: light and variable
  /// - 4 digits (`DDff`): direction and speed, no temperature
  /// - 6 or 7 characters with explicit sign (`DDff±TT`): direction, speed,
  ///   signed temperature
  /// - 6 digits unsigned (`DDffTT`): above 24,000 ft, temperature always
  ///   negative
  /// - DD ≥ 51 (and not 99): high-wind encoding, direction = (DD−50)×10,
  ///   speed = ff+100
  func parse(_ group: String) throws -> WindsAloftEntry? {
    let trimmed = group.trimmingCharacters(in: .whitespaces)
    guard !trimmed.isEmpty else { return nil }

    // Light and variable
    if trimmed == "9900" || trimmed == "990000" {
      return .lightAndVariable
    }

    if let match = try signedRx.wholeMatch(in: trimmed) {
      let (direction, speed) = decodeDirectionSpeed(dd: match[ddRef], ff: match[ffRef])
      return .wind(direction: direction, speed: .knots(speed), temperature: match[signedTempRef])
    }

    if let match = try sixDigitRx.wholeMatch(in: trimmed) {
      let (direction, speed) = decodeDirectionSpeed(dd: match[ddRef], ff: match[ffRef])
      return .wind(
        direction: direction,
        speed: .knots(speed),
        temperature: -Int8(match[unsignedTempRef])
      )
    }

    if let match = try fourDigitRx.wholeMatch(in: trimmed) {
      let (direction, speed) = decodeDirectionSpeed(dd: match[ddRef], ff: match[ffRef])
      return .wind(direction: direction, speed: .knots(speed), temperature: nil)
    }

    throw Error.invalidWindsAloftGroup(group)
  }

  /// Decodes the DD and ff components, handling the high-wind encoding
  /// where DD ≥ 51 means direction = (DD−50)×10, speed = ff+100.
  private func decodeDirectionSpeed(dd: UInt16, ff: UInt16) -> (
    direction: UInt16, speed: UInt16
  ) {
    if dd >= 51 && dd <= 86 {
      return (direction: (dd - 50) * 10, speed: ff + 100)
    }
    return (direction: dd * 10, speed: ff)
  }
}
