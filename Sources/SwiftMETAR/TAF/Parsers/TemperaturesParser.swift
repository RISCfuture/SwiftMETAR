import Foundation
import Regex

let temperatureRx = Regex(#"\bT([NX]?)(M?)(\d+)\/(\d{2})(\d{2})Z\b"#)

func parseTemperatures(_ parts: inout Array<String.SubSequence>, date: DateComponents) throws -> Array<TAF.Temperature>? {
    var temps = Array<TAF.Temperature>()
    
    while !parts.isEmpty {
        let tempStr = String(parts[0])
        guard let result = temperatureRx.firstMatch(in: tempStr) else { return nil }
        parts.removeFirst()
        
        guard let extremeStr = result.captures[0],
              let signStr = result.captures[1],
              let valueStr = result.captures[2],
              let absValue = UInt(valueStr),
              let dayStr = result.captures[3],
              let day = UInt8(dayStr),
              let hourStr = result.captures[4],
              let hour = UInt8(hourStr) else { throw Error.invalidForecastTemperature(tempStr) }
        
        let type: TAF.Temperature.TemperatureType?
        switch extremeStr {
            case "N": type = .minimum
            case "X": type = .maximum
            case "": type = nil
            default: throw Error.invalidForecastTemperature(tempStr)
        }
        let value = signStr == "M" ? -Int(absValue) : Int(absValue)
        guard let time = date.merged(with: .init(day: Int(day), hour: Int(hour))) else {
            throw Error.invalidForecastTemperature(tempStr)
        }
        
        temps.append(.init(type: type, value: value, time: time))
    }
    
    return temps
}
