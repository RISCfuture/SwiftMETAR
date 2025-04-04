import Foundation

/// METAR and TAF parsing errors.
public enum Error: Swift.Error {

    /// Format was bad in general, so that no groups could be parsed.
    case badFormat

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
        return String(localized: "Couldn’t parse METAR or TAF.", comment: "error description")
    }

    public var failureReason: String? {
        switch self {
            case .badFormat:
                return String(localized: "METAR or TAF format is incorrect.", comment: "failure reason")
            case let .invalidDate(date):
                return String(localized: "Invalid date ‘\(date)’.", comment: "failure reason")
            case let .invalidWinds(winds):
                return String(localized: "Invalid winds ‘\(winds)’.", comment: "failure reason")
            case let .invalidVisibility(visibility):
                return String(localized: "Invalid visibility ‘\(visibility)’.", comment: "failure reason")
            case let .invalidWeather(weather):
                return String(localized: "Invalid weather ‘\(weather)’.", comment: "failure reason")
            case let .invalidConditions(conditions):
                return String(localized: "Invalid conditions ‘\(conditions)’.", comment: "failure reason")
            case let .invalidTempDewpoint(temps):
                return String(localized: "Invalid temperature and dewpoint ‘\(temps)’.", comment: "failure reason")
            case let .invalidAltimeter(altimeter):
                return String(localized: "Invalid altimeter setting ‘\(altimeter)’.", comment: "failure reason")
            case let .invalidPeriod(period):
                return String(localized: "Invalid TAF period ‘\(period)’.", comment: "failure reason")
            case let .invalidWindshear(windshear):
                return String(localized: "Invalid low-level windshear ‘\(windshear)’.", comment: "failure reason")
            case let .invalidIcing(icing):
                return String(localized: "Invalid icing ‘\(icing)’", comment: "failure reason")
            case let .invalidTurbulence(turbulence):
                return String(localized: "Invalid turbulence ‘\(turbulence)’", comment: "failure reason")
            case let .invalidForecastTemperature(temp):
                return String(localized: "Invalid forecast temperature ‘\(temp)’", comment: "failure reason")
        }
    }

    public var recoverySuggestion: String? {
        return String(localized: "Verify the format of the METAR or TAF string.", comment: "recovery suggestion")
    }
}
