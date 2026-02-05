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
        return String(
          localized: "Couldn’t parse Winds Aloft product.",
          comment: "error description"
        )
      default:
        return String(localized: "Couldn’t parse METAR or TAF.", comment: "error description")
    }
  }

  public var failureReason: String? {
    switch self {
      case .badFormat:
        return String(localized: "METAR or TAF format is incorrect.", comment: "failure reason")
      case .invalidDate(let date):
        return String(localized: "Invalid date ‘\(date)’.", comment: "failure reason")
      case .invalidWinds(let winds):
        return String(localized: "Invalid winds ‘\(winds)’.", comment: "failure reason")
      case .invalidVisibility(let visibility):
        return String(localized: "Invalid visibility ‘\(visibility)’.", comment: "failure reason")
      case .invalidWeather(let weather):
        return String(localized: "Invalid weather ‘\(weather)’.", comment: "failure reason")
      case .invalidConditions(let conditions):
        return String(localized: "Invalid conditions ‘\(conditions)’.", comment: "failure reason")
      case .invalidTempDewpoint(let temps):
        return String(
          localized: "Invalid temperature and dewpoint ‘\(temps)’.",
          comment: "failure reason"
        )
      case .invalidAltimeter(let altimeter):
        return String(
          localized: "Invalid altimeter setting ‘\(altimeter)’.",
          comment: "failure reason"
        )
      case .invalidPeriod(let period):
        return String(localized: "Invalid TAF period ‘\(period)’.", comment: "failure reason")
      case .invalidWindshear(let windshear):
        return String(
          localized: "Invalid low-level windshear ‘\(windshear)’.",
          comment: "failure reason"
        )
      case .invalidIcing(let icing):
        return String(localized: "Invalid icing ‘\(icing)’", comment: "failure reason")
      case .invalidTurbulence(let turbulence):
        return String(localized: "Invalid turbulence ‘\(turbulence)’", comment: "failure reason")
      case .invalidForecastTemperature(let temp):
        return String(
          localized: "Invalid forecast temperature '\(temp)'",
          comment: "failure reason"
        )
      case .invalidWindsAloftHeader(let header):
        return String(
          localized: "Invalid winds aloft header '\(header)'.",
          comment: "failure reason"
        )
      case .invalidWindsAloftGroup(let group):
        return String(
          localized: "Invalid winds aloft data group '\(group)'.",
          comment: "failure reason"
        )
      case .invalidWindsAloftColumns(let columns):
        return String(
          localized: "Invalid winds aloft column layout '\(columns)'.",
          comment: "failure reason"
        )
    }
  }

  public var recoverySuggestion: String? {
    switch self {
      case .invalidWindsAloftHeader, .invalidWindsAloftGroup, .invalidWindsAloftColumns:
        return String(
          localized: "Verify the format of the Winds Aloft product.",
          comment: "recovery suggestion"
        )
      default:
        return String(
          localized: "Verify the format of the METAR or TAF string.",
          comment: "recovery suggestion"
        )
    }
  }
}
