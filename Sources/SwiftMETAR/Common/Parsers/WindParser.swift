import Foundation
import Regex

fileprivate let windRx = Regex(#"^(\d{3}|VRB)(\d+)(?:G(\d+))?(KTS?|MPS|KPH)$"#)
fileprivate let variableRx = Regex(#"^(\d+)V(\d+)$"#)

func parseWind(_ parts: inout Array<String.SubSequence>) throws -> Wind? {
    guard !parts.isEmpty else { return nil }
    let dirAndSpeed = String(parts[0])
    
    if dirAndSpeed == "00000KT" {
        parts.removeFirst()
        return .calm
    }
    
    guard let match = windRx.firstMatch(in: dirAndSpeed) else { return nil }
    parts.removeFirst()
    
    guard let speed = try parseSpeed(dirAndSpeed, from: match, index: 1) else {
        throw Error.invalidWinds(String(dirAndSpeed))
    }
    
    guard let dirStr = match.captures[0] else { throw Error.invalidWinds(String(dirAndSpeed)) }
    if dirStr == "VRB" {
        guard let rangeSeq = parts.first else {
            return .variable(speed: speed)
        }
        let range = try parseDirectionRange(&parts, rangeSeq: rangeSeq)
        return .variable(speed: speed, headingRange: range)
    }
    
    guard let heading = UInt16(dirStr) else { throw Error.invalidWinds(String(dirAndSpeed)) }
    
    let gust = try parseSpeed(dirAndSpeed, from: match, index: 2)
    
    guard let rangeSeq = parts.first else {
        return .direction(heading, speed: speed, gust: gust)
    }
    
    if let range = try parseDirectionRange(&parts, rangeSeq: rangeSeq) {
        return .directionRange(heading, headingRange: range, speed: speed, gust: gust)
    } else {
        return .direction(heading, speed: speed, gust: gust)
    }
}

fileprivate func parseDirectionRange(_ parts: inout Array<String.SubSequence>, rangeSeq: String.SubSequence) throws -> (UInt16, UInt16)? {
    let rangeStr = String(rangeSeq)
    
    guard let variableMatch = variableRx.firstMatch(in: rangeStr) else { return nil }
    parts.removeFirst()
    
    guard let dir1Str = variableMatch.captures[0],
          let dir2Str = variableMatch.captures[1],
          let dir1 = UInt16(dir1Str),
          let dir2 = UInt16(dir2Str) else { throw Error.invalidWinds(rangeStr) }
    
    return (dir1, dir2)
}

fileprivate func parseSpeed(_ string: String, from match: MatchResult, index: Int) throws -> Wind.Speed? {
    guard let speedStr = match.captures[index] else { return nil }
    guard let speed = UInt16(speedStr),
          let units = match.captures[3] else { throw Error.invalidWinds(string) }
    
    switch units {
        case "KT", "KTS": return .knots(speed)
        case "KPH": return .kph(speed)
        case "MPS": return .mps(speed)
        default: throw Error.invalidWinds(string)
    }
}
