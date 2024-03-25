import NumberKit
import Regex

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
        
        /// The distance in feet, regardless of the original units. This var is
        /// used for comparison between distances.
        public var feet: Float {
            switch self {
            case let .feet(value): return Float(value)
            case let .meters(value): return Float(value)*3.28084
            case let .statuteMiles(value): return Float(value.magnitude)*5280
            }
        }
        
        public static func == (lhs: Value, rhs: Value) -> Bool {
            return lhs.feet == rhs.feet
        }
        
        public static func < (lhs: Value, rhs: Value) -> Bool {
            return lhs.feet < rhs.feet
        }
        
        enum CodingKeys: String, CodingKey {
            case unit, value, numerator, denominator
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case constraint, value, low, high
    }
}

extension Visibility: RawRepresentable {
    
    public var rawValue: String {
        return "unimplemented"
        
        switch self {
        case let .lessThan(value):
            fatalError()
        case let .equal(value):
            fatalError()
        case let .greaterThan(value):
            fatalError()
        case let .variable(low, high):
            fatalError()
        }
    }
    
    public init?(rawValue: String) {
        
        switch rawValue {
        case "CAVOK", "9999":
            self = .greaterThan(.meters(9999))
            return
        case "10SM":
            self = .greaterThan(.statuteMiles(10))
            return
        case "M":
            return nil
            
        case let rawValue:
            
            if let int = UInt16(rawValue) {
                self = .equal(.meters(int))
                return
            }
            
            if let fraction = FractionResult(rawValue: rawValue) {
                switch fraction.rangeValue {
                    case .lessThan: self = .lessThan(.statuteMiles(fraction.value))
                    case .equal: self = .equal(.statuteMiles(fraction.value))
                    case .greaterThan: self = .greaterThan(.statuteMiles(fraction.value))
                }
                return
            }
            
            guard let whole = IntegerResult(rawValue: rawValue) else {
                return nil
            }
            
            switch whole.units {
            case "SM":
                let value = Ratio(Int(whole.value), 1)
                switch whole.rangeValue {
                case .lessThan: self = .lessThan(.statuteMiles(value))
                case .equal: self = .equal(.statuteMiles(value))
                case .greaterThan: self = .greaterThan(.statuteMiles(value))
                }
            case "M":
                switch whole.rangeValue {
                case .lessThan: self = .lessThan(.meters(whole.value))
                case .equal: self = .equal(.meters(whole.value))
                case .greaterThan: self = .greaterThan(.meters(whole.value))
                }
            case "FT":
                switch whole.rangeValue {
                case .lessThan: self = .lessThan(.feet(whole.value))
                case .equal: self = .equal(.feet(whole.value))
                case .greaterThan: self = .greaterThan(.feet(whole.value))
                }
            default: preconditionFailure("Unknown units")
            }
        }
    }
}

fileprivate let fractionalRx = Regex(#"^([PM])?(\d+)\/(\d+)SM$"#)

enum RangeValue {
    case lessThan, equal, greaterThan
}

fileprivate struct FractionResult {
    let value: Ratio
    let rangeValue: RangeValue
}

extension FractionResult: RawRepresentable {
    var rawValue: String {
        "Unimplemented"
    }
    
    init?(rawValue: String) {
        try? self.init(rawValueTrowing: rawValue)
    }
    
    init?(rawValueTrowing: String) throws {
        var rangeValue = RangeValue.equal
        guard let match = fractionalRx.firstMatch(in: rawValueTrowing)
        else { return nil }
        
        if let signStr = match.captures[0] {
            switch signStr {
            case "P": rangeValue = .greaterThan
            case "M": rangeValue = .lessThan
            default: throw Error.invalidVisibility(rawValueTrowing)
            }
        }
        
        guard
            let numStr = match.captures[1],
            let numerator = UInt8(numStr),
            let denStr = match.captures[2],
            let denominator = UInt8(denStr)
        else { throw Error.invalidVisibility(rawValueTrowing) }
        
        self = .init(
            value: Ratio(Int(numerator), Int(denominator)),
            rangeValue: rangeValue)
    }
}

fileprivate struct IntegerResult {
    let value: UInt16
    let units: String
    let rangeValue: RangeValue
}

extension IntegerResult: RawRepresentable {
    
    fileprivate static var rx: Regex {
        .init(#"^([PM])?(\d+)(SM|FT|M)$"#)
    }
    
    var rawValue: String {
        "unimplemented"
    }
    
    init?(rawValue: String) {
        guard let match = Self.rx.firstMatch(in: rawValue) else { return nil }
        
        switch match.captures[0] {
        case "P": rangeValue = .greaterThan
        case "M": rangeValue = .lessThan
        case .none: rangeValue = .equal
        default: return nil
        }
        
        guard 
            let valueStr = match.captures[1],
            let value = UInt16(valueStr)
        else { return nil }

        units = match.captures[2] ?? "M"
        self.value = value
    }
}
