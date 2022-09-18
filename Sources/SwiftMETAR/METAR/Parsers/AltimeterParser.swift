import Foundation
import Regex

fileprivate let METARAltRx = Regex(#"^([AQ])(\d+)$"#)

func parseMETARAltimeter(_ parts: inout Array<String.SubSequence>) throws -> Altimeter? {
    guard !parts.isEmpty else { return nil }
    
    let altStr = String(parts[0])
    guard let match = METARAltRx.firstMatch(in: altStr) else { return nil }
    parts.removeFirst()
    
    guard let valueStr = match.captures[1],
          let value = UInt16(valueStr) else { throw Error.invalidAltimeter(String(altStr)) }
    
    guard let units = match.captures[0] else { throw Error.invalidAltimeter(String(altStr)) }
    switch units {
        case "A": return .inHg(value)
        case "Q": return .hPa(value)
        default: throw Error.invalidAltimeter(String(altStr))
    }
}

fileprivate let TAFAltRx = Regex(#"^QNH(\d+)(INS|HPA)$"#)

func parseTAFAltimeter(_ parts: inout Array<String.SubSequence>) throws -> Altimeter? {
    guard !parts.isEmpty else { return nil }
    
    let altStr = String(parts[0])
    guard let match = TAFAltRx.firstMatch(in: altStr) else {
        return nil
    }
    parts.removeFirst()
    
    guard let valueStr = match.captures[0],
          let value = UInt16(valueStr) else { throw Error.invalidAltimeter(String(altStr)) }
    
    guard let units = match.captures[1] else { throw Error.invalidAltimeter(String(altStr)) }
    switch units {
        case "INS": return .inHg(value)
        case "HPA": return .hPa(value)
        default: throw Error.invalidAltimeter(String(altStr))
    }
}
