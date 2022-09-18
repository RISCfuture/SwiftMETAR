import Foundation
import Regex

let tempRx = Regex(#"^(M?\d{2})\/(M?\d{2})?$"#)

func parseTempDewpoint(_ parts: inout Array<String.SubSequence>) throws -> (Int8?, Int8?) {
    if parts.isEmpty { return (nil, nil) }
    let tempStr = String(parts[0])
    
    if let match = tempRx.firstMatch(in: tempStr) {
        parts.removeFirst()
        
        guard let tempNumStr = match.captures[0] else { preconditionFailure("No temperature string") }
        let temp = try parseTempDewpointNumber(tempNumStr)
        
        guard let dpStr = match.captures[1] else { return (temp, nil) }
        let dp = try parseTempDewpointNumber(dpStr)
        return (temp, dp)
    }
    
    return (nil, nil)
}

fileprivate func parseTempDewpointNumber(_ string: String) throws -> Int8? {
    if string.isEmpty { return nil }
    
    if string[string.startIndex] == Character("M") {
        guard let value = UInt8(string[string.index(after: string.startIndex)...]) else {
            preconditionFailure("Couldn't parse number")
        }
        return -Int8(value)
    } else {
        guard let value = UInt8(string) else {
            preconditionFailure("Couldn't parse number")
        }
        return Int8(value)
    }
}
