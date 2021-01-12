import Foundation

/**
 Terminal aerodrome forecasts (TAFs) are point forecasts of a 5-mile area around
 a forecast location. They are generated every 6 hours, and are valid for 24 or
 28 hours depending on the reporting station.
 
 A TAF object consists of an origin date, when it was originally reported, and
 one or more `Group`s, each of which contains a valid period, and the weather
 that is forecasted during that valid period.
 */

public struct TAF: Codable {
    
    /// The raw text of the TAF.
    public let text: String?
    
    /// The reason for this TAF's issuance.
    public let issuance: Issuance
    
    /// The reporting station ICAO code (typically an airport).
    public let airportID: String
    
    /// The components of the date that the forecast was generated.
    public let originCalendarDate: DateComponents
    
    /// The forecasted weather changes, and the valid periods for each forecast.
    public let groups: Array<Group>
    
    /// Additional remarks following the forecast.
    public let remarks: String?
    
    /// The date that the forecast was generated.
    public var originDate: Date { originCalendarDate.date! }
    
    /**
     Parse a TAF from its text.
     
     - Parameter string: The TAF text.
     - Parameter date: TAF dates only include the day and hour. By default, the
                       month and year are taken from the current date. If you
                       pass in a date here, its month and year will be used for
                       the TAF dates.
     - Parameter lenientRemarks: If true, does not require the string "RMK" to
                                 appear before the remarks section. This will
                                 reduce the amount of errors when parsing non-US
                                 TAFs, but can result in mis-formatted weather
                                 data being parsed as a remark.
     - Returns: The parsed TAF.
     - Throws: If a parsing error occurs.
     */
    public static func from(string: String, on date: Date? = nil, lenientRemarks: Bool = false) throws -> TAF {
        return try parseTAF(string, on: date, lenientRemarks: lenientRemarks)
    }
    
    /**
     Generates a snapshot of the forecasted weather at a given time within the
     forecast period. The closest prior `FM` (from) entry is combined with any
     subsequent `TEMPO` or `PROB` entries (regardless of probability) to create
     an aggregate `Group`, which is returned.
     
     - Parameter date: The date to generate aggregate weather for.
     - Returns: The aggregate weather at that time, or `nil` if `date` is
                outside the forecast period.
     */
    public func during(_ date: Date) -> Group? {
        guard covers(date) else { return nil }
        
        let components = zuluCal.dateComponents(in: zulu, from: date)
        var combinedGroup = Group(period: .from(components), wind: nil, visibility: nil, weather: [], conditions: [], windshear: nil)
        
        for group in groups {
            switch group.period {
                case .from(let from):
                    guard let fromDate = zuluCal.date(from: from) else { continue }
                    print(date, fromDate)
                    if date < fromDate { continue }
                case .range(let period):
                    if !period.contains(date) { continue }
                case .probability(_, let period):
                    if !period.contains(date) { continue }
                case .temporary(let period):
                    if !period.contains(date) { continue }
                case .becoming(let period):
                    if !period.contains(date) { continue }
            }
            // if we're still here, this period covers the date in question
            
            switch group.period {
                case .from(_): // reset all the fields
                    combinedGroup.wind = group.wind
                    combinedGroup.visibility = group.visibility
                    combinedGroup.weather = group.weather
                    combinedGroup.conditions = group.conditions
                    combinedGroup.windshear = group.windshear
                default:
                    if let wind = group.wind { combinedGroup.wind = wind }
                    if let visibility = group.visibility { combinedGroup.visibility = visibility }
                    if !group.weather.isEmpty { combinedGroup.weather = group.weather }
                    if !group.conditions.isEmpty { combinedGroup.conditions = group.conditions }
                    if let windshear = group.windshear { combinedGroup.windshear = windshear }
            }
        }
        
        return combinedGroup
    }
    
    /**
     Returns `true` if the given date is within this TAF's forecast period.
     
     - Parameter date: A date.
     - Returns: Whether `date` is within the forecast period.
     */
    public func covers(_ date: Date) -> Bool {
        guard !groups.isEmpty else { return false }
        
        switch groups[0].period {
            case .range(let period):
                return period.contains(date)
            default: preconditionFailure("TAF must start with group with range period") //TODO is this too extreme
        }
    }
    
    /// Reasons for a TAF issuance.
    public enum Issuance: String, Codable {
        
        /// Routine 6-hour issuance.
        case routine = ""
        
        /// Amended TAF with additional forecasts.
        case amended = "AMD"
        
