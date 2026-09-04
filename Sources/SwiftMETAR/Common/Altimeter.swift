public import Foundation

/// A sea-level pressure altimeter setting.
public enum Altimeter: CodedRepresentable, Comparable, Sendable {

  /**
   An altimeter setting in inches of mercury (typical in the US).

   - Parameter value: The altimeter setting, in inHg multiplied by 100.
   */
  case inHg(_ value: UInt16)  // 100s

  /// An altimeter setting in hectopascals (typical in Europe).
  case hPa(_ value: UInt16)

  /// The value as a `Measurement`, which can be converted to other units.
  public var measurement: Measurement<UnitPressure> {
    switch self {
      case .inHg(let value): .init(value: Double(value) / 100, unit: .inchesOfMercury)
      case .hPa(let value): .init(value: Double(value), unit: .hectopascals)
    }
  }

  /**
   The coded representation of this altimeter setting, e.g. `"A2992"` for
   inches of mercury (the value in inHg × 100) or `"Q1013"` for hectopascals.
   Both are zero-padded to four digits (e.g. `hPa(995)` → `"Q0995"`).
   */
  public var codedString: String {
    switch self {
      case .inHg(let value): "A\(String(format: "%04d", value))"
      case .hPa(let value): "Q\(String(format: "%04d", value))"
    }
  }

  /**
   Parses a coded altimeter setting, e.g. `"A2992"` or `"Q1013"`.

   - Parameter coded: The coded string.
   - Throws: ``Error/invalidAltimeter(_:)`` if `coded` is not a valid altimeter
             setting.
   */
  public init(coded: String) throws {
    var parts = coded.split(whereSeparator: \.isWhitespace)
    guard let altimeter = try AltimeterParser().parseMETAR(&parts), parts.isEmpty else {
      throw Error.invalidAltimeter(coded)
    }
    self = altimeter
  }

  public static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs.measurement == rhs.measurement
  }

  public static func < (lhs: Self, rhs: Self) -> Bool {
    return lhs.measurement < rhs.measurement
  }
}
