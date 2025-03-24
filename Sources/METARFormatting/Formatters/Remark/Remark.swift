import Foundation
import SwiftMETAR
import BuildableMacro

public extension Remark {
    
    /// Formatter for `Remark`
    @Buildable struct FormatStyle: Foundation.FormatStyle, Sendable {
        
        /// The format to use when printing times (default: hour and minute).
        public var dateFormat = Date.FormatStyle(date: .omitted, time: .shortened)
        
        /// The format to use when printing precipitation amounts and depths (inches).
        public var precipAmountFormat = Measurement<UnitLength>.FormatStyle(
            width: .abbreviated,
            usage: .asProvided,
            numberFormatStyle: .number.precision(.fractionLength(2)))
        
        /// The format to use when printing temperatures (°C).
        public var tempFormat = Measurement<UnitTemperature>.FormatStyle(
            width: .abbreviated,
            usage: .asProvided,
            numberFormatStyle: .number.precision(.fractionLength(1))
        )
        
        /// The format to use when printing hailstone sizes (inches).
        public var hailstoneSizeFormat = Measurement<UnitLength>.FormatStyle(
            width: .abbreviated,
            usage: .asProvided,
            numberFormatStyle: .number.precision(.fractionLength(2)))
        
        /// The format to use when printing cloud heights (feet).
        public var heightFormat = Measurement<UnitLength>.FormatStyle(
            width: .abbreviated,
            usage: .asProvided,
            numberFormatStyle: .number.precision(.fractionLength(0)))
        
        /// The format to use when printing visibility distances (statute miles).
        public var distanceFormat = Measurement<UnitLength>.FormatStyle(
            width: .abbreviated,
            usage: .asProvided,
            numberFormatStyle: .number.precision(.fractionLength(0)))
        
        /// The format to use when printing air pressures (hectopascals).
        public var pressureFormat = Measurement<UnitPressure>.FormatStyle(
            width: .abbreviated,
            usage: .asProvided,
            numberFormatStyle: .number.precision(.fractionLength(1)))
        
        /// The format to use when printing wind information.
        public var windFormat = Wind.FormatStyle()
        
        /// The format to use when printing time durations (minutes).
        public var durationFormat = Measurement<UnitDuration>.FormatStyle(
            width: .abbreviated,
            usage: .asProvided,
            numberFormatStyle: .number.precision(.fractionLength(0)))
            
