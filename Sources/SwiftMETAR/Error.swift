/// METAR and TAF parsing errors.
public enum Error: Swift.Error {
    
    /// Format was bad in general, so that no groups could be parsed.
    case badFormat
    
    /// Report type could not be parsed.
    case unknownReportType(_ type: String)
    
    /// Date could not be parsed.
    case invalidDate(_ date: String)
    
    /// Winds could not be parsed.
    case invalidWinds(_ winds: String)
    
    /// Visibility could not be parsed.
    case invalidVisibility(_ visibility: String)
    
    /// Weather phenomena could not be parsed.
    case invalidWeather(_ weather: String)
    
    /// Sky conditions could not be parsed.
    case invalidConditions(_ conditions: String)
    
    /// Temperature/dewpoint could not be parsed.
    case invalidTempDewpoint(_ temps: String)
    
    /// Altimeter setting could not be parsed.
    case invalidAltimeter(_ altimeter: String)
    
    /// Forecast valid period could not be parsed.
    case invalidPeriod(_ period: String)
    
    /// Forecasted windshear could not be parsed.
    case invalidWindshear(_ windshear: String)
    
    
    /// A non-localized, human-readable description of the error for internal
    /// use.
    public var description: String {
        switch self {
            case .badFormat: return "METAR or TAF format is incorrect"
            case .unknownReportType(let type):
                return "Unknown report type '\(type)'"
            case .invalidDate(let date):
                return "Invalid date '\(date)'"
            case .invalidWinds(let winds):
                return "Invalid winds '\(winds)'"
            case .invalidVisibility(let visibility):
                return "Invalid visibility '\(visibility)'"
            case .invalidWeather(let weather):
                return "Invalid weather '\(weather)'"
            case .invalidConditions(let conditions):
                return "Invalid conditions '\(conditions)'"
            case .invalidTempDewpoint(let temps):
                return "Invalid temperature and dewpoint '\(temps)'"
            case .invalidAltimeter(let altimeter):
                return "Invalid altimeter setting '\(altimeter)'"
            case .invalidPeriod(let period):
                return "Invalid TAF period '\(period)'"
            case .invalidWindshear(let windshear):
                return "Invalid low-level windshear '\(windshear)'"
        }
    }
}
