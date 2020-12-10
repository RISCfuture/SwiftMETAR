import Foundation

let tempRxString = #"^(M?\d{2})\/(M?\d{2})?$"#
let tempRx = try! NSRegularExpression(pattern: tempRxString, options: [])

func parseTempDewpoint(_ parts: inout Array<String.SubSequence>) throws -> (Int8?, Int8?) {
    if parts.isEmpty { return (nil, nil) }
    let tempStr = String(parts[0])
    
    if let match = tempRx.firstMatch(in: tempStr, options: [], range: tempStr.nsRange) {
        parts.removeFirst()
        let temp = try parseTempDewpointNumber(tempStr.substring(with: match.range(at: 1)))
        
        let dpRange = match.range(at: 2)
        if dpRange.location == NSNotFound {
            return (temp, nil)
        } else {
            let dp = try parseTempDewpointNumber(tempStr.substring(with: dpRange))
            return (temp, dp)
        }
    }
    
    return (nil, nil)
}

fileprivate func parseTempDewpointNumber(_ string: String.SubSequence) throws -> Int8? {
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
