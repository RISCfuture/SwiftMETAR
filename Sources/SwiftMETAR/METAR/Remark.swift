import Foundation
import NumericAnnex

/// Types of METAR remarks.
public enum Remark: Codable, Equatable {
    
    /// An aircraft mishap has occurred.
    case aircraftMishap
    
    /**
     Observed cloud types.
     
     - Parameter low: Observed cloud types below 6500 feet AGL.
     - Parameter middle: Observed cloud types between 6500 and 20,000 feet AGL.
     - Parameter high: Observed cloud types above 20,000 feet AGL.
     */
    case cloudTypes(low: LowCloudType, middle: MiddleCloudType, high: HighCloudType)
    
    /**
     METAR correction was issued.
     
     - Parameter time: The time that the correction was issued.
     */
    case correction(time: DateComponents)
    
    /**
     Daily accumulated precipitation amount.
     
     - Parameter amount: The amount, in inches. 0 indicates trace precipitation.
     */
    case dailyPrecipitationAmount(_ amount: Float?)
    
    /**
     Daily temperature extremes.
     
     - Parameter low: The low temperature extreme, in °C.
     - Parameter high: The high temperature extreme, in °C.
     */
    case dailyTemperatureExtremes(low: Float, high: Float)
    
    /**
     Largest recorded hailstone size.
     
     - Parameter size: Largest hailstone size, in inches.
     */
    case hailstoneSize(_ size: Ratio)
    
    /**
     Hourly accumulated precipitation amount.
     
     - Parameter amount: The amount, in inches. 0 indicates trace precipitation.
     */
    case hourlyPrecipitationAmount(_ amount: Float)
    
    /// Last METAR or TAF before regular reporting stops for the night.
    case last
    
    /**
     Observed or detected lightning.
     
     - Parameter frequency: How often the lightning is occurring.
     - Parameter types: The types of lightning observed.
     - Parameter proximity: How distant the lightning is from the observer.
     - Parameter directions: The direction(s) that lightning is occurring. May
                             be empty is lightning is overhead.
     */
    case lightning(frequency: Frequency?, types: Set<LightningType>, proximity: Proximity?, directions: Set<Direction>)
    
    /// An automated system detects that maintenance is needed on the system.
    case maintenance
    
    /**
     The ID of the naval weather center forecaster who produced this TAF.
     
     - Parameter center: The naval weather center that produced this TAF.
     - Parameter ID: The forecaster ID.
     */
    case navalForecaster(center: Remark.NavalWeatherCenter, ID: UInt)
    
    /**
     Time of next forecast, when regular forecasting has stopped for the day.
     
     - Parameter date: The time that forecasting will resume.
     */
    case next(_ date: DateComponents)
    
    /**
     No forecast amendments will be made after the given date.
     
     - Parameter date: The last time that forecast amendments will be published.
     */
    case noAmendmentsAfter(_ date: DateComponents)
    
    /// No changes in weather conditions will be reported until the next METAR.
    case noSPECI
    
    /**
     Weather obscuration was observed in the vicinity.
     
     - Parameter type: The type of obscuration.
     - Parameter amount: How much obscuration was present.
     - Parameter height: The height of the obscuration, in feet AGL.
     */
    case obscuration(type: Weather.Phenomenon, amount: Coverage?, height: UInt)
    
    /**
     The type of automated observing station.
     
     - Parameter type: The automated observing station type.
     - Parameter augmented: `true` if a human observer has augmented the report.
     */
    case observationType(_ type: ObservationType, augmented: Bool)
    
    /**
     Precipitation was observed in the vicinity.
     
     - Parameter type: The precipitation type.
     - Parameter proximity: How far away the precipitation was.
     - Parameter directions: The direction(s) the precipitation was observed in.
                             May be blank if proximity is overhead.
     */
    case observedPrecipitation(type: ObservedPrecipitationType, proximity: Proximity?, directions: Set<Direction>)
    
    /**
     Observed visibility at a location.
     
     - Parameter source: The location that the visibility was observed from.
     - Parameter distance: The visibility, in statute miles.
     */
    case observedVisibility(source: VisibilitySource, distance: Ratio)
    
    /**
     Maximum recorded wind speed for the observation period.
     
     - Parameter wind: Peak wind direction and speed.
     - Parameter time: The time that peak wind speed occurred.
     */
    case peakWinds(_ wind: Wind, time: DateComponents)
    
    /**
     Measured ice accretion for a recording period.
     
     - Parameter period: The recording period, in hours (1, 3, or 6).
     - Parameter amount: The amount of ice accretion, in inches.
     */
    case periodicIceAccretionAmount(period: UInt, amount: Float)
    
    /**
     Measured precipitation for a recording period.
     
     - Parameter period: The recording period, in hours (3 or 6).
     - Parameter amount: The amount of precipitation, in inches.
     */
    case periodicPrecipitationAmount(period: UInt, amount: Float?)
    
