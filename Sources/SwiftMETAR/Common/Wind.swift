/// A report on the condition and strength of the winds.
public enum Wind: Codable, Equatable {
    
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
    case directionRange(_ heading: UInt16, headingRange: (UInt16, UInt16), speed: Speed, gust: Speed? = nil)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(String.self, forKey: .type) {
            case "calm":
                self = .calm
            case "variable":
                let speed = try container.decode(Speed.self, forKey: .speed)
                let headingLow = try container.decode(Optional<UInt16>.self, forKey: .headingLow)
                let headingHigh = try container.decode(Optional<UInt16>.self, forKey: .headingHigh)
                if let low = headingLow, let high = headingHigh {
                    self = .variable(speed: speed, headingRange: (low, high))
                } else {
                    self = .variable(speed: speed)
                }
            case "direction":
                let speed = try container.decode(Speed.self, forKey: .speed)
                let gust = try container.decode(Optional<Speed>.self, forKey: .gust)
                let heading = try container.decode(UInt16.self, forKey: .heading)
                self = .direction(heading, speed: speed, gust: gust)
            case "range":
                let speed = try container.decode(Speed.self, forKey: .speed)
                let gust = try container.decode(Optional<Speed>.self, forKey: .gust)
                let heading = try container.decode(UInt16.self, forKey: .heading)
                let headingLow = try container.decode(UInt16.self, forKey: .headingLow)
                let headingHigh = try container.decode(UInt16.self, forKey: .headingHigh)
                self = .directionRange(heading, headingRange: (headingLow, headingHigh), speed: speed, gust: gust)
            default:
                throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown enum value")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
            case .calm:
                try container.encode("calm", forKey: .type)
            case let .variable(speed, headingRange):
                try container.encode("variable", forKey: .type)
                try container.encode(speed, forKey: .speed)
                if let range = headingRange {
                    try container.encode(range.0, forKey: .headingLow)
                    try container.encode(range.1, forKey: .headingHigh)
                }
            case let .direction(heading, speed, gust):
                try container.encode("direction", forKey: .type)
                try container.encode(speed, forKey: .speed)
                try container.encode(gust, forKey: .gust)
                try container.encode(heading, forKey: .heading)
            case let .directionRange(heading, headingRange, speed, gust):
                try container.encode("range", forKey: .type)
                try container.encode(speed, forKey: .speed)
                try container.encode(gust, forKey: .gust)
                try container.encode(heading, forKey: .heading)
                try container.encode(headingRange.0, forKey: .headingLow)
                try container.encode(headingRange.1, forKey: .headingHigh)
        }
    }
    
    public static func == (lhs: Wind, rhs: Wind) -> Bool {
        switch lhs {
            case .calm: if case .calm = rhs { return true } else { return false }
            case let .variable(lhsSpeed, lhsRange):
                guard case let .variable(rhsSpeed, rhsRange) = rhs else { return false }
                if let lhsRange = lhsRange {
                    if let rhsRange = rhsRange {
                        // both not nil
                        return lhsSpeed == rhsSpeed
                        && lhsRange.0 == rhsRange.0 && lhsRange.1 == rhsRange.1
                    }
                    else { return false } // one nil, one not
                } else {
                    if let _ = rhsRange { return false } // one nil, one not
                    else { return lhsSpeed == rhsSpeed } // both nil
                }
            case let .direction(lhsHeading, lhsSpeed, lhsGust):
                guard case let .direction(rhsHeading, rhsSpeed, rhsGust) = rhs else { return false }
                return lhsHeading == rhsHeading && lhsSpeed == rhsSpeed && lhsGust == rhsGust
            case let .directionRange(lhsHeading, lhsRange, lhsSpeed, lhsGust):
                guard case let .directionRange(rhsHeading, rhsRange, rhsSpeed, rhsGust) = rhs else { return false }
                return lhsHeading == rhsHeading && lhsRange == rhsRange && lhsSpeed == rhsSpeed && lhsGust == rhsGust
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case type, speed, gust, heading, headingLow, headingHigh
    }
    
    /// A wind speed.
    public enum Speed: Codable, Comparable {
        
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
        
        /// The wind speed in knots, regardless of the original units. This var
        /// is used to compare wind speeds.
        public var knots: Float {
            switch self {
                case let .knots(quantity): return Float(quantity)
                case let .kph(quantity): return Float(quantity)*0.539957
                case let .mps(quantity): return Float(quantity)*1.94384
            }
        }
        
        public static func == (lhs: Speed, rhs: Speed) -> Bool {
            return lhs.knots == rhs.knots
        }
        
        public static func < (lhs: Speed, rhs: Speed) -> Bool {
            return lhs.knots < rhs.knots
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            switch try container.decode(String.self, forKey: .unit) {
                case "KT":
                    let quantity = try container.decode(UInt16.self, forKey: .quantity)
                    self = .knots(quantity)
                case "KPH":
                    let quantity = try container.decode(UInt16.self, forKey: .quantity)
                    self = .kph(quantity)
                case "MPS":
                    let quantity = try container.decode(UInt16.self, forKey: .quantity)
                    self = .mps(quantity)
                default:
                    throw DecodingError.dataCorruptedError(forKey: .unit, in: container, debugDescription: "Unknown enum value")
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
                case let .knots(quantity):
                    try container.encode("KT", forKey: .unit)
                    try container.encode(quantity, forKey: .quantity)
                case let .kph(quantity):
                    try container.encode("KPH", forKey: .unit)
                    try container.encode(quantity, forKey: .quantity)
                case let .mps(quantity):
                    try container.encode("MPS", forKey: .unit)
                    try container.encode(quantity, forKey: .quantity)
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case unit, quantity
        }
    }
}

