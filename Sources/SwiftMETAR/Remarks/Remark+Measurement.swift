import Foundation

public extension Remark {

    /**
     The precipitation amount as a `Measurement`, which can be converted to
     other units. `nil` if this remark is not a ``dailyPrecipitationAmount(_:)``, ``hourlyPrecipitationAmount(_:)``, ``periodicPrecipitationAmount(period:amount:)``,
     or ``periodicIceAccretionAmount(period:amount:)``.
     */
    var precipitationAmountMeasurement: Measurement<UnitLength>? {
        switch self {
            case let .dailyPrecipitationAmount(amount):
                guard let amount else { return nil }
                return .init(value: Double(amount), unit: .inches)
            case let .hourlyPrecipitationAmount(amount):
                return .init(value: Double(amount), unit: .inches)
            case let .periodicPrecipitationAmount(_, amount):
                guard let amount else { return nil }
                return .init(value: Double(amount), unit: .inches)
            case let .periodicIceAccretionAmount(_, amount):
                return .init(value: Double(amount), unit: .inches)
            default: return nil
        }
    }

    /**
     The daily low-temperature extreme as a `Measurement`, which can be
     converted to other units. `nil` if this is not a
     ``dailyTemperatureExtremes(low:high:)``.
     */
    var lowTemperatureMeasurement: Measurement<UnitTemperature>? {
        switch self {
            case let .dailyTemperatureExtremes(low, _): .init(value: Double(low), unit: .celsius)
            default: nil
        }
    }

    /**
     The daily high-temperature extreme as a `Measurement`, which can be
     converted to other units. `nil` if this is not a
     ``dailyTemperatureExtremes(low:high:)``.
     */
    var highTemperatureMeasurement: Measurement<UnitTemperature>? {
        switch self {
            case let .dailyTemperatureExtremes(_, high): .init(value: Double(high), unit: .celsius)
            default: nil
        }
    }

    /**
     The hailstone size as a `Measurement`, which can be converted to other
     units. `nil` if this is not a ``hailstoneSize(_:)``.
     */
    var hailstoneSizeMeasurement: Measurement<UnitLength>? {
        switch self {
            case let .hailstoneSize(size): .init(value: size.doubleValue, unit: .inches)
            default: nil
        }
    }

    /**
     The height as a `Measurement`, which can be converted to other units. `nil`
     if this is not an ``obscuration(type:amount:height:)``,
     ``runwayCeiling(runway:height:)``, or ``variableSkyCondition(low:high:height:)``.
     */
    var heightMeasurement: Measurement<UnitLength>? {
        switch self {
            case let .obscuration(_, _, height):
                return .init(value: Double(height), unit: .feet)
            case let .runwayCeiling(_, height):
                return .init(value: Double(height), unit: .feet)
            default: return nil
        }
    }

