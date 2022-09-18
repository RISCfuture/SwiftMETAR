import Foundation
import Regex

fileprivate let windRegex = #"(\d{3})(\d{2,3})"#

struct PeakWindsParser: RemarkParser {
    var urgency = Remark.Urgency.routine
    
    private static let regex = try! Regex(string: "\\bPK WND \(windRegex)\\/\(remarkTimeRegex)\\b")
    
    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let result = Self.regex.firstMatch(in: remarks) else { return nil }
        
        guard let wind = parsePeakWind(from: result, index: 0),
              let time = parseDate(from: result, index: 2, base: date) else { return nil }
        
        remarks.removeSubrange(result.range)
        return .peakWinds(wind, time: time)
    }
}

fileprivate func parsePeakWind(from match: MatchResult, index: Int) -> Wind? {
    guard let direction = UInt16(match.captures[index]!),
          let speed = UInt16(match.captures[index+1]!) else { return nil }
    
    return .direction(direction, speed: .knots(speed))
}
