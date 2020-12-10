import Foundation

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
fileprivate let weatherRx = try! NSRegularExpression(pattern: weatherRxStr, options: [])
fileprivate let noRecordedWxStr = #"^\/{2,}$"#
fileprivate let noRecordedWx = try! NSRegularExpression(pattern: noRecordedWxStr, options: [])

func parseWeather(_ parts: inout Array<String.SubSequence>) throws -> Array<Weather> {
    var weather = Array<Weather>()
    
    while true {
        if parts.isEmpty { return weather }
        let weatherStr = String(parts[0])
        
        if weatherStr == "NSW" {
            parts.removeFirst()
            return []
        }
        if weatherStr == "VCSH" { // not technically correct but sometimes coded
            weather.append(.init(intensity: .vicinity, descriptor: .showering, phenomena: [.rain]))
            parts.removeFirst()
            continue
        }
        if noRecordedWx.firstMatch(in: weatherStr, options: [], range: weatherStr.nsRange) != nil {
            parts.removeFirst()
            return []
        }
        
        if let match = weatherRx.firstMatch(in: weatherStr, options: [], range: weatherStr.nsRange) {
            parts.removeFirst()
            
            let intensityStr = String(weatherStr.substring(with: match.range(at: 1)))
            guard let intensity = Weather.Intensity(rawValue: intensityStr) else {
                throw Error.invalidWeather(weatherStr)
            }
            
            let descriptorRange = match.range(at: 2)
            var descriptor: Weather.Descriptor? = nil
            if descriptorRange.location != NSNotFound {
                let descriptorStr = String(weatherStr.substring(with: descriptorRange))
                descriptor = Weather.Descriptor(rawValue: descriptorStr)
                guard descriptor != nil else { throw Error.invalidWeather(weatherStr) }
            }
            
            let phenomenaStr = String(weatherStr.substring(with: match.range(at: 3))).partition(by: 2)
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
