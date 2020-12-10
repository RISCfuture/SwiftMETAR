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
        }
    }
    
    public static func == (lhs: Visibility, rhs: Visibility) -> Bool {
        switch lhs {
            case .equal(let lhsValue):
                switch rhs {
                    case .equal(let rhsValue): return lhsValue == rhsValue
                    default: return false
                }
            case .lessThan(let lhsValue):
                switch rhs {
                    case .lessThan(let rhsValue): return lhsValue == rhsValue
                    default: return false
                }
            case .greaterThan(let lhsValue):
                switch rhs {
                    case .greaterThan(let rhsValue): return lhsValue == rhsValue
                    default: return false
                }
            case .variable(let lhsLow, let lhsHigh):
                switch rhs {
                    case .variable(let rhsLow, let rhsHigh):
                        return lhsLow == rhsLow && lhsHigh == rhsHigh
                    default: return false
                }
        }
    }
    
    /// A distance as used in a visibility report.
    public enum Value: Codable, Comparable {
        
        /**
         A distance reported in statute miles, as a vulgar fraction.
         
         - Parameter numerator: The fractional numerator of the value.
         - Parameter denominator: The fractional denominator of the value.
         */
        case statuteMiles(_ numerator: UInt8, _ denominator: UInt8 = 1)
        
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
                    let num = try container.decode(UInt8.self, forKey: .numerator)
                    let den = try container.decode(UInt8.self, forKey: .denominator)
                    self = .statuteMiles(num, den)
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
                case .statuteMiles(let num, let den):
                    try container.encode("SM", forKey: .unit)
                    try container.encode(num, forKey: .numerator)
                    try container.encode(den, forKey: .denominator)
                case .feet(let value):
                    try container.encode("FT", forKey: .unit)
                    try container.encode(value, forKey: .value)
                case .meters(let value):
                    try container.encode("M", forKey: .unit)
                    try container.encode(value, forKey: .value)
            }
        }
        
        /// The distance in feet, regardless of the original units. This var is
        /// used for comparison between distances.
        public var feet: Float {
            switch self {
                case .feet(let value): return Float(value)
                case .meters(let value): return Float(value)*3.28084
                case .statuteMiles(let num, let den): return Float(num)/Float(den)*5280
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
