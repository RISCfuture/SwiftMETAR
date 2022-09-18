import Foundation

/// METAR and TAF parsing errors.
public enum Error: Swift.Error, LocalizedError {
    
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
    
    public var errorDescription: String? {
        switch self {
            case .badFormat:
                return NSLocalizedString("METAR or TAF format is incorrect.", comment: "SwiftMETAR error")
            case let .unknownReportType(type):
                return String(format: NSLocalizedString("Unknown report type ‘%@’.", comment: "SwiftMETAR error"), type)
            case let .invalidDate(date):
                return String(format: NSLocalizedString("Invalid date ‘%@’.", comment: "SwiftMETAR error"), date)
            case let .invalidWinds(winds):
                return String(format: NSLocalizedString("Invalid winds ‘%@’.", comment: "SwiftMETAR error"), winds)
            case let .invalidVisibility(visibility):
                return String(format: NSLocalizedString("Invalid visibility ‘%@’.", comment: "SwiftMETAR error"), visibility)
            case let .invalidWeather(weather):
                return String(format: NSLocalizedString("Invalid weather ‘%@’.", comment: "SwiftMETAR error"), weather)
            case let .invalidConditions(conditions):
                return String(format: NSLocalizedString("Invalid conditions ‘%@’.", comment: "SwiftMETAR error"), conditions)
            case let .invalidTempDewpoint(temps):
                return String(format: NSLocalizedString("Invalid temperature and dewpoint ‘%@’.", comment: "SwiftMETAR error"), temps)
            case let .invalidAltimeter(altimeter):
                return String(format: NSLocalizedString("Invalid altimeter setting ‘%@’.", comment: "SwiftMETAR error"), altimeter)
            case let .invalidPeriod(period):
                return String(format: NSLocalizedString("Invalid TAF period ‘%@’.", comment: "SwiftMETAR error"), period)
            case let .invalidWindshear(windshear):
                return String(format: NSLocalizedString("Invalid low-level windshear ‘%@’.", comment: "SwiftMETAR error"), windshear)
            case let .invalidIcing(icing):
                return String(format: NSLocalizedString("Invalid icing ‘%@’", comment: "SwiftMETAR error"), icing)
            case let .invalidTurbulence(turbulence):
                return String(format: NSLocalizedString("Invalid turbulence ‘%@’", comment: "SwiftMETAR error"), turbulence)
        }
    }
}
