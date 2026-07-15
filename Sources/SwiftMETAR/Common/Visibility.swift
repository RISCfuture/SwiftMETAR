import Foundation
import NumberKit

/// A visibility report, made by a human or a transmissometer.
public enum Visibility: CodedRepresentable, Equatable, Sendable {

  /**
   Visibility is equal to this value.

   - Parameter value: The visibility value.
   */
  case equal(_ value: Value)

  /**
   Visibility is less than this value.

   - Parameter value: The visibility value.
   */
  case lessThan(_ value: Value)

  /**
   Visibility is greater than this value.

   - Parameter value: The visibility value.
   */
  case greaterThan(_ value: Value)

  /**
   Visibility is variable between these values.

   - Parameter low: The low value.
   - Parameter high: The high value.
   */
  indirect case variable(_ low: Self, _ high: Self)

  /// Visibility was not recorded.
  case notRecorded

  /**
   The coded representation of this visibility, e.g. `"10SM"`, `"3/4SM"`,
   `"1 1/2SM"` (a whole number plus a fraction is a single value written with a
   space), `"1200FT"`, or `"3000"` (bare metric meters). A range is prefixed with
   `M` for ``lessThan`` (e.g. `"M1/4SM"`) or `P` for ``greaterThan``
   (e.g. `"P6SM"`). A ``variable`` visibility joins its two bounds with `V`,
   e.g. `"1000FTV1400FT"`.

   `notRecorded` has no standard coded token; it is emitted as `"////SM"`, which
   decodes back to `notRecorded` but is not an official METAR spelling.
   */
  public var codedString: String {
    switch self {
      case .equal(let value): value.codedString
      case .lessThan(let value): "M\(value.codedString)"
      case .greaterThan(let value): "P\(value.codedString)"
      case let .variable(low, high): "\(low.codedString)V\(high.codedString)"
      case .notRecorded: "////SM"
    }
  }

  /**
   Parses a coded visibility group, e.g. `"10SM"`, `"M1/4SM"`, `"1 1/2SM"`,
   `"1200FT"`, `"3000"`, or a variable range like `"1000FTV1400FT"`.

   - Parameter coded: The coded visibility string.
   - Throws: ``Error/invalidVisibility(_:)`` if `coded` is not a valid
             visibility group.
   */
  public init(coded: String) throws {
    var parts = coded.split(whereSeparator: \.isWhitespace)
    if let visibility = try VisibilityParser().parse(&parts), parts.isEmpty {
      self = visibility
      return
    }

    if let separator = coded.firstIndex(of: "V") {
      let low = try Self(coded: String(coded[..<separator]))
      let high = try Self(coded: String(coded[coded.index(after: separator)...]))
      self = .variable(low, high)
      return
    }

    throw Error.invalidVisibility(coded)
  }

  public static func == (lhs: Self, rhs: Self) -> Bool {
    switch lhs {
      case .equal(let lhsValue):
        guard case .equal(let rhsValue) = rhs else { return false }
        return lhsValue == rhsValue
      case .lessThan(let lhsValue):
        guard case .lessThan(let rhsValue) = rhs else { return false }
        return lhsValue == rhsValue
      case .greaterThan(let lhsValue):
        guard case .greaterThan(let rhsValue) = rhs else { return false }
        return lhsValue == rhsValue
      case let .variable(lhsLow, lhsHigh):
        guard case let .variable(rhsLow, rhsHigh) = rhs else { return false }
        return lhsLow == rhsLow && lhsHigh == rhsHigh
      case .notRecorded:
        guard case .notRecorded = rhs else { return false }
        return true
    }
  }

  /// A distance as used in a visibility report.
  public enum Value: CodedRepresentable, Comparable, Sendable {

    /**
     A distance reported in statute miles, as a vulgar fraction.
     Used when parsing text METARs with fraction visibility (e.g., "3/4SM").

     - Parameter value: distance, in statute miles.
     */
    case statuteMiles(_ value: Ratio)

    /**
     A distance reported in statute miles, as a decimal.
     Used when parsing XML METARs where visibility is provided as decimal (e.g., 0.75).

     - Parameter value: distance, in statute miles.
     */
    case statuteMilesDecimal(_ value: Double)

    /**
     A distance reported in feet.

     - Parameter value: The distance, in feet.
     */
    case feet(_ value: UInt16)

    /**
     A distance reported in meters.

     - Parameter value: The distance, in meters.
     */
    case meters(_ value: UInt16)

    /// The distance expressed as a `Measurement`, which is convertible to
    /// other units.
    public var measurement: Measurement<UnitLength> {
      switch self {
        case .statuteMiles(let value): .init(value: value.doubleValue, unit: .miles)
        case .statuteMilesDecimal(let value): .init(value: value, unit: .miles)
        case .feet(let value): .init(value: Double(value), unit: .feet)
        case .meters(let value): .init(value: Double(value), unit: .meters)
      }
    }

    /**
     The coded representation of this distance, without any range prefix, e.g.
     `"10SM"`, `"3/4SM"`, `"1 1/2SM"`, `"1200FT"`, or `"3000"` for bare metric
     meters.

     `statuteMilesDecimal` has no native coded METAR form; it is rendered as a
     decimal `"SM"` string (e.g. `"0.75SM"`), which the parser cannot read back,
     so it is lossy and non-idempotent.
     */
    public var codedString: String {
      switch self {
        case .statuteMiles(let value): Self.coded(statuteMiles: value)
        case .statuteMilesDecimal(let value): Self.coded(statuteMilesDecimal: value)
        case .feet(let value): "\(value)FT"
        case .meters(let value): "\(value)"
      }
    }

    /**
     Parses a coded distance, without any range prefix, e.g. `"10SM"`, `"3/4SM"`,
     `"1 1/2SM"`, `"1200FT"`, or `"3000"`.

     - Parameter coded: The coded distance string.
     - Throws: ``Error/invalidVisibility(_:)`` if `coded` is not a valid,
               unqualified distance.
     */
    public init(coded: String) throws {
      guard case let .equal(value) = try Visibility(coded: coded) else {
        throw Error.invalidVisibility(coded)
      }
      self = value
    }

    private static func coded(statuteMiles ratio: Ratio) -> String {
      let whole = ratio.numerator / ratio.denominator
      let remainder = ratio.numerator % ratio.denominator
      let body =
        if remainder == 0 {
          "\(whole)"
        } else if whole == 0 {
          "\(ratio.numerator)/\(ratio.denominator)"
        } else {
          "\(whole) \(remainder)/\(ratio.denominator)"
        }
      return "\(body)SM"
    }

    private static func coded(statuteMilesDecimal value: Double) -> String {
      let body = value == value.rounded() ? "\(Int(value))" : "\(value)"
      return "\(body)SM"
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
      return lhs.measurement == rhs.measurement
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
      return lhs.measurement < rhs.measurement
    }
  }
}
