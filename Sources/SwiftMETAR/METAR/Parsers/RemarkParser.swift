import Foundation
import NumericAnnex
import Regex

let directionFromString: Dictionary<String, Remark.Direction> = [
    "N": .north,
    "NE": .northeast,
    "E": .east,
    "SE": .southeast,
    "S": .south,
    "SW": .southwest,
    "W": .west,
    "NW": .northwest,
    "ALQS": .all,
    "ALQDS": .all
]
fileprivate let directionOrder: Array<Remark.Direction> = [.north, .northeast, .east, .southeast, .south, .southwest, .west, .northwest]

let multiplierFromSignString: Dictionary<String, Int> = [
    "0": 1,
    "1": -1
]
fileprivate let nocapMultiplierSignRegex = multiplierFromSignString.keys.joined(separator: "|")
let multiplierSignRegex = "(\(nocapMultiplierSignRegex))"

let nocapPrecipitationDescriptorRegex = Weather.Descriptor.allCases.map { $0.rawValue }.joined(separator: "|")
let nocapPhenomenonRegex = Weather.Phenomenon.allCases.map { $0.rawValue }.joined(separator: "|")
let precipitationDescriptorRegex = "(\(nocapPrecipitationDescriptorRegex))"
let phenomenonRegex = "(\(nocapPhenomenonRegex))"
let obscurationTypeRegex = phenomenonRegex
fileprivate let nocapCoverageRegex = Remark.Coverage.allCases.map { $0.rawValue }.joined(separator: "|")
let coverageRegex = "(\(nocapCoverageRegex))"
let remarkTimeRegex = #"(\d{2})?(\d{2})"#
let metarWindRegex = #"(\d{3})(\d{2,3})"#
fileprivate let nocapRemarkDirectionRegex = directionFromString.keys.joined(separator: "|")
fileprivate let nocapRemarkProximityRegex = Remark.Proximity.allCases.map { $0.rawValue }.joined(separator: "|")
let remarkProximityRegex = "(\(nocapRemarkProximityRegex))"
fileprivate let nocapRemarkFrequencyRegex = Remark.Frequency.allCases.map { $0.rawValue }.joined(separator: "|")
let remarkFrequencyRegex = "(\(nocapRemarkFrequencyRegex))"
let remarkDirectionRegex = "(\(nocapRemarkDirectionRegex))"
let remarkDirectionsRegex = "(\(nocapRemarkDirectionRegex))(?:(-| THRU | AND )(\(nocapRemarkDirectionRegex)))*"
fileprivate let metarWholeVisRegex = #"(\d+)"#
fileprivate let metarFractionalVisRegex = #"(\d+)/(\d+)"#
fileprivate let metarIrrationalVisRegex = #"(\d+) (\d+)/(\d+)"#
let metarVisibilityRegex = "(?:\(metarIrrationalVisRegex)|\(metarFractionalVisRegex)|\(metarWholeVisRegex))"

protocol RemarkParser {
    var urgency: Remark.Urgency { get }
    
    init()
    func parse(remarks: inout String, date: DateComponents) -> Remark?
}

let remarkParsers: Array<RemarkParser.Type> = [
    ThunderstormBeginEndParser.self,
    
    AircraftMishapParser.self, CloudTypesParser.self, DailyPrecipitationAmountParser.self,
    DailyTemperatureExtremeParser.self, HailstoneSizeParser.self, HourlyPrecipitationAmountParser.self,
    LightningParser.self, NoSPECIParser.self, ObscurationParser.self,
    ObservationTypeParser.self, ObservedPrecipitationParser.self, ObservedVisibilityParser.self,
    PeakWindsParser.self, PeriodicIceAccretionAmountParser.self, PeriodicPrecipitationAmountParser.self,
    PrecipitationBeginEndParser.self, PressureTendencyParser.self, RapidPressureChangeParser.self,
    RapidSnowIncreaseParser.self, RunwayCeilingParser.self, RunwayVisibilityParser.self,
    SeaLevelPressureParser.self, SectorVisibilityParser.self, SensorStatusParser.self,
    SignificantCloudsParser.self, SixHourTemperatureExtremeParser.self, SnowDepthParser.self,
    SunshineDurationParser.self, TemperatureDewpointParser.self,
    ThunderstormLocationParser.self, TornadicActivityParser.self, VariableCeilingHeightParser.self,
    VariablePrevailingVisibilityParser.self, VariableSkyConditionParser.self, WaterEquivalentDepthParser.self,
    WindShiftParser.self, RelativeHumidityParser.self, WindDataEstimatedParser.self,
    LastParser.self, NextParser.self, NoAmendmentsAfterParser.self, NavalForecasterParser.self,
    VariableWindDirectionParser.self,
    
    MaintenanceParser.self, CorrectionParser.self
]

extension RemarkParser {
    func parseDirections(from match: MatchResult, index: Int) -> Set<Remark.Direction>? {
        var directions = Set<Remark.Direction>()
        
        let direction1String = match.captures[index]!
        guard let direction1 = directionFromString[direction1String] else { return nil }
        directions.insert(direction1)
        
        if let span = match.captures[index + 1] {
            guard let direction2String = match.captures[index + 2] else { return nil }
            guard let direction2 = directionFromString[direction2String] else { return nil }
            
            directions.insert(direction2)
            if span != " AND " { // through range
                var rangeIndex = directionOrder.firstIndex(of: direction1)!
                let lastIndex = directionOrder.firstIndex(of: direction2)!
                while rangeIndex != lastIndex {
                    rangeIndex += 1
                    if rangeIndex == directionOrder.count { rangeIndex = 0 }
                    directions.insert(directionOrder[rangeIndex])
                }
            }
        }
        
        return directions
    }
    
    func parseVisibility(from match: MatchResult, index: Int) -> Ratio? {
        if let wholeStr = match.captures[index],
           let numStr = match.captures[index+1],
           let denStr = match.captures[index+2] {
            guard let whole = UInt(wholeStr),
                  let num = UInt(numStr),
                  let den = UInt(denStr) else { return nil }
            return .init(numerator: Int(whole*den+num), denominator: Int(den))
        }
        
        if let numStr = match.captures[index+3],
           let denStr = match.captures[index+4] {
            guard let num = UInt(numStr),
                  let den = UInt(denStr) else { return nil }
            return .init(numerator: Int(num), denominator: Int(den))
        }
        
        if let wholeStr = match.captures[index+5] {
            guard let whole = UInt(wholeStr) else { return nil }
            return .init(numerator: Int(whole), denominator: 1)
        }
        
        return nil
    }
    
    func parseDate(from match: MatchResult, index: Int, base: DateComponents?) -> DateComponents? {
        var hours: Int? = nil
        if let hoursStr = match.captures[index] {
            guard let hr = UInt(hoursStr) else { return nil }
            hours = Int(hr)
        }
        guard let minutes = UInt(match.captures[index+1]!) else { return nil }
        let date = DateComponents(hour: hours, minute: Int(minutes))
        
        if let base = base {
            return base.merged(with: date)
        } else {
            return date
        }
    }
    
    func parseWind(from match: MatchResult, index: Int) -> Wind? {
        guard let direction = UInt16(match.captures[index]!) else { return nil }
        guard let speed = UInt16(match.captures[index+1]!) else { return nil }
        
        return .direction(direction, speed: .knots(speed))
    }
}
