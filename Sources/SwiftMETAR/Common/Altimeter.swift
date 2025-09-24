import Foundation

/// A sea-level pressure altimeter setting.
public enum Altimeter: Codable, Comparable, Sendable {

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

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    switch try container.decode(String.self, forKey: .units) {
      case "inHg":
        self = .inHg(try container.decode(UInt16.self, forKey: .value))
      case "hPa":
        self = .hPa(try container.decode(UInt16.self, forKey: .value))
      default:
        throw DecodingError.dataCorruptedError(
          forKey: CodingKeys.units,
          in: container,
          debugDescription: "Invalid enum value"
        )
    }
  }

  public static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs.measurement == rhs.measurement
  }

  public static func < (lhs: Self, rhs: Self) -> Bool {
    return lhs.measurement < rhs.measurement
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
      case .inHg(let value):
        try container.encode(value, forKey: .value)
        try container.encode("inHq", forKey: .units)
      case .hPa(let value):
        try container.encode(value, forKey: .value)
        try container.encode("hPa", forKey: .units)
    }
  }

  enum CodingKeys: String, CodingKey {
    case value, units
  }
}