    /**
     Precipitation beginning and/or ending during the recording period.
     Precipitation could have began or ended multiple times.
     
     - Parameter events: Individual events of precipitation beginning or ending.
     */
    case precipitationBeginEnd(events: Array<PrecipitationEvent>)
    
    /**
     Sea-level pressure trend over the past three hours.
     
     - Parameter character: Whether the pressure was rising or falling during
                            the 3-hour period, and how quickly.
     - Parameter change: The pressure change, in hectopascals.
     */
    case pressureTendency(character: PressureCharacter, change: Float)
    
    /**
     Pressure was rising or falling rapidly.
     
     - Parameter change: Whether the pressure was rising or falling.
     */
    case rapidPressureChange(_ change: RapidPressureChange)
    
    /**
     Snow depth increased by 1+ inches in the past hour.
     
     - Parameter depthIncrease: The snow depth increase, in inches.
     - Parameter totalDepth: The total snow depth, in inches.
     */
    case rapidSnowIncrease(_ depthIncrease: UInt, totalDepth: UInt)
    
    /**
     The relative humidity, derived from temperature and dewpoint.
     
     - Parameter percent: The relative humidity in percent, where 100% is fully
                          saturated air.
     */
    case relativeHumidity(_ percent: UInt)
    
    /**
     The recorded ceiling at a runway departure end.
     
     - Parameter runway: The runway name (e.g., "11" for runway 11).
     - Parameter height: The ceiling height, in feet AGL.
     */
    case runwayCeiling(runway: String, height: UInt)
    
    /**
     The recorded visibility at a runway departure end.
     
     - Parameter runway: The runway name (e.g., "11" for runway 11).
     - Parameter distance: The visibility, in statute miles.
     */
    case runwayVisibility(runway: String, distance: Ratio)
    
    /**
     Recorded sea-level pressure.
     
     - Parameter pressure: Sea-level pressure, in hectopascals.
     */
    case seaLevelPressure(_ pressure: Float?)
    
    /**
     Recorded visibility in a certain direction.
     
     - Parameter direction: The cardinal direction.
     - Parameter distance: The visibility, in statute miles.
     */
    case sectorVisibility(direction: Direction, distance: Ratio)
    
    /**
     A weather sensor is inoperative.
     
     - Parameter type: The inoperative sensor.
     */
    case inoperativeSensor(_ type: SensorType)
    
    /**
     Significant clouds observed in the vicinity.
     
     - Parameter type: The cloud type.
     - Parameter directions: The direction(s) that the clouds are from the
                             observer.
     - Parameter movingDirection: The direction the clouds are moving. `nil` if
                                  the clouds are stationary or direction is
                                  unknown.
     - Parameter distant: `true` if clouds are more than 10 statute miles away.
     - Parameter apparent: `true` if cloud type is not confirmed.
     */
    case significantClouds(type: SignificantCloudType, directions: Set<Direction>, movingDirection: Direction?, distant: Bool, apparent: Bool)
    
    /**
     Highest or lowest temperature recorded in the last six-hour observation
     period.
     
     - Parameter type: Whether this is a high or low extreme.
     - Parameter temperature: Minimum or maximum temperature, in °C.
     */
    case sixHourTemperatureExtreme(type: Extreme, temperature: Float)
    
    /**
     Current recorded snow depth.
     
     - Parameter depth: Snow depth, in inches.
     */
    case snowDepth(_ depth: UInt)
    
    /**
     Total duration of unobscured sunshine for the previous day. Typically
     recorded with the 0800 UTC report or first 6-hourly period report.
     
     - Parameter duration: Total minutes of sunshine during the previous day.
     */
    case sunshineDuration(_ duration: UInt)
    
    /**
     Exact recorded temperature and dewpoint.
     
     - Parameter temperature: Recorded air temperature, in °C.
     - Parameter dewpoint: Recorded dewpoint, in °C.
     */
    case temperatureDewpoint(temperature: Float, dewpoint: Float?)
    
    /**
     Thunderstorms beginning and/or ending during the recording period.
     Thunderstorms could have began or ended multiple times.
     
     - Parameter events: Individual events of thunderstorms beginning or ending.
     */
    case thunderstormBeginEnd(events: Array<ThunderstormEvent>)
    
    /**
     Observed thunderstorms in the vicinity of the station.
     
     - Parameter proximity: The proximity of the thunderstorm(s) to the station.
     - Parameter directions: The direction(s) of the thunderstorm(s) from the
                             station.
     - Parameter movingDirection: The direction the thunderstorm(s) are moving.
                                  `nil` if the storms are stationary or
                                  direction is unknown.
     */
    case thunderstormLocation(proximity: Proximity?, directions: Set<Direction>, movingDirection: Direction?)
    
