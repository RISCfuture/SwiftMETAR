import Foundation
import Regex

/// A sky condition, either a cloud layer or the presence of a clear sky.
public enum Condition: Equatable {
    
    /// Sky clear below 12,000 feet (USA) or 25,000 feet (Canada). Typically
    /// reported by automated ceilometers.
    case clear
    
    /// Sky clear. Typically reported by human observers.
    case skyClear
    
    /// No significant clouds below 5,000 feet and no TCU or CB.
    case noSignificantClouds
    
    /**
     Included outside US region as a replacement of
     visibility, cloud, and weather groups.
     
     - No clouds exist below 5,000 feet or below the highest minimum sector
     altitude, whichever is greater, and no TCU or CB are present.
     - Visibility is 10 kilometres or greater
     - No precipitation, thunderstorms, sandstorm, dust storm, shallow fog,
     or low drifting dust, sand or snow is occurring (no significant weather).
     */
    case cavok
    
    /**
     Cloud coverage between 1 and 2 oktas.
     
     - Parameter height: The cloud bases in feet AGL.
     - Parameter type: The vertical development, if any.
     */
    case few(_ height: UInt, type: CeilingType? = nil)
    
    /**
     Cloud coverage between 3 and 4 oktas.
     
     - Parameter height: The cloud bases in feet AGL.
     - Parameter type: The vertical development, if any.
     */
    case scattered(_ height: UInt, type: CeilingType? = nil)
    
    /**
     Cloud coverage between 5 and 7 oktas.
     
     - Parameter height: The cloud bases in feet AGL.
     - Parameter type: The vertical development, if any.
     */
    case broken(_ height: UInt, type: CeilingType? = nil)
    
    /**
     Cloud coverage of 8 oktas.
     
     - Parameter height: The cloud bases in feet AGL.
     - Parameter type: The vertical development, if any.
     */
    case overcast(_ height: UInt, type: CeilingType? = nil)
    
    /**
     Cloud coverage is obscured by low-visibility conditions; the height of the
     obscuration layer is reported instead.
     
     - Parameter ceiling: The top altitude of the obscuration layer, in feet
                          AGL.
     - Parameter type: The vertical development, if any.
     */
    case indefinite(_ ceiling: UInt?, type: CeilingType? = nil)
    
    public var type: CeilingType? {
        switch self {
        case let .few(_, type), let .scattered(_, type),
            let .broken(_, type), let .overcast(_, type),
            let .indefinite(_, type):
            return type

        case .clear, .skyClear, .noSignificantClouds, .cavok:
            return nil
        }
    }
    
    /// Types of vertical development that a cloud layer can have.
    public enum CeilingType: String, Codable, CaseIterable {
        
        /// Layer consists of cumulonimbus clouds.
        case cumulonimbus = "CB"
        
        /// Layer consists of towering cumulus clouds.
        case toweringCumulus = "TCU"
        
        /// If the type of clouds cannot be measured.
        case undefined = "///"
    }
}

fileprivate extension Condition {
    /// The cloud cover for parsing.
     enum RawValueType: String, Codable, CaseIterable {
        case clear = "CLR"
        case skyClear = "SKC"
        case noSignificantClouds = "NSC"
        case noCloudsDetected = "NCD"
        case cavok = "CAVOK"
        case few = "FEW"
        case scattered = "SCT"
        case broken = "BKN"
        case overcast = "OVC"
        case verticalVisibility = "VV"
        case undefined = "///"
    }
}

extension Condition: Codable {
    
    enum CodingKeys: String, CodingKey {
        case coverage, height, type
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let raw = try container.decode(String.self, forKey: .coverage)
        switch RawValueType(rawValue: raw) {
        case .clear: self = .clear
        case .skyClear: self = .skyClear
        case .noSignificantClouds: self = .noSignificantClouds
        case .cavok: self = .cavok
        case .few:
            let (height, type) = try Self.decodeHeightAndTypeFrom(container: container)
            self = .few(height, type: type)
        case .scattered:
            let (height, type) = try Self.decodeHeightAndTypeFrom(container: container)
            self = .scattered(height, type: type)
        case .broken:
            let (height, type) = try Self.decodeHeightAndTypeFrom(container: container)
            self = .broken(height, type: type)
        case .overcast:
            let (height, type) = try Self.decodeHeightAndTypeFrom(container: container)
            self = .overcast(height, type: type)
        case .verticalVisibility:
            let (height, type) = try Self.decodeHeightAndTypeFrom(container: container)
            self = .indefinite(height, type: type)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown enum value")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .clear: try container.encode(RawValueType.clear.rawValue, forKey: .coverage)
        case .skyClear: try container.encode(RawValueType.skyClear.rawValue, forKey: .coverage)
        case .noSignificantClouds: try container.encode(RawValueType.noSignificantClouds.rawValue, forKey: .coverage)
        case .cavok: try container.encode(RawValueType.cavok.rawValue, forKey: .coverage)
        case let .few(height, type):
            try container.encode(RawValueType.few.rawValue, forKey: .coverage)
            try container.encode(height, forKey: .height)
            try container.encode(type, forKey: .type)
        case let .scattered(height, type):
            try container.encode(RawValueType.scattered.rawValue, forKey: .coverage)
            try container.encode(height, forKey: .height)
            try container.encode(type, forKey: .type)
        case let .broken(height, type):
            try container.encode(RawValueType.broken.rawValue, forKey: .coverage)
            try container.encode(height, forKey: .height)
            try container.encode(type, forKey: .type)
        case let .overcast(height, type):
            try container.encode(RawValueType.overcast.rawValue, forKey: .coverage)
            try container.encode(height, forKey: .height)
            try container.encode(type, forKey: .type)
        case let .indefinite(height, type):
            try container.encode(RawValueType.verticalVisibility.rawValue, forKey: .coverage)
            try container.encode(height, forKey: .height)
            try container.encode(type, forKey: .type)
        }
    }
    