    /**
     The distance as a `Measurement`, which can be converted to other units.
     `nil` if this is not an ``observedVisibility(source:distance:)``,
     ``runwayVisibility(runway:distance:)``, or ``sectorVisibility(direction:distance:)``.
     */
    var distanceMeasurement: Measurement<UnitLength>? {
        switch self {
            case let .observedVisibility(_, distance):
                return .init(value: distance.doubleValue, unit: .miles)
            case let .runwayVisibility(_, distance):
                return .init(value: distance.doubleValue, unit: .miles)
            case let .sectorVisibility(_, distance):
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
    var pressureMeasurement: Measurement<UnitPressure>? {
        switch self {
            case let .pressureTendency(_, change):
                return .init(value: Double(change), unit: .hectopascals)
            case let .seaLevelPressure(pressure):
                guard let pressure else { return nil }
                return .init(value: Double(pressure), unit: .hectopascals)
            default: return nil
        }
    }

    /**
     The depth increase as a `Measurement`, which can be converted to other
     units. `nil` if this is not a ``rapidSnowIncrease(_:totalDepth:)``.
     */
    var depthIncreaseMeasurment: Measurement<UnitLength>? {
        switch self {
            case let .rapidSnowIncrease(depthIncrease, _):
                    .init(value: Double(depthIncrease), unit: .inches)
            default: nil
        }
    }

    /**
     The total deptyh as a `Measurement`, which can be converted to other
     units. `nil` if this is not a ``rapidSnowIncrease(_:totalDepth:)``.
     */
    var totalDepthMeasurement: Measurement<UnitLength>? {
        switch self {
            case let .rapidSnowIncrease(_, totalDepth):
                    .init(value: Double(totalDepth), unit: .inches)
            default: nil
        }
    }

    /**
     The temperature as a `Measurement`, which can be converted to other units.
     `nil` if this is not a ``sixHourTemperatureExtreme(type:temperature:)`` or
     ``temperatureDewpoint(temperature:dewpoint:)``.
     */
    var temperatureMeasurement: Measurement<UnitTemperature>? {
        switch self {
            case let .sixHourTemperatureExtreme(_, temperature):
                    .init(value: Double(temperature), unit: .celsius)
            case let .temperatureDewpoint(temperature, _):
                    .init(value: Double(temperature), unit: .celsius)
            default: nil
        }
    }

    /**
     The depth as a `Measurement`, which can be converted to other units. `nil`
     if this is not a ``snowDepth(_:)`` or ``waterEquivalentDepth(_:)``.
     */
    var depthMeasurement: Measurement<UnitLength>? {
        switch self {
            case let .snowDepth(depth): .init(value: Double(depth), unit: .inches)
            case let .waterEquivalentDepth(depth): .init(value: Double(depth), unit: .inches)
            default: nil
        }
    }

    /**
     The duration as a `Measurement`, which can be converted to other units.
     `nil` if this is not a ``sunshineDuration(_:)``.
     */
    var durationMeasurement: Measurement<UnitDuration>? {
        switch self {
            case let .sunshineDuration(duration): .init(value: Double(duration), unit: .minutes)
            default: nil
        }
    }

    /**
     The dewpoint as a `Measurement`, which can be converted to other units.
     `nil` if this is not a ``temperatureDewpoint(temperature:dewpoint:)``.
     */
    var dewpointMeasurement: Measurement<UnitTemperature>? {
        switch self {
            case let .temperatureDewpoint(_, dewpoint):
                guard let dewpoint else { return nil }
                return .init(value: Double(dewpoint), unit: .celsius)
            default: return nil
        }
    }

    /**
     The lower height as a `Measurement`, which can be converted to other units.
     `nil` if this is not a ``variableCeilingHeight(low:high:)``.
     */
    var lowHeightMeasurement: Measurement<UnitLength>? {
        switch self {
            case let .variableCeilingHeight(low, _): .init(value: Double(low), unit: .feet)
            default: nil
        }
    }

    /**
     The higher height as a `Measurement`, which can be converted to other
     units. `nil` if this is not a ``variableCeilingHeight(low:high:)``.
     */
    var highHeightMeasurement: Measurement<UnitLength>? {
        switch self {
            case let .variableCeilingHeight(_, high): .init(value: Double(high), unit: .feet)
            default: nil
        }
    }

    /**
     The lower visibility as a `Measurement`, which can be converted to other
     units. `nil` if this is not a ``variablePrevailingVisibility(low:high:)``.
     */
    var lowVisibilityMeasurement: Measurement<UnitLength>? {
        switch self {
            case let .variablePrevailingVisibility(low, _):
                    .init(value: low.doubleValue, unit: .miles)
            default: nil
        }
    }

    /**
     The higher visibility as a `Measurement`, which can be converted to other
     units. `nil` if this is not a ``variablePrevailingVisibility(low:high:)``.
     */
    var highVisibilityMeasurement: Measurement<UnitLength>? {
        switch self {
            case let .variablePrevailingVisibility(_, high):
                    .init(value: high.doubleValue, unit: .miles)
            default: nil
        }
    }
}
