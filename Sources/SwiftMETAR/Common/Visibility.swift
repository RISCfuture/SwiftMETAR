import Foundation
import NumberKit

/// A visibility report, made by a human or a transmissometer.
public enum Visibility: Codable, Equatable, Sendable {

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

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    switch try container.decode(String.self, forKey: .constraint) {
      case "=":
        let value = try container.decode(Value.self, forKey: .value)
        self = .equal(value)
      case "<":
        let value = try container.decode(Value.self, forKey: .value)
        self = .lessThan(value)
      case ">":
        let value = try container.decode(Value.self, forKey: .value)
        self = .greaterThan(value)
      case "<>":
        let low = try container.decode(Self.self, forKey: .low)
        let high = try container.decode(Self.self, forKey: .high)
        self = .variable(low, high)
      default:
        throw DecodingError.dataCorruptedError(
          forKey: .constraint,
          in: container,
          debugDescription: "Unknown enum value"
        )
    }
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
      case .variable(let lhsLow, let lhsHigh):
        guard case .variable(let rhsLow, let rhsHigh) = rhs else { return false }
        return lhsLow == rhsLow && lhsHigh == rhsHigh
      case .notRecorded:
        guard case .notRecorded = rhs else { return false }
        return true
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
      case .equal(let value):
        try container.encode("=", forKey: .constraint)
        try container.encode(value, forKey: .value)
      case .lessThan(let value):
        try container.encode("<", forKey: .constraint)
        try container.encode(value, forKey: .value)
      case .greaterThan(let value):
        try container.encode(">", forKey: .constraint)
        try container.encode(value, forKey: .value)
      case .variable(let low, let high):
        try container.encode("<>", forKey: .constraint)
        try container.encode(low, forKey: .low)
        try container.encode(high, forKey: .high)
      case .notRecorded:
        try container.encode("no", forKey: .constraint)
    }
  }

  /// A distance as used in a visibility report.
  public enum Value: Codable, Comparable, Sendable {

    /**
     A distance reported in statute miles, as a vulgar fraction.
    
     - Parameter value: distance, in statute miles.
     */
    case statuteMiles(_ value: Ratio)

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
        case .feet(let value): .init(value: Double(value), unit: .feet)
        case .meters(let value): .init(value: Double(value), unit: .meters)
      }
    }

    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      switch try container.decode(String.self, forKey: .unit) {
        case "SM":
          let value = try container.decode(Ratio.self, forKey: .value)
          self = .statuteMiles(value)
        case "FT":
          let value = try container.decode(UInt16.self, forKey: .value)
          self = .feet(value)
        case "M":
          let value = try container.decode(UInt16.self, forKey: .value)
          self = .meters(value)
        default:
          throw DecodingError.dataCorruptedError(
            forKey: .unit,
            in: container,
            debugDescription: "Unknown enum value"
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
        case .statuteMiles(let value):
          try container.encode("SM", forKey: .unit)
          try container.encode(value, forKey: .value)
        case .feet(let value):
          try container.encode("FT", forKey: .unit)
          try container.encode(value, forKey: .value)
        case .meters(let value):
          try container.encode("M", forKey: .unit)
          try container.encode(value, forKey: .value)
      }
    }

    enum CodingKeys: String, CodingKey {
      case unit, value, numerator, denominator
    }
  }

  enum CodingKeys: String, CodingKey {
    case constraint, value, low, high
  }
}