    /**
     A columnar vortex was observed in the vicinity of the station.
     
     - Parameter type: The type of columnar vortex (e.g., tornado).
     - Parameter begin: The time that the phenomenon began. `nil` if it began
                        before the current observation period.
     - Parameter end: The time that the phenomenon ended. `nil` if it is
                      ongoing.
     - Parameter location: The direction and distance to the phenomenon.
     - Parameter movingDirection: The direction the phenomenon is moving. `nil`
                                  if direction is stationary or unknown.
     */
    case tornadicActivity(type: TornadicActivityType, begin: DateComponents?, end: DateComponents?, location: Location, movingDirection: Direction?)
    
    /**
     Ceiling height varies across the observation area.
     
     - Parameter low: The lowest ceiling height, in feet AGL.
     - Parameter high: The highest ceiling height, in feet AGL.
     */
    case variableCeilingHeight(low: UInt, high: UInt)
    
    /**
     Prevailing visibility varies across the observation area.
     
     - Parameter low: The lowest visibility, in statute miles.
     - Parameter high: The highest visibility, in statute miles.
     */
    case variablePrevailingVisibility(low: Ratio, high: Ratio)
    
    /**
     Cloud coverage varies across the observation area.
     
     - Parameter low: The thinnest cloud coverage.
     - Parameter high: The thickest cloud coverage.
     */
    case variableSkyCondition(low: Coverage, high: Coverage, height: UInt?)
    
    /**
     Wind direction varies during the forecast period. This remark is
     exclusively used in TAFs. Variable winds in a METAR would be encoded in the
     wind group.
     
     - Parameter heading1: A variable wind direction extreme.
     - Parameter heading2: A variable wind direction extreme.
     */
    case variableWindDirection(_ heading1: UInt16, _ heading2: UInt16)
    
    /**
     The equivalent water depth of snow on the ground.
     
     - Parameter depth: The equivalent water depth of fallen snow, in inches.
     */
    case waterEquivalentDepth(_ depth: Float)
    
    /**
     Wind direction/speed will change after a certain time within the forecast
     period. This remark is used exclusively in TAFs.
     
     - Parameter wind: The new wind direction/speed.
     - Parameter after: The time after which the new wind direction/speed takes
                        effect.
     */
    case windChange(wind: Wind, after: DateComponents)
    
    /// Wind data is estimated instead of recorded from an anemometer.
    case windDataEstimated
    
    /**
     The wind has shifted during the observation period.
     
     - Parameter time: The time of the wind shift.
     - Parameter frontalPassage: `true` if the wind shift occurred because of a
                                 frontal passage.
     */
    case windShift(time: DateComponents, frontalPassage: Bool)
    
    /**
     A remark that couldn't be parsed.
     
     - Parameter remark: The raw text remark.
     */
    case unknown(_ remark: String)
    
    public enum Frequency: String, Codable, CaseIterable {
        
        /// For lightning, less than one flash per minute.
        case occasional = "OCNL"
        
        /// For lightning, one to six flashes per minute.
        case frequent = "FRQ"
        
        /// For lightning, more than six flashes per minute.
        case constant = "CONS"
    }
    
    /// A direction and distance.
    public struct Location: Codable, Equatable {
        public let direction: Direction
        public let distance: UInt
    }
    
    /// A proximity from an observation station.
    public enum Proximity: String, Codable, CaseIterable {
        
        /// Within 5 miles of the observer.
        case overhead = "OHD"
        
        /// Between 5 and 10 miles from the observer.
        case vicinity = "VC"
        
        /// Between 10 and 30 miles from the observer.
        case distant = "DSNT"
    }
    
    /// A direction from an observation station.
    public enum Direction: Codable {
        case all
        case north
        case northeast
        case east
        case southeast
        case south
        case southwest
        case west
        case northwest
    }
    
    /// Cloud coverage amounts, as used in remarks.
    public enum Coverage: String, Codable, Equatable, RawRepresentable, CaseIterable {
        
        /// Cloud coverage between 1 and 2 oktas.
        case few = "FEW"
        
        /// Cloud coverage between 3 and 4 oktas.
        case scattered = "SCT"
        
        /// Cloud coverage between 5 and 7 oktas.
        case broken = "BKN"
        
        /// Cloud coverage is 8 oktas.
        case overcast = "OVC"
    }
    
    /// Whether an event began or ended.
    public enum EventType: String, Codable, Equatable, RawRepresentable, CaseIterable {
        case began = "B"
        case ended = "E"
    }
    
    /// How critical a remark is to aviation safety.
    public enum Urgency: Codable, Equatable {
        
        /// Remark could not be parsed.
        case unknown
        
        /// Remark is not critical to aviation safety.
        case routine
        
        /// Remark may be critical to aviation safety.
        case caution
        
        /// Remark is almost certainly critical to aviation safety.
        case urgent
    }
}

/// A remark and its urgency.
public struct RemarkEntry: Codable, Equatable {
    public let remark: Remark
    public let urgency: Remark.Urgency
}