        public func format(_ value: Remark) -> String {
            switch value {
                case .nosig:
                    return String(localized: "no significant weather", comment: "remark")
                    
                case .aircraftMishap:
                    return String(localized: "aircraft mishap", comment: "remark")
                    
                case let .cloudTypes(low, middle, high):
                    return String(localized: "observed cloud types, low: \(low, format: .lowClouds), middle: \(middle, format: .middleClouds), high: \(high, format: .highClouds)", comment: "remark")
                    
                case let .correction(time):
                    guard let date = Calendar.current.date(from: time) else {
                        return String(localized: "correction issued", comment: "remark")
                    }
                    return String(localized: "correction issued at \(date, format: dateFormat)", comment: "remark")
                    
                case .dailyPrecipitationAmount:
                    guard let amount = value.precipitationAmountMeasurement else {
                        return String(localized: "daily precipitation amount: unknown", comment: "remark")
                    }
                    if amount.value.isZero {
                        return String(localized: "daily precipitation amount: trace", comment: "remark")
                    }
                    return String(localized: "daily precipitation amount: \(amount, format: precipAmountFormat)", comment: "remark")
                    
                case .dailyTemperatureExtremes:
                    return String(localized: "daily temperature extremes: low \(value.lowTemperatureMeasurement!, format: tempFormat), high \(value.highTemperatureMeasurement!, format: tempFormat)", comment: "remark")
                    
                case .hailstoneSize:
                    return String(localized: "hailstone size: \(value.hailstoneSizeMeasurement!, format: hailstoneSizeFormat)", comment: "remark")
                    
                case let .hourlyPrecipitationAmount(amount):
                    if amount.isZero {
                        return String(localized: "daily precipitation amount: trace", comment: "remark")
                    }
                    return String(localized: "hourly precipitation amount: \(value.precipitationAmountMeasurement!, format: precipAmountFormat)", comment: "remark")
                    
                case .last:
                    return String(localized: "final METAR/TAF", comment: "remark")
                    
                case let .lightning(frequency, types, proximity, directions):
                    let parts = [
                        String(localized: "lightning", comment: "lightning remark part"),
                        proximity  == nil  ? nil : Remark.Proximity.FormatStyle.proximity.format(proximity!),
                        frequency == nil ? nil : Remark.Frequency.FormatStyle.frequency.format(frequency!),
                        types.isEmpty ? nil : ListFormatStyle.list(memberStyle: .lightning, type: .and).format(types),
                        directions.isEmpty ? nil : Remark.Direction.RangeFormatStyle.range(width: .full).format(directions),
                        
                    ].compactMap(\.self)
                    return parts.joined(separator: ", ")
                    
                case .maintenance:
                    return String(localized: "station requires maintenance", comment: "remark")
                    
                case let .navalForecaster(center, ID):
                    return String(localized: "\(center, format: .navalWeatherCenter(width: .abbreviated)) forecaster \(ID)", comment: "remark")
                    
                case let .next(components):
                    guard let time = Calendar.current.date(from: components) else {
                        return String(localized: "next issuance <unknown>", comment: "remark")
                    }
                    return String(localized: "next issuance \(time, format: dateFormat)", comment: "remark")
                    
                case let .noAmendmentsAfter(components):
                    guard let time = Calendar.current.date(from: components) else {
                        return String(localized: "no amendments after <unknown>", comment: "remark")
                    }
                    return String(localized: "no amendments after \(time, format: dateFormat)", comment: "remark")
                    
                case .noSPECI:
                    return String(localized: "no SPECI issuances", comment: "remark")
                    
                case let .obscuration(type, amount, _):
                    if let amount {
                        return String(localized: "\(amount, format: .coverage) \(type, format: .phenomenon) at \(value.heightMeasurement!, format: heightFormat)", comment: "obscurstion remark (coverage, type, height)")
                    } else {
                        return String(localized: "\(type, format: .phenomenon) at \(value.heightMeasurement!, format: heightFormat)", comment: "obscuration remark (type, height)")
                    }
                    
                case let .observationType(type, augmented):
                    if augmented {
                        return String(localized: "\(type, format: .observationType) (augmented)", comment: "observation type remark")
                    }
                    else { return Remark.ObservationType.FormatStyle.observationType.format(type) }
                    
                case let .observedPrecipitation(type, proximity, directions):
                    if let proximity {
                        return String(localized: "\(proximity, format: .proximity) \(type, format: .precipitation) \(directions, format: .range(width: .abbreviated))", comment: "observed precip remark (proximity, type, directions)")
                    } else {
                        return String(localized: "\(type, format: .precipitation) \(directions, format: .range(width: .abbreviated))", comment: "observed precip remark (type, directions)")
                    }
                    
                case let .observedVisibility(source, _):
                    return String(localized: "\(source, format: .source(includeVisibility: true)) \(value.distanceMeasurement!, format: distanceFormat)", comment: "observed viz remark (source, distance)")
                    
                case let .peakWinds(wind, components):
                    guard let date = Calendar.current.date(from: components) else {
                        return String(localized: "peak winds \(wind, format: windFormat) at <unknown time>", comment: "remark")
                    }
                    return String(localized: "peak winds \(wind, format: windFormat) at \(date, format: dateFormat)", comment: "remark")
                    
                case let .periodicIceAccretionAmount(period, _):
                    return String(localized: "\(period, format: .number)-hour ice accretion \(value.precipitationAmountMeasurement!, format: precipAmountFormat)", comment: "remark")
                    
                case let .periodicPrecipitationAmount(period, _):
                    if let amount = value.precipitationAmountMeasurement {
                        return String(localized: "\(period, format: .number)-hour precipitation amount \(amount, format: precipAmountFormat)", comment: "remark")
                    } else {
                        return String(localized: "\(period, format: .number)-hour precipitation amount unknown", comment: "remark")
                    }
                    
                case let .precipitationBeginEnd(events):
                    return ListFormatStyle.list(memberStyle: .event(dateFormat: dateFormat), type: .and).format(events)
                    
                case let .pressureTendency(character, _):
                    return String(localized: "\(character, format: .pressureCharacter) (change: \(value.pressureMeasurement!, format: pressureFormat))", comment: "remark")
                    
                case let .rapidPressureChange(change):
                    switch change {
                        case .rising: return String(localized: "pressure rapidly rising", comment: "remark")
                        case .falling: return String(localized: "pressure rapidly falling", comment: "remark")
                    }
                    
                case .rapidSnowIncrease:
                    return String(localized: "rapid snow increase (\(value.depthIncreaseMeasurment!, format: precipAmountFormat) increase, \(value.totalDepthMeasurement!, format: precipAmountFormat) total)", comment: "remark")
                    
                case let .relativeHumidity(percent):
                    return String(localized: "relative humidity \(percent, format: .percent)", comment: "remark")
                    
                case let .runwayCeiling(runway, _):
                    return String(localized: "runway \(runway) ceiling \(value.heightMeasurement!, format: heightFormat)", comment: "remark")
                    
                case let .runwayVisibility(runway, _):
                    return String(localized: "runway \(runway) visibility \(value.distanceMeasurement!, format: distanceFormat)", comment: "remark")
                    
                case .seaLevelPressure:
                    if let pressure = value.pressureMeasurement {
                        return String(localized: "sea-level pressure \(pressure, format: pressureFormat)", comment: "remark")
                    } else {
                        return String(localized: "sea-level pressure unknown", comment: "remark")
                    }
                    
                case let .sectorVisibility(direction, _):
                    return String(localized: "visibility \(direction, format: .direction(width: .full)) \(value.distanceMeasurement!, format: distanceFormat)", comment: "remark")
                    
                case let .inoperativeSensor(sensor):
                    return String(localized: "\(sensor, format: .sensor) inoperative", comment: "sensor inoperative remark")
                    
                case let .significantClouds(type, directions, movingDirection, distant, apparent):
                    let parts = [
                        Remark.SignificantCloudType.FormatStyle.cloudType.format(type),
                        distant ? String(localized: "distant", comment: "signific. clouds remark part") : nil,
                        apparent ? String(localized: "apparent", comment: "signific. clouds remark part") : nil,
                        directions.isEmpty ? nil : Remark.Direction.RangeFormatStyle.range(width: .full).format(directions),
                        movingDirection == nil ? nil : String(localized: "moving \(movingDirection!, format: .direction(width: .full))", comment: "remark part")
                    ].compactMap(\.self)
                    return parts.joined(separator: ", ")
                    
                case let .sixHourTemperatureExtreme(type, _):
                    switch type {
                        case .low:
                            return String(localized: "6-hour temperature low \(value.temperatureMeasurement!, format: tempFormat)", comment: "remark")
                        case .high:
                            return String(localized: "6-hour temperature high \(value.temperatureMeasurement!, format: tempFormat)", comment: "remark")
                    }
                    
                case .snowDepth:
                    return String(localized: "snow depth \(value.depthMeasurement!, format: precipAmountFormat)", comment: "remark")
                    
                case .sunshineDuration:
                    return String(localized: "previous day sunshine duration \(value.durationMeasurement!, format: durationFormat)", comment: "remark")
                    
                case .temperatureDewpoint:
                    if let dewpoint = value.dewpointMeasurement {
                        return String(localized: "temperature \(value.temperatureMeasurement!, format: tempFormat), dewpoint \(dewpoint, format: tempFormat)", comment: "remark")
                    } else {
                        return String(localized: "temperature \(value.temperatureMeasurement!, format: tempFormat)", comment: "remark")
                    }
                    
                case let .thunderstormBeginEnd(events):
                    return String(localized: "thunderstorms \(events, format: .list(memberStyle: .event(includeThunderstorms: false, dateFormat: dateFormat), type: .and))", comment: "thunderstorm events remark")
                    
                case let .thunderstormLocation(proximity, directions, movingDirection):
                    let parts = [
                        String(localized: "thunderstorms", comment: "thunderstorm remark part"),
                        proximity == nil ? nil : Remark.Proximity.FormatStyle.proximity.format(proximity!),
                        directions.isEmpty ? nil : Remark.Direction.RangeFormatStyle.range(width: .full).format(directions),
                        movingDirection == nil ? nil : String(localized: "moving \(movingDirection!, format: .direction(width: .full))", comment: "remark part")
                    ].compactMap(\.self)
                    return parts.joined(separator: ", ")
                    
                case let .tornadicActivity(type, begin, end, location, movingDirection):
                    let beginDate = begin == nil ? nil : Calendar.current.date(from: begin!),
                        endDate = end == nil ? nil : Calendar.current.date(from: end!),
                        parts = [
                            Remark.TornadicActivityType.FormatStyle.tornadicActivity.format(type),
                            beginDate == nil ? nil : String(localized: "began \(beginDate!, format: dateFormat)", comment: "remark part"),
                            endDate == nil ? nil : String(localized: "ended \(endDate!, format: dateFormat)", comment: "remark part"),
                            Remark.Location.FormatStyle.location(distanceWidth: .abbreviated).format(location),
                            movingDirection == nil ? nil : String(localized: "moving \(movingDirection!, format: .direction(width: .full))", comment: "remark part")
                        ].compactMap(\.self)
                    return parts.joined(separator: ", ")
                    
                case .variableCeilingHeight:
                    return String(localized: "ceiling variable from \(value.lowHeightMeasurement!, format: heightFormat) to \(value.highHeightMeasurement!, format: heightFormat)", comment: "remark")
                    
                case .variablePrevailingVisibility:
                    return String(localized: "prevailing visibility variable from \(value.lowVisibilityMeasurement!, format: distanceFormat) to \(value.highVisibilityMeasurement!, format: distanceFormat)", comment: "remark")
                    
                case let .variableSkyCondition(low, high, _):
                    if let height = value.heightMeasurement {
                        return String(localized: "layer at \(height, format: heightFormat) variable from \(low, format: .coverage) to \(high, format: .coverage)", comment: "remark (height, coverage, coverage)")
                    } else {
                        return String(localized: "variable from \(low, format: .coverage) to \(high, format: .coverage)", comment: "remark (coverage, coverage)")
                    }
                    
                case let .variableWindDirection(from, to):
                    let heading1 = Measurement<UnitAngle>(value: Double(from), unit: .degrees),
                        heading2 = Measurement<UnitAngle>(value: Double(to), unit: .degrees)
                    return String(localized: "wind variable from \(heading1, format: windFormat.directionFormat) to \(heading2, format: windFormat.directionFormat)", comment: "remark")
                    
                case .waterEquivalentDepth:
                    return String(localized: "equivalent water depth of snowfall \(value.depthMeasurement!, format: precipAmountFormat)", comment: "remark")
                    
                case let .windChange(wind, after):
                    let time = Calendar.current.date(from: after)
                    if let time {
                        return String(localized: "winds change to \(wind, format: windFormat) after \(time, format: dateFormat)", comment: "remark")
                    } else {
                        return String(localized: "winds change to \(wind, format: windFormat) after <unknown>", comment: "remark")
                    }
                    
                case .windDataEstimated:
                    return String(localized: "wind data estimated", comment: "remark")
                    
                case let .windShift(components, frontalPassage):
                    let time = Calendar.current.date(from: components)
                    if frontalPassage {
                        if let time {
                            return String(localized: "wind shift at \(time, format: dateFormat) (frontal passage)", comment: "remark")
                        } else {
                            return String(localized: "wind shift at <unknown> (frontal passage)", comment: "remark")
                        }
                    } else {
                        if let time {
                            return String(localized: "wind shift at \(time, format: dateFormat)", comment: "remark")
                        } else {
                            return String(localized: "wind shift at <unknown>", comment: "remark")
                        }
                    }
                    
                case let .unknown(raw):
                    return raw
            }
        }
    }
}

public extension FormatStyle where Self == Remark.FormatStyle {
    static func remark(dateFormat: Date.FormatStyle? = nil) -> Self {
        dateFormat.map { .init(dateFormat: $0) } ?? .init()
    }
    
    static var remark: Self { .init() }
}
