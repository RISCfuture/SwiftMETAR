import Foundation

fileprivate let windRxStr = #"^(\d{3}|VRB)(\d+)(?:G(\d+))?(KTS?|MPS|KPH)$"#
fileprivate let windRx = try! NSRegularExpression(pattern: windRxStr, options: [])

fileprivate let variableRxStr = #"^(\d+)V(\d+)$"#
fileprivate let variableRx = try! NSRegularExpression(pattern: variableRxStr, options: [])

func parseWind(_ parts: inout Array<String.SubSequence>) throws -> Wind? {
    guard !parts.isEmpty else { return nil }
    let dirAndSpeed = String(parts[0])
    
    if dirAndSpeed == "00000KT" {
        parts.removeFirst()
        return .calm
    }
    
    guard let match = windRx.firstMatch(in: dirAndSpeed, options: [], range: dirAndSpeed.nsRange) else {
        return nil
    }
    parts.removeFirst()
    
    guard let speed = try parseSpeed(dirAndSpeed, from: match, index: 2) else {
        preconditionFailure("Coded winds didn't contain speed")
    }
    
    let dirStr = dirAndSpeed.substring(with: match.range(at: 1))
    if dirStr == "VRB" { return .variable(speed: speed) }
    guard let heading = UInt16(dirStr) else {
        throw Error.invalidWinds(String(dirAndSpeed))
    }
    
    let gust = try parseSpeed(dirAndSpeed, from: match, index: 3)
    
    guard let rangeSeq = parts.first else {
        return .direction(heading, speed: speed, gust: gust)
    }
    let rangeStr = String(rangeSeq)
    
    if let variableMatch = variableRx.firstMatch(in: rangeStr, options: [], range: rangeStr.nsRange) {
        parts.removeFirst()
        
        let dir1Str = rangeStr.substring(with: variableMatch.range(at: 1))
        let dir2Str = rangeStr.substring(with: variableMatch.range(at: 2))
        
        guard let dir1 = UInt16(dir1Str) else { throw Error.invalidWinds(rangeStr) }
        guard let dir2 = UInt16(dir2Str) else { throw Error.invalidWinds(rangeStr) }
        
        let range = (dir1, dir2)
        
        return .directionRange(heading, headingRange: range, speed: speed, gust: gust)
    } else {
        return .direction(heading, speed: speed, gust: gust)
    }
}

fileprivate func parseSpeed(_ string: String, from match: NSTextCheckingResult, index: Int) throws -> Wind.Speed? {
    let range = match.range(at: index)
    guard range.location != NSNotFound else { return nil }
    guard let speed = UInt16(string.substring(with: range)) else {
        throw Error.invalidWinds(string)
    }
    let units = string.substring(with: match.range(at: 4))
    
    switch units {
        case "KT", "KTS": return .knots(speed)
        case "KPH": return .kph(speed)
        case "MPS": return .mps(speed)
        default:
            throw Error.invalidWinds(string)
    }
}
