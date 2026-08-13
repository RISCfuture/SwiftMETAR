import Foundation
import RegexBuilder

final class WindsAloftDataGroupParser: WarmableParser, @unchecked Sendable {

  // MARK: - Regex references

  /// The direction figure that, paired with a zero speed figure, marks a group
  /// as light and variable.
  private static let lightAndVariableDirection: UInt16 = 99

  /// The highest direction figure that encodes a plain direction; figures above
  /// this are either the high-wind encoding or invalid.
  private static let maximumDirectionFigure: UInt16 = 36

  /// Direction figures in this range carry a wind of 100 knots or more.
  private static let highWindDirections: ClosedRange<UInt16> = 51...86

  private static let highWindDirectionOffset: UInt16 = 50
  private static let highWindSpeedOffset: UInt16 = 100
  private static let degreesPerDirectionFigure: UInt16 = 10

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
  /// - 4 digits (`DDff`): direction and speed, no temperature
  /// - 6 or 7 characters with explicit sign (`DDff±TT`): direction, speed,
  ///   signed temperature
  /// - 6 digits unsigned (`DDffTT`): above 24,000 ft, temperature always
  ///   negative
  /// - DD 51–86: high-wind encoding, direction = (DD−50)×10,
  ///   speed = ff+100
  /// - `9900`: light and variable, carrying the temperature of whichever form
  ///   it appears in (`9900`, `9900±TT`, or `9900TT`)
  func parse(_ group: String) throws -> WindsAloftEntry? {
    let trimmed = group.trimmingCharacters(in: .whitespaces)
    guard !trimmed.isEmpty else { return nil }
    guard let components = try components(of: trimmed) else {
      throw Error.invalidWindsAloftGroup(group)
    }

    if components.isLightAndVariable {
      return .lightAndVariable(temperature: components.temperature)
    }
    guard let (direction, speed) = decodeDirectionSpeed(components) else {
      throw Error.invalidWindsAloftGroup(group)
    }
    return .wind(
      direction: direction,
      speed: .knots(speed),
      temperature: components.temperature
    )
  }

  /// Matches `group` against each supported data group format, or returns `nil`
  /// if it matches none of them.
  private func components(of group: String) throws -> Components? {
    if let match = try Self.signedRx.wholeMatch(in: group) {
      return .init(match: match, temperature: match[Self.signedTempRef])
    }
    if let match = try Self.sixDigitRx.wholeMatch(in: group) {
      return .init(match: match, temperature: -Int8(match[Self.unsignedTempRef]))
    }
    if let match = try Self.fourDigitRx.wholeMatch(in: group) {
      return .init(match: match, temperature: nil)
    }
    return nil
  }

  /// Decodes the DD and ff figures, handling the high-wind encoding where
  /// DD 51–86 means direction = (DD−50)×10, speed = ff+100. Returns `nil` for
  /// direction figures that encode no possible direction.
  private func decodeDirectionSpeed(_ components: Components) -> (
    direction: UInt16, speed: UInt16
  )? {
    let (dd, ff) = (components.dd, components.ff)
    if Self.highWindDirections.contains(dd) {
      return (
        direction: (dd - Self.highWindDirectionOffset) * Self.degreesPerDirectionFigure,
        speed: ff + Self.highWindSpeedOffset
      )
    }
    guard dd <= Self.maximumDirectionFigure else { return nil }
    return (direction: dd * Self.degreesPerDirectionFigure, speed: ff)
  }

  /// The direction, speed, and temperature figures common to every data group
  /// format, before they are interpreted.
  private struct Components {
    let dd: UInt16
    let ff: UInt16
    let temperature: Int8?

    var isLightAndVariable: Bool {
      dd == WindsAloftDataGroupParser.lightAndVariableDirection && ff == 0
    }

    init<Output>(match: Regex<Output>.Match, temperature: Int8?) {
      dd = match[WindsAloftDataGroupParser.ddRef]
      ff = match[WindsAloftDataGroupParser.ffRef]
      self.temperature = temperature
    }
  }
}
