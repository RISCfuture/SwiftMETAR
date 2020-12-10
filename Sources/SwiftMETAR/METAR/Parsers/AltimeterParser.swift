import Foundation

fileprivate let METARAltRxStr = #"^([AQ])(\d+)$"#
fileprivate let METARAltRx = try! NSRegularExpression(pattern: METARAltRxStr, options: [])

func parseMETARAltimeter(_ parts: inout Array<String.SubSequence>) throws -> Altimeter? {
    guard !parts.isEmpty else { return nil }
    
    let altStr = String(parts[0])
    guard let match = METARAltRx.firstMatch(in: altStr, options: [], range: altStr.nsRange) else {
        return nil
    }
    parts.removeFirst()
    
    guard let value = UInt16(altStr.substring(with: match.range(at: 2))) else {
        throw Error.invalidAltimeter(String(altStr))
    }
    
    switch altStr.substring(with: match.range(at: 1)) {
        case "A": return .inHg(value)
        case "Q": return .hPa(value)
        default: throw Error.invalidAltimeter(String(altStr))
    }
}

fileprivate let TAFAltRxStr = #"^QNH(\d+)(INS|HPA)$"#
fileprivate let TAFAltRx = try! NSRegularExpression(pattern: TAFAltRxStr, options: [])

func parseTAFAltimeter(_ parts: inout Array<String.SubSequence>) throws -> Altimeter? {
    guard !parts.isEmpty else { return nil }
    
    let altStr = String(parts[0])
    guard let match = TAFAltRx.firstMatch(in: altStr, options: [], range: altStr.nsRange) else {
        return nil
    }
    parts.removeFirst()
    
    guard let value = UInt16(altStr.substring(with: match.range(at: 1))) else {
        throw Error.invalidAltimeter(String(altStr))
    }
    
    switch altStr.substring(with: match.range(at: 2)) {
        case "INS": return .inHg(value)
        case "HPA": return .hPa(value)
        default: throw Error.invalidAltimeter(String(altStr))
    }
}