    private static func decodeHeightAndTypeFrom(
        container: KeyedDecodingContainer<Condition.CodingKeys>
    ) throws -> (UInt, Condition.CeilingType?) {
        let height = try container.decode(UInt.self, forKey: .height)
        guard let rawType = try container.decode(Optional<String>.self, forKey: .type) else {
            return (height, nil)
        }
        guard let type = Condition.CeilingType(rawValue: rawType) else {
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unknown enum value")
        }
        return (height, type)
    }
}

extension Condition: RawRepresentable {
    
    fileprivate static let coverages = Condition.RawValueType.allCases
        .map(\.rawValue)
        .map(NSRegularExpression.escapedPattern(for:))
        .joined(separator: "|")
    fileprivate static let types = Condition.CeilingType.allCases
        .map { NSRegularExpression.escapedPattern(for: $0.rawValue) }
        .joined(separator: "|")
    fileprivate static let conditionsRx = try! Regex(string: "^(\(coverages))(\\d+|///)(\(types))?$")
    
    public var rawValue: String {
        switch self {
        case .clear: 
            return RawValueType.clear.rawValue

        case .skyClear:
            return RawValueType.skyClear.rawValue
            
        case .noSignificantClouds:
            return RawValueType.noSignificantClouds.rawValue
            
        case .cavok:
            return RawValueType.cavok.rawValue
            
        case
            let .few(height, type),
            let .scattered(height, type),
            let .broken(height, type),
            let .overcast(height, type):
            return "\(RawValueType.few.rawValue)\(Self.feetToFlightLevel(height).description)\(type.map(\.rawValue) ?? "")"
        
        case let .indefinite(height, type):
            return "\(RawValueType.few.rawValue)\(height.map(Self.feetToFlightLevel)?.description ?? "///")\(type.map(\.rawValue) ?? "")"
        }
    }
    
    public init?(rawValue: String) {
        
        switch RawValueType(rawValue: rawValue) {
        case .skyClear:
            self = .skyClear
            return
            
        case .clear, .noCloudsDetected:
            self = .clear
            return
            
        case .noSignificantClouds:
            self = .noSignificantClouds
            return
            
        case .cavok:
            self = .cavok
            return
            
        default:
            break
        }
            
        guard
            let match = Self.conditionsRx.firstMatch(in: rawValue),
            let raw = match.captures[0],
            let coverage = Condition.RawValueType(rawValue: raw)
        else { return nil }
        
        let height = match.captures[1]
            .flatMap(UInt.init)
            .map(Self.flightLeveltoFeet)
        
        let type: Condition.CeilingType? = try? match.captures[2]
            .flatMap { rawCeiling in try .init(
                rawCondition: rawValue,
                rawCeiling: rawCeiling,
                coverage: coverage)
            }

        switch (coverage, height) {
        case let (.few, .some(height)):
            self = .few(height, type: type)
        case let (.scattered, .some(height)):
            self = .scattered(height, type: type)
        case let (.broken, .some(height)): 
            self = .broken(height, type: type)
        case let (.overcast, .some(height)): 
            self = .overcast(height, type: type)
        case let (.verticalVisibility, .some(height)): 
            self = .indefinite(height)
        case let (.undefined, height):
            self = .indefinite(height, type: type)
        default:
            return nil
        }
    }
    
    private static func flightLeveltoFeet(_ fl: UInt) -> UInt {
        fl * 100
    }
    
    private static func feetToFlightLevel(_ fl: UInt) -> UInt {
        fl / 100
    }
}

extension Condition.RawValueType {
    static var allowingCeilingTypeCases: [Self] {
        [.few, .scattered, .broken, .overcast, .undefined]
    }
}

extension Condition.CeilingType {
    fileprivate init?(rawCondition: String, rawCeiling: String, coverage: Condition.RawValueType) throws {
        guard Condition.RawValueType.allowingCeilingTypeCases.contains(coverage)
        else { throw Error.invalidConditions(rawCondition) }
        self.init(rawValue: rawCeiling)
    }
}
