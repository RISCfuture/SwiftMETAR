import Foundation
import Regex

fileprivate let turbulenceRx = Regex(#"\b5([0-9X])(\d{3})(\d)\b"#)

func parseTurbulence(_ parts: inout Array<String.SubSequence>) throws -> Turbulence? {
    guard !parts.isEmpty else { return nil }
    let turbStr = String(parts[0])
    guard let result = turbulenceRx.firstMatch(in: turbStr) else { return nil }
    parts.removeFirst()
    
    guard let typeStr = result.captures[0],
          let baseStr = result.captures[1],
          let base = UInt(baseStr),
          let depthStr = result.captures[2],
          let depth = UInt(depthStr) else { throw Error.invalidTurbulence(turbStr) }
    
    var intensity = Turbulence.Intensity.none
    var location: Turbulence.Location? = nil
    var frequency: Turbulence.Frequency? = nil
    switch typeStr {
        case "0":
            break
        case "1":
            intensity = .light
        case "2":
            intensity = .moderate
            location = .clearAir
            frequency = .occasional
        case "3":
            intensity = .moderate
            location = .clearAir
            frequency = .frequent
        case "4":
            intensity = .moderate
            location = .inCloud
            frequency = .occasional
        case "5":
            intensity = .moderate
            location = .inCloud
            frequency = .frequent
        case "6":
            intensity = .severe
            location = .clearAir
            frequency = .occasional
        case "7":
            intensity = .severe
            location = .clearAir
            frequency = .frequent
        case "8":
            intensity = .severe
            location = .inCloud
            frequency = .occasional
        case "9":
            intensity = .severe
            location = .inCloud
            frequency = .frequent
        case "X":
            intensity = .extreme
        default:
            throw Error.invalidTurbulence(turbStr)
    }
    
    return Turbulence(location: location, intensity: intensity, frequency: frequency, base: base*100, depth: depth*1000)
}
