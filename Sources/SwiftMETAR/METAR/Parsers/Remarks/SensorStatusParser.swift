import Foundation
import Regex

fileprivate enum Sensor: String, RawRepresentable, CaseIterable {
    case RVR = "RVRNO"
    case presentWeather = "PWINO"
    case rain = "PNO"
    case freezingRain = "FZRANO"
    case lightning = "TSNO"
}

fileprivate enum SecondarySensor: String, RawRepresentable, CaseIterable {
    case visibility = "VISNO"
    case ceiling = "CHINO"
}

fileprivate let nocapSensorRegex = Sensor.allCases.map { $0.rawValue }.joined(separator: "|")
fileprivate let nocapSecondarySensorRegex = SecondarySensor.allCases.map { "\($0.rawValue) [A-Z0-9]+" }.joined(separator: "|")
fileprivate let nocapAllSensorRegex = "\(nocapSensorRegex)|\(nocapSecondarySensorRegex)"

struct SensorStatusParser: RemarkParser {
    var urgency = Remark.Urgency.caution
    
    private static let regex = try! Regex(string: "\\b(\(nocapAllSensorRegex))\\b")
    
    func parse(remarks: inout String, date: DateComponents) -> Remark? {
        guard let result = Self.regex.firstMatch(in: remarks) else { return nil }
        
        let type: Remark.SensorType
        let parts = result.matchedString.split(separator: " ")
        let sensorStr = String(parts[0])
        if let sensor = Sensor(rawValue: sensorStr) {
            switch sensor {
                case .RVR: type = .RVR
                case .presentWeather: type = .presentWeather
                case .rain: type = .rain
                case .freezingRain: type = .freezingRain
                case .lightning: type = .lightning
            }
        } else if let sensor = SecondarySensor(rawValue: sensorStr) {
            guard parts.count == 2 else { return nil }
            switch sensor {
                case .visibility: type = .secondaryVisibility(location: String(parts[1]))
                case .ceiling: type = .secondaryCeiling(location: String(parts[1]))
            }
        } else {
            return nil
        }
        
        remarks.removeSubrange(result.range)
        return .inoperativeSensor(type)
    }
}
