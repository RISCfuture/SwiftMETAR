/// A sea-level pressure altimeter setting.
public enum Altimeter: Codable, Comparable {
    
    /**
     An altimeter setting in inches of mercury (typical in the US).
     
     - Parameter value: The altimeter setting, in inHg multiplied by 100.
     */
    case inHg(_ value: UInt16) // 100s
    
    /// An altimeter setting in hectopascals (typical in Europe).
    case hPa(_ value: UInt16)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(String.self, forKey: .units) {
            case "inHg":
                self = .inHg(try container.decode(UInt16.self, forKey: .value))
            case "hPa":
                self = .hPa(try container.decode(UInt16.self, forKey: .value))
            default:
                throw DecodingError.dataCorruptedError(forKey: CodingKeys.units, in: container, debugDescription: "Invalid enum value")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
            case let .inHg(value):
                try container.encode(value, forKey: .value)
                try container.encode("inHq", forKey: .units)
            case let .hPa(value):
                try container.encode(value, forKey: .value)
                try container.encode("hPa", forKey: .units)
        }
    }
    
    /// The altimeter setting in inches of mercury (converted from inHg*100 or
    /// hPa as appropriate). This field is used for comparison.
    public var inHg: Float {
        switch self {
            case let .inHg(value): return Float(value)/100
            case let .hPa(value): return Float(value)*0.02953
        }
    }
    
    public static func == (lhs: Altimeter, rhs: Altimeter) -> Bool {
        return lhs.inHg == rhs.inHg
    }
    
    public static func < (lhs: Altimeter, rhs: Altimeter) -> Bool {
        return lhs.inHg < rhs.inHg
    }
    
    enum CodingKeys: String, CodingKey {
        case value, units
    }
}
