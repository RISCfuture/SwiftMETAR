import Foundation

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
    
    /// Forecasted icing could not be parsed.
    case invalidIcing(_ icing: String)
    
    /// Forecasted turbulence could not be parsed.
    case invalidTurbulence(_ turbulence: String)
    
    /// Forecasted temperature or temperature extreme could not be parsed.
    case invalidForecastTemperature(_ temperature: String)
}
 
extension Error: LocalizedError {
    public var errorDescription: String? {
        return t("Couldn’t parse METAR or TAF.", comment: "error description")
    }
    
    public var failureReason: String? {
        switch self {
            case .badFormat:
                return t("METAR or TAF format is incorrect.", comment: "failure reason")
            case let .unknownReportType(type):
                return t("Unknown report type ‘%@’.", comment: "failure reason",
                         type)
            case let .invalidDate(date):
                return t("Invalid date ‘%@’.", comment: "failure reason",
                         date)
            case let .invalidWinds(winds):
                return t("Invalid winds ‘%@’.", comment: "failure reason",
                         winds)
            case let .invalidVisibility(visibility):
                return t("Invalid visibility ‘%@’.", comment: "failure reason",
                         visibility)
            case let .invalidWeather(weather):
                return t("Invalid weather ‘%@’.", comment: "failure reason",
                         weather)
            case let .invalidConditions(conditions):
                return t("Invalid conditions ‘%@’.", comment: "failure reason",
                         conditions)
            case let .invalidTempDewpoint(temps):
                return t("Invalid temperature and dewpoint ‘%@’.", comment: "failure reason",
                         temps)
            case let .invalidAltimeter(altimeter):
                return t("Invalid altimeter setting ‘%@’.", comment: "failure reason",
                         altimeter)
            case let .invalidPeriod(period):
                return t("Invalid TAF period ‘%@’.", comment: "failure reason",
                         period)
            case let .invalidWindshear(windshear):
                return t("Invalid low-level windshear ‘%@’.", comment: "failure reason",
                         windshear)
            case let .invalidIcing(icing):
                return t("Invalid icing ‘%@’", comment: "failure reason",
                         icing)
            case let .invalidTurbulence(turbulence):
                return t("Invalid turbulence ‘%@’", comment: "failure reason",
                         turbulence)
            case let .invalidForecastTemperature(temp):
                return t("Invalid forecast temperature ‘%@’", comment: "failure reason",
                         temp)
        }
    }
    
    public var recoverySuggestion: String? {
        return t("Verify the format of the METAR or TAF string.", comment: "recovery suggestion")
    }
}

fileprivate func t(_ key: String, comment: String, _ arguments: CVarArg...) -> String {
    let format = NSLocalizedString(key, bundle: Bundle.module, comment: comment)
    if arguments.isEmpty {
        return format
    } else {
        return String(format: format, arguments: arguments)
    }
}
