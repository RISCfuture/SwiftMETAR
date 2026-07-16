import Foundation
import RegexBuilder

final class WindsAloftDataGroupParser: WarmableParser, @unchecked Sendable {

  // MARK: - Regex references

  private static let ddRef = Reference<UInt16>()
  private static let ffRef = Reference<UInt16>()
  private static let signedTempRef = Reference<Int8>()
  private static let unsignedTempRef = Reference<UInt8>()

  // MARK: - Signed format: "3209+02", "3209-02"

  private static let signedRx = LockedRegex(
    Regex {
      Anchor.startOfSubject
      Capture(as: WindsAloftDataGroupParser.ddRef) {
        Repeat(.digit, count: 2)
      } transform: {
        UInt16($0)!
      }
      Capture(as: WindsAloftDataGroupParser.ffRef) {
        Repeat(.digit, count: 2)
      } transform: {
        UInt16($0)!
      }
      Capture(as: WindsAloftDataGroupParser.signedTempRef) {
        ChoiceOf {
          "+"; "-"
        }
        OneOrMore(.digit)
      } transform: {
        Int8($0)!
      }
      Anchor.endOfSubject
    }
  )

  // MARK: - 4-digit format: "3214"

  private static let fourDigitRx = LockedRegex(
    Regex {
      Anchor.startOfSubject
      Capture(as: WindsAloftDataGroupParser.ddRef) {
        Repeat(.digit, count: 2)
      } transform: {
        UInt16($0)!
      }
      Capture(as: WindsAloftDataGroupParser.ffRef) {
        Repeat(.digit, count: 2)
      } transform: {
        UInt16($0)!
      }
      Anchor.endOfSubject
    }
  )

  // MARK: - 6-digit unsigned format: "295947"

  private static let sixDigitRx = LockedRegex(
    Regex {
      Anchor.startOfSubject
      Capture(as: WindsAloftDataGroupParser.ddRef) {
        Repeat(.digit, count: 2)
      } transform: {
        UInt16($0)!
      }
      Capture(as: WindsAloftDataGroupParser.ffRef) {
        Repeat(.digit, count: 2)
      } transform: {
        UInt16($0)!
      }
      Capture(as: WindsAloftDataGroupParser.unsignedTempRef) {
        Repeat(.digit, count: 2)
      } transform: {
        UInt8($0)!
      }
      Anchor.endOfSubject
    }
  )

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
  /// - DD 51–86: high-wind encoding, direction = (DD−50)×10,
  ///   speed = ff+100
  func parse(_ group: String) throws -> WindsAloftEntry? {
    let trimmed = group.trimmingCharacters(in: .whitespaces)
    guard !trimmed.isEmpty else { return nil }

    // Light and variable
    if trimmed == "9900" || trimmed == "990000" {
      return .lightAndVariable
    }

    if let match = try Self.signedRx.wholeMatch(in: trimmed) {
      let (direction, speed) = decodeDirectionSpeed(
        dd: match[Self.ddRef],
        ff: match[Self.ffRef]
      )
      return .wind(
        direction: direction,
        speed: .knots(speed),
        temperature: match[Self.signedTempRef]
      )
    }

    if let match = try Self.sixDigitRx.wholeMatch(in: trimmed) {
      let (direction, speed) = decodeDirectionSpeed(
        dd: match[Self.ddRef],
        ff: match[Self.ffRef]
      )
      return .wind(
        direction: direction,
        speed: .knots(speed),
        temperature: -Int8(match[Self.unsignedTempRef])
      )
    }

    if let match = try Self.fourDigitRx.wholeMatch(in: trimmed) {
      let (direction, speed) = decodeDirectionSpeed(
        dd: match[Self.ddRef],
        ff: match[Self.ffRef]
      )
      return .wind(direction: direction, speed: .knots(speed), temperature: nil)
    }

    throw Error.invalidWindsAloftGroup(group)
  }

  /// Decodes the DD and ff components, handling the high-wind encoding
  /// where DD 51–86 means direction = (DD−50)×10, speed = ff+100.
  private func decodeDirectionSpeed(dd: UInt16, ff: UInt16) -> (
    direction: UInt16, speed: UInt16
  ) {
    if dd >= 51 && dd <= 86 {
      return (direction: (dd - 50) * 10, speed: ff + 100)
    }
    return (direction: dd * 10, speed: ff)
  }
}
