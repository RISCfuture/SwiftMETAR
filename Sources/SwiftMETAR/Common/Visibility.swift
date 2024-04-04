import Foundation
import NumberKit

/// A visibility report, made by a human or a transmissometer.
public enum Visibility: Codable, Equatable {
    
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
    indirect case variable(_ low: Visibility, _ high: Visibility)
    
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
                let low = try container.decode(Visibility.self, forKey: .low)
                let high = try container.decode(Visibility.self, forKey: .high)
                self = .variable(low, high)
            default:
                throw DecodingError.dataCorruptedError(forKey: .constraint, in: container, debugDescription: "Unknown enum value")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
            case let .equal(value):
                try container.encode("=", forKey: .constraint)
                try container.encode(value, forKey: .value)
            case let .lessThan(value):
                try container.encode("<", forKey: .constraint)
                try container.encode(value, forKey: .value)
            case let .greaterThan(value):
                try container.encode(">", forKey: .constraint)
                try container.encode(value, forKey: .value)
            case let .variable(low, high):
                try container.encode("<>", forKey: .constraint)
                try container.encode(low, forKey: .low)
                try container.encode(high, forKey: .high)
        }
    }
    
    public static func == (lhs: Visibility, rhs: Visibility) -> Bool {
        switch lhs {
            case let .equal(lhsValue):
                guard case let .equal(rhsValue) = rhs else { return false }
                return lhsValue == rhsValue
            case let .lessThan(lhsValue):
                guard case let .lessThan(rhsValue) = rhs else { return false }
                return lhsValue == rhsValue
            case let .greaterThan(lhsValue):
                guard case let .greaterThan(rhsValue) = rhs else { return false }
                return lhsValue == rhsValue
            case let .variable(lhsLow, lhsHigh):
                guard case let .variable(rhsLow, rhsHigh) = rhs else { return false }
                return lhsLow == rhsLow && lhsHigh == rhsHigh
        }
    }
    
    /// A distance as used in a visibility report.
    public enum Value: Codable, Comparable {
        
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
                case let .statuteMiles(value): .init(value: value.doubleValue, unit: .miles)
                case let .feet(value): .init(value: Double(value), unit: .feet)
                case let .meters(value): .init(value: Double(value), unit: .meters)
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
                    throw DecodingError.dataCorruptedError(forKey: .unit, in: container, debugDescription: "Unknown enum value")
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
                case let .statuteMiles(value):
                    try container.encode("SM", forKey: .unit)
                    try container.encode(value, forKey: .value)
                case let .feet(value):
                    try container.encode("FT", forKey: .unit)
                    try container.encode(value, forKey: .value)
                case let .meters(value):
                    try container.encode("M", forKey: .unit)
                    try container.encode(value, forKey: .value)
            }
        }
        
        public static func == (lhs: Value, rhs: Value) -> Bool {
            return lhs.measurement == rhs.measurement
        }
        
        public static func < (lhs: Value, rhs: Value) -> Bool {
            return lhs.measurement < rhs.measurement
        }
        
        enum CodingKeys: String, CodingKey {
            case unit, value, numerator, denominator
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case constraint, value, low, high
    }
}
