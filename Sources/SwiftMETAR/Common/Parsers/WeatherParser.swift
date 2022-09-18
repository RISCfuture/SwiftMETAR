import Foundation
import Regex

fileprivate let intensities = Weather.Intensity.allCases
    .map { NSRegularExpression.escapedPattern(for: $0.rawValue) }
    .joined(separator: "|")
fileprivate let descriptors = Weather.Descriptor.allCases
    .map { NSRegularExpression.escapedPattern(for: $0.rawValue) }
    .joined(separator: "|")
fileprivate let phenomena = Weather.Phenomenon.allCases
    .map { NSRegularExpression.escapedPattern(for: $0.rawValue) }
    .joined(separator: "|")

fileprivate let weatherRxStr = "^(\(intensities))?(\(descriptors))?((?:\(phenomena))+)$"
fileprivate let weatherRx = try! Regex(string: weatherRxStr)
fileprivate let noRecordedWx = Regex(#"^\/{2,}$"#)

func parseWeather(_ parts: inout Array<String.SubSequence>) throws -> Array<Weather>? {
    var weather = Array<Weather>()
    
    while true {
        if parts.isEmpty { return weather }
        let weatherStr = String(parts[0])
        
        if weatherStr == "M" {
            parts.removeFirst()
            return nil
        }
        if weatherStr == "NSW" {
            parts.removeFirst()
            return []
        }
        if weatherStr == "VCSH" { // not technically correct but sometimes coded
            weather.append(.init(intensity: .vicinity, descriptor: .showering, phenomena: [.rain]))
            parts.removeFirst()
            continue
        }
        if noRecordedWx.firstMatch(in: weatherStr) != nil {
            parts.removeFirst()
            return []
        }
        
        if let match = weatherRx.firstMatch(in: weatherStr) {
            parts.removeFirst()
            
            guard let intensityStr = match.captures[0],
                  let intensity = Weather.Intensity(rawValue: intensityStr) else {
                throw Error.invalidWeather(weatherStr)
            }
            
            var descriptor: Weather.Descriptor? = nil
            if let descriptorStr = match.captures[1] {
                guard let desc = Weather.Descriptor(rawValue: descriptorStr) else { throw Error.invalidWeather(weatherStr) }
                descriptor = desc
            }
            
            guard let phenomenaStr = match.captures[2]?.partition(by: 2) else { throw Error.invalidWeather(weatherStr) }
            let phenomena = try phenomenaStr.map { code -> Weather.Phenomenon in
                guard let phenomenon = Weather.Phenomenon(rawValue: code) else {
                    throw Error.invalidWeather(weatherStr)
                }
                return phenomenon
            }
            
            weather.append(Weather(intensity: intensity, descriptor: descriptor, phenomena: Set(phenomena)))
        } else {
            return weather
        }
    }
}
