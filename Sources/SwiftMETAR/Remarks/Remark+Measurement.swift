import Foundation

extension Remark {

  /**
   The precipitation amount as a `Measurement`, which can be converted to
   other units. `nil` if this remark is not a ``dailyPrecipitationAmount(_:)``, ``hourlyPrecipitationAmount(_:)``, ``periodicPrecipitationAmount(period:amount:)``,
   or ``periodicIceAccretionAmount(period:amount:)``.
   */
  public var precipitationAmountMeasurement: Measurement<UnitLength>? {
    switch self {
      case .dailyPrecipitationAmount(let amount):
        guard let amount else { return nil }
        return .init(value: Double(amount), unit: .inches)
      case .hourlyPrecipitationAmount(let amount):
        return .init(value: Double(amount), unit: .inches)
      case .periodicPrecipitationAmount(_, let amount):
        guard let amount else { return nil }
        return .init(value: Double(amount), unit: .inches)
      case .periodicIceAccretionAmount(_, let amount):
        return .init(value: Double(amount), unit: .inches)
      default: return nil
    }
  }

  /**
   The daily low-temperature extreme as a `Measurement`, which can be
   converted to other units. `nil` if this is not a
   ``dailyTemperatureExtremes(low:high:)``.
   */
  public var lowTemperatureMeasurement: Measurement<UnitTemperature>? {
    switch self {
      case .dailyTemperatureExtremes(let low, _): .init(value: Double(low), unit: .celsius)
      default: nil
    }
  }

  /**
   The daily high-temperature extreme as a `Measurement`, which can be
   converted to other units. `nil` if this is not a
   ``dailyTemperatureExtremes(low:high:)``.
   */
  public var highTemperatureMeasurement: Measurement<UnitTemperature>? {
    switch self {
      case .dailyTemperatureExtremes(_, let high): .init(value: Double(high), unit: .celsius)
      default: nil
    }
  }

  /**
   The hailstone size as a `Measurement`, which can be converted to other
   units. `nil` if this is not a ``hailstoneSize(_:)``.
   */
  public var hailstoneSizeMeasurement: Measurement<UnitLength>? {
    switch self {
      case .hailstoneSize(let size): .init(value: size.doubleValue, unit: .inches)
      default: nil
    }
  }

  /**
   The height as a `Measurement`, which can be converted to other units. `nil`
   if this is not an ``obscuration(type:amount:height:)``,
   ``runwayCeiling(runway:height:)``, or ``variableSkyCondition(low:high:height:)``.
   */
  public var heightMeasurement: Measurement<UnitLength>? {
    switch self {
      case .obscuration(_, _, let height):
        return .init(value: Double(height), unit: .feet)
      case .runwayCeiling(_, let height):
        return .init(value: Double(height), unit: .feet)
      default: return nil
    }
  }

  /**
   The distance as a `Measurement`, which can be converted to other units.
   `nil` if this is not an ``observedVisibility(source:distance:)``,
   ``runwayVisibility(runway:distance:)``, or ``sectorVisibility(direction:distance:)``.
   */
  public var distanceMeasurement: Measurement<UnitLength>? {
    switch self {
      case .observedVisibility(_, let distance):
        return .init(value: distance.doubleValue, unit: .miles)
      case .runwayVisibility(_, let distance):
        return .init(value: distance.doubleValue, unit: .miles)
      case .sectorVisibility(_, let distance):
        return .init(value: distance.doubleValue, unit: .miles)
      default:
        return nil
    }
  }

  /**
   The pressure change as a `Measurement`, which can be converted to other
   units. `nil` if this is not a ``pressureTendency(character:change:)`` or
   ``seaLevelPressure(_:)``.
   */
  public var pressureMeasurement: Measurement<UnitPressure>? {
    switch self {
      case .pressureTendency(_, let change):
        return .init(value: Double(change), unit: .hectopascals)
      case .seaLevelPressure(let pressure):
        guard let pressure else { return nil }
        return .init(value: Double(pressure), unit: .hectopascals)
      default: return nil
    }
  }