        /// Correction of incorrect information.
        case corrected = "COR"
    }
    
    /// A snapshot of weather conditions for a forecast period. Not all weather
    /// information need be supplied.
    public struct Group: Codable, Equatable {
        
        /// The period during which these forecasts are valid.
        public let period: Period
        
        /// The forecasted winds.
        public var wind: Wind?
        
        /// The forecasted visibility.
        public var visibility: Visibility?
        
        /// Any forecasted weather phenomena.
        public var weather: Array<Weather>
        
        /// Any forecasted cloud coverage.
        public var conditions: Array<Condition>
        
        /// Forecasted altimeter setting.
        public var altimeter: Altimeter?
        
        /// Any forecasted windshear.
        public var windshear: Windshear?
        
        /// A valid period for a TAF or one of its groups.
        public enum Period: Codable, Equatable {
            
            /**
             Forecast is valid between two dates.
             
             - Parameter period: The valid period.
             */
            case range(_ period: DateComponentsInterval)
            
            /**
             Forecast is valid starting at a date.
             
             - Parameter from: The start date.
             */
            case from(_ from: DateComponents)
            
            /**
             Forecast is valid between two dates within a larger date range
             covered by a `.from` entry.
             
             - Parameter period: The valid period.
             */
            case temporary(_ period: DateComponentsInterval)
            
            /**
             Changing to this forecast within this time period.
             
             - Parameter period: The valid period.
             */
            case becoming(_ period: DateComponentsInterval)
            
            /**
             Forecast has a probability of becoming valid between two dates.
             
             - Parameter probability: The percentage probability of this
                                      forecast.
             - Parameter period: The valid period.
             */
            case probability(_ probability: UInt8, period: DateComponentsInterval)
            
            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                switch try container.decode(String.self, forKey: .type) {
                    case "":
                        let period = try container.decode(DateComponentsInterval.self, forKey: .period)
                        self = .range(period)
                    case "FM":
                        let from = try container.decode(DateComponents.self, forKey: .from)
                        self = .from(from)
                    case "TEMPO":
                        let period = try container.decode(DateComponentsInterval.self, forKey: .period)
                        self = .temporary(period)
                    case "BCMG":
                        let period = try container.decode(DateComponentsInterval.self, forKey: .period)
                        self = .becoming(period)
                    case "PROB":
                        let probability = try container.decode(UInt8.self, forKey: .probability)
                        let period = try container.decode(DateComponentsInterval.self, forKey: .period)
                        self = .probability(probability, period: period)
                    default:
                        throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown enum value")
                }
            }
            
            public func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                switch self {
                    case .range(let period):
                        try container.encode("", forKey: .type)
                        try container.encode(period, forKey: .period)
                    case .from(let from):
                        try container.encode("FM", forKey: .type)
                        try container.encode(from, forKey: .from)
                    case .temporary(let period):
                        try container.encode("TEMPO", forKey: .type)
                        try container.encode(period, forKey: .period)
                    case .becoming(let period):
                        try container.encode("BCMG", forKey: .type)
                        try container.encode(period, forKey: .period)
                    case .probability(let probability, let period):
                        try container.encode("PROB", forKey: .type)
                        try container.encode(probability, forKey: .probability)
                        try container.encode(period, forKey: .period)
                }
            }
            
            public static func == (lhs: Period, rhs: Period) -> Bool {
                switch lhs {
                    case .range(let lhsPeriod):
                        switch rhs {
                            case .range(let rhsPeriod): return lhsPeriod == rhsPeriod
                            default: return false
                        }
                    case .from(let lhsFrom):
                        switch rhs {
                            case .from(let rhsFrom): return lhsFrom == rhsFrom
                            default: return false
                        }
                    case .temporary(let lhsPeriod):
                        switch rhs {
                            case .temporary(let rhsPeriod): return lhsPeriod == rhsPeriod
                            default: return false
                        }
                    case .becoming(let lhsPeriod):
                        switch rhs {
                            case .becoming(let rhsPeriod): return lhsPeriod == rhsPeriod
                            default: return false
                        }
                    case .probability(let lhsProb, let lhsPeriod):
                        switch rhs {
                            case .probability(let rhsProb, let rhsPeriod):
                                return lhsProb == rhsProb && lhsPeriod == rhsPeriod
                            default: return false
                        }
                }
            }
            
            enum CodingKeys: String, CodingKey {
                case type, probability, from, period
            }
        }
    }
}
