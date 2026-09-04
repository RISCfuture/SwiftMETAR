public import Foundation

/// A report on the condition and strength of the winds.
public enum Wind: CodedRepresentable, Equatable, Sendable {

  /// No winds detected, or variable winds with speed under 3 knots.
  case calm

  /**
   Wind direction is variable.

   - Parameter speed: The average wind speed.
   - Parameter headingRange: The range of headings the wind is coming from.
   */
  case variable(speed: Speed, headingRange: (UInt16, UInt16)? = nil)

  /**
   Wind has a definite heading and speed.

   - Parameter heading: The direction the wind is coming from, referenced from
                        true north.
   - Parameter speed: The average wind speed.
   - Parameter gust: The highest wind speed, when wind speed varies
                     significantly.
   */
  case direction(_ heading: UInt16, speed: Speed, gust: Speed? = nil)

  /**
   Wind has a definite heading range and speed.

   - Parameter heading: The average direction the wind is coming from,
                        referenced from true north.
   - Parameter headingRange: The range of headings the wind is coming from.
   - Parameter speed: The average wind speed.
   - Parameter gust: The highest wind speed, when wind speed varies
                     significantly.
   */
  case directionRange(
    _ heading: UInt16,
    headingRange: (UInt16, UInt16),
    speed: Speed,
    gust: Speed? = nil
  )

  /**
   The coded representation of these winds, e.g. `"03015KT"`, `"03015G25KT"`,
   `"VRB02KT"`, or `"00000KT"` for calm. Direction ranges append the variable
   group as a second token, e.g. `"28025G37KT 250V310"`.
   */
  public var codedString: String {
    switch self {
      case .calm:
        return "00000KT"
      case let .variable(speed, headingRange):
        let base = "VRB\(speed.speedDigits)\(speed.unitCode)"
        guard let headingRange else { return base }
        return "\(base) \(Self.heading(headingRange.0))V\(Self.heading(headingRange.1))"
      case let .direction(heading, speed, gust):
        return "\(Self.heading(heading))\(Self.speedGroup(speed, gust: gust))\(speed.unitCode)"
      case let .directionRange(heading, headingRange, speed, gust):
        let base = "\(Self.heading(heading))\(Self.speedGroup(speed, gust: gust))\(speed.unitCode)"
        return "\(base) \(Self.heading(headingRange.0))V\(Self.heading(headingRange.1))"
    }
  }

  public init(coded: String) throws {
    var parts = coded.split(whereSeparator: \.isWhitespace)
    guard let wind = try WindParser.parse(&parts), parts.isEmpty else {
      throw Error.invalidWinds(coded)
    }
    self = wind
  }

  private static func heading(_ value: UInt16) -> String {
    String(format: "%03d", value)
  }

  private static func speedGroup(_ speed: Speed, gust: Speed?) -> String {
    guard let gust else { return speed.speedDigits }
    return "\(speed.speedDigits)G\(gust.speedDigits)"
  }

  public static func == (lhs: Self, rhs: Self) -> Bool {
    switch lhs {
      case .calm:
        if case .calm = rhs { return true }
        return false
      case let .variable(lhsSpeed, lhsRange):
        guard case let .variable(rhsSpeed, rhsRange) = rhs else { return false }
        if lhsRange == nil && rhsRange == nil { return true }
        return zipOptionals(lhsRange, rhsRange).map { $0 == $1 && lhsSpeed == rhsSpeed } ?? false
      case let .direction(lhsHeading, lhsSpeed, lhsGust):
        guard case let .direction(rhsHeading, rhsSpeed, rhsGust) = rhs else { return false }
        return lhsHeading == rhsHeading && lhsSpeed == rhsSpeed && lhsGust == rhsGust
      case let .directionRange(lhsHeading, lhsRange, lhsSpeed, lhsGust):
        guard case let .directionRange(rhsHeading, rhsRange, rhsSpeed, rhsGust) = rhs
        else { return false }
        return lhsHeading == rhsHeading && lhsRange == rhsRange && lhsSpeed == rhsSpeed
          && lhsGust == rhsGust
    }
  }

  /// A wind speed.
  public enum Speed: CodedRepresentable, Comparable, Sendable {

    /**
     A wind speed in knots.

     - Parameter quantity: The wind speed in knots.
     */
    case knots(_ quantity: UInt16)

    /**
     A wind speed in kilometers per hour.

     - Parameter quantity: The wind speed in KPH.
     */
    case kph(_ quantity: UInt16)

    /**
     A wind speed in meters per second.

     - Parameter quantity: The wind speed in m/s.
     */
    case mps(_ quantity: UInt16)

    /// The speed expressed as a `Measurement`, which is convertible to
    /// other units.
    public var measurement: Measurement<UnitSpeed> {
      switch self {
        case .knots(let quantity): .init(value: Double(quantity), unit: .knots)
        case .kph(let quantity): .init(value: Double(quantity), unit: .kilometersPerHour)
        case .mps(let quantity): .init(value: Double(quantity), unit: .metersPerSecond)
      }
    }

    /// The coded unit suffix for this speed, e.g. `"KT"`, `"KPH"`, or `"MPS"`.
    public var unitCode: String {
      switch self {
        case .knots: "KT"
        case .kph: "KPH"
        case .mps: "MPS"
      }
    }

    /// The quantity as coded digits, zero-padded to at least two places
    /// (e.g. `5` → `"05"`), without a unit suffix.
    public var speedDigits: String {
      let quantity =
        switch self {
          case .knots(let quantity), .kph(let quantity), .mps(let quantity): quantity
        }
      return String(format: "%02d", quantity)
    }

    /// The coded representation of this speed, e.g. `"15KT"`.
    public var codedString: String { "\(speedDigits)\(unitCode)" }

    public init(coded: String) throws {
      let units: [(suffix: String, make: (UInt16) -> Self)] = [
        ("KTS", Self.knots), ("KT", Self.knots), ("MPS", Self.mps), ("KPH", Self.kph)
      ]
      for (suffix, make) in units where coded.hasSuffix(suffix) {
        guard let quantity = UInt16(coded.dropLast(suffix.count)) else { break }
        self = make(quantity)
        return
      }
      throw Error.invalidWinds(coded)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
      return lhs.measurement == rhs.measurement
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
      return lhs.measurement < rhs.measurement
    }
  }
}