  /**
   The depth increase as a `Measurement`, which can be converted to other
   units. `nil` if this is not a ``rapidSnowIncrease(_:totalDepth:)``.
   */
  public var depthIncreaseMeasurment: Measurement<UnitLength>? {
    switch self {
      case .rapidSnowIncrease(let depthIncrease, _):
        .init(value: Double(depthIncrease), unit: .inches)
      default: nil
    }
  }

  /**
   The total deptyh as a `Measurement`, which can be converted to other
   units. `nil` if this is not a ``rapidSnowIncrease(_:totalDepth:)``.
   */
  public var totalDepthMeasurement: Measurement<UnitLength>? {
    switch self {
      case .rapidSnowIncrease(_, let totalDepth):
        .init(value: Double(totalDepth), unit: .inches)
      default: nil
    }
  }

  /**
   The temperature as a `Measurement`, which can be converted to other units.
   `nil` if this is not a ``sixHourTemperatureExtreme(type:temperature:)`` or
   ``temperatureDewpoint(temperature:dewpoint:)``.
   */
  public var temperatureMeasurement: Measurement<UnitTemperature>? {
    switch self {
      case .sixHourTemperatureExtreme(_, let temperature):
        .init(value: Double(temperature), unit: .celsius)
      case .temperatureDewpoint(let temperature, _):
        .init(value: Double(temperature), unit: .celsius)
      default: nil
    }
  }

  /**
   The depth as a `Measurement`, which can be converted to other units. `nil`
   if this is not a ``snowDepth(_:)`` or ``waterEquivalentDepth(_:)``.
   */
  public var depthMeasurement: Measurement<UnitLength>? {
    switch self {
      case .snowDepth(let depth): .init(value: Double(depth), unit: .inches)
      case .waterEquivalentDepth(let depth): .init(value: Double(depth), unit: .inches)
      default: nil
    }
  }

  /**
   The duration as a `Measurement`, which can be converted to other units.
   `nil` if this is not a ``sunshineDuration(_:)``.
   */
  public var durationMeasurement: Measurement<UnitDuration>? {
    switch self {
      case .sunshineDuration(let duration): .init(value: Double(duration), unit: .minutes)
      default: nil
    }
  }

  /**
   The dewpoint as a `Measurement`, which can be converted to other units.
   `nil` if this is not a ``temperatureDewpoint(temperature:dewpoint:)``.
   */
  public var dewpointMeasurement: Measurement<UnitTemperature>? {
    switch self {
      case .temperatureDewpoint(_, let dewpoint):
        guard let dewpoint else { return nil }
        return .init(value: Double(dewpoint), unit: .celsius)
      default: return nil
    }
  }

  /**
   The lower height as a `Measurement`, which can be converted to other units.
   `nil` if this is not a ``variableCeilingHeight(low:high:)``.
   */
  public var lowHeightMeasurement: Measurement<UnitLength>? {
    switch self {
      case .variableCeilingHeight(let low, _): .init(value: Double(low), unit: .feet)
      default: nil
    }
  }

  /**
   The higher height as a `Measurement`, which can be converted to other
   units. `nil` if this is not a ``variableCeilingHeight(low:high:)``.
   */
  public var highHeightMeasurement: Measurement<UnitLength>? {
    switch self {
      case .variableCeilingHeight(_, let high): .init(value: Double(high), unit: .feet)
      default: nil
    }
  }

  /**
   The lower visibility as a `Measurement`, which can be converted to other
   units. `nil` if this is not a ``variablePrevailingVisibility(low:high:)``.
   */
  public var lowVisibilityMeasurement: Measurement<UnitLength>? {
    switch self {
      case .variablePrevailingVisibility(let low, _):
        .init(value: low.doubleValue, unit: .miles)
      default: nil
    }
  }

  /**
   The higher visibility as a `Measurement`, which can be converted to other
   units. `nil` if this is not a ``variablePrevailingVisibility(low:high:)``.
   */
  public var highVisibilityMeasurement: Measurement<UnitLength>? {
    switch self {
      case .variablePrevailingVisibility(_, let high):
        .init(value: high.doubleValue, unit: .miles)
      default: nil
    }
  }
}
