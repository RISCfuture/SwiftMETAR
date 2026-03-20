import Foundation

/// METAR, TAF, and Winds Aloft parsing errors.
public enum Error: Swift.Error, Equatable {

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

  /// Winds aloft header could not be parsed.
  case invalidWindsAloftHeader(_ header: String)

  /// Winds aloft data group could not be parsed.
  case invalidWindsAloftGroup(_ group: String)

  /// Winds aloft column layout could not be parsed.
  case invalidWindsAloftColumns(_ columns: String)
}

extension Error: LocalizedError {
  public var errorDescription: String? {
    switch self {
      case .invalidWindsAloftHeader, .invalidWindsAloftGroup, .invalidWindsAloftColumns:
        #if canImport(Darwin)
          return String(
            localized: "Couldn’t parse Winds Aloft product.",
            comment: "error description"
          )
        #else
          return "Couldn’t parse Winds Aloft product."
        #endif
      default:
        #if canImport(Darwin)
          return String(localized: "Couldn’t parse METAR or TAF.", comment: "error description")
        #else
          return "Couldn’t parse METAR or TAF."
        #endif
    }
  }

  public var failureReason: String? {
    switch self {
      case .badFormat:
        #if canImport(Darwin)
          return String(localized: "METAR or TAF format is incorrect.", comment: "failure reason")
        #else
          return "METAR or TAF format is incorrect."
        #endif
      case .invalidDate(let date):
        #if canImport(Darwin)
          return String(localized: "Invalid date ‘\(date)’.", comment: "failure reason")
        #else
          return "Invalid date ‘\(date)’."
        #endif
      case .invalidWinds(let winds):
        #if canImport(Darwin)
          return String(localized: "Invalid winds ‘\(winds)’.", comment: "failure reason")
        #else
          return "Invalid winds ‘\(winds)’."
        #endif
      case .invalidVisibility(let visibility):
        #if canImport(Darwin)
          return String(localized: "Invalid visibility ‘\(visibility)’.", comment: "failure reason")
        #else
          return "Invalid visibility ‘\(visibility)’."
        #endif
      case .invalidWeather(let weather):
        #if canImport(Darwin)
          return String(localized: "Invalid weather ‘\(weather)’.", comment: "failure reason")
        #else
          return "Invalid weather ‘\(weather)’."
        #endif
      case .invalidConditions(let conditions):
        #if canImport(Darwin)
          return String(localized: "Invalid conditions ‘\(conditions)’.", comment: "failure reason")
        #else
          return "Invalid conditions ‘\(conditions)’."
        #endif
      case .invalidTempDewpoint(let temps):
        #if canImport(Darwin)
          return String(
            localized: "Invalid temperature and dewpoint ‘\(temps)’.",
            comment: "failure reason"
          )
        #else
          return "Invalid temperature and dewpoint ‘\(temps)’."
        #endif
      case .invalidAltimeter(let altimeter):
        #if canImport(Darwin)
          return String(
            localized: "Invalid altimeter setting ‘\(altimeter)’.",
            comment: "failure reason"
          )
        #else
          return "Invalid altimeter setting ‘\(altimeter)’."
        #endif
      case .invalidPeriod(let period):
        #if canImport(Darwin)
          return String(localized: "Invalid TAF period ‘\(period)’.", comment: "failure reason")
        #else
          return "Invalid TAF period ‘\(period)’."
        #endif
      case .invalidWindshear(let windshear):
        #if canImport(Darwin)
          return String(
            localized: "Invalid low-level windshear ‘\(windshear)’.",
            comment: "failure reason"
          )
        #else
          return "Invalid low-level windshear ‘\(windshear)’."
        #endif
      case .invalidIcing(let icing):
        #if canImport(Darwin)
          return String(localized: "Invalid icing ‘\(icing)’", comment: "failure reason")
        #else
          return "Invalid icing ‘\(icing)’"
        #endif
      case .invalidTurbulence(let turbulence):
        #if canImport(Darwin)
          return String(localized: "Invalid turbulence ‘\(turbulence)’", comment: "failure reason")
        #else
          return "Invalid turbulence ‘\(turbulence)’"
        #endif
      case .invalidForecastTemperature(let temp):
        #if canImport(Darwin)
          return String(
            localized: "Invalid forecast temperature '\(temp)'",
            comment: "failure reason"
          )
        #else
          return "Invalid forecast temperature '\(temp)'"
        #endif
      case .invalidWindsAloftHeader(let header):
        #if canImport(Darwin)
          return String(
            localized: "Invalid winds aloft header '\(header)'.",
            comment: "failure reason"
          )
        #else
          return "Invalid winds aloft header '\(header)'."
        #endif
      case .invalidWindsAloftGroup(let group):
        #if canImport(Darwin)
          return String(
            localized: "Invalid winds aloft data group '\(group)'.",
            comment: "failure reason"
          )
        #else
          return "Invalid winds aloft data group '\(group)'."
        #endif
      case .invalidWindsAloftColumns(let columns):
        #if canImport(Darwin)
          return String(
            localized: "Invalid winds aloft column layout '\(columns)'.",
            comment: "failure reason"
          )
        #else
          return "Invalid winds aloft column layout '\(columns)'."
        #endif
    }
  }

  public var recoverySuggestion: String? {
    switch self {
      case .invalidWindsAloftHeader, .invalidWindsAloftGroup, .invalidWindsAloftColumns:
        #if canImport(Darwin)
          return String(
            localized: "Verify the format of the Winds Aloft product.",
            comment: "recovery suggestion"
          )
        #else
          return "Verify the format of the Winds Aloft product."
        #endif
      default:
        #if canImport(Darwin)
          return String(
            localized: "Verify the format of the METAR or TAF string.",
            comment: "recovery suggestion"
          )
        #else
          return "Verify the format of the METAR or TAF string."
        #endif
    }
  }
}
