import Foundation
import Regex

fileprivate let nocapExtremesRegex = Remark.Extreme.allCases.map { $0.rawValue }.joined(separator: "|")

struct WindChangeParser: RemarkParser {
    var urgency = Remark.Urgency.routine
    
    private static let regex = try! Regex(string: "\\bWND \(noAnchorWindRx) AFT (\\d{2})(\\d{2})\\b")
    
    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let result = Self.regex.firstMatch(in: remarks) else { return nil }
        
        guard let wind = try parseWind(from: result, index: 0),
              let dayStr = result.captures[4],
              let day = UInt(dayStr),
              let hourStr = result.captures[5],
              let hour = UInt(hourStr) else {
            return nil
        }
        guard let after = date.merged(with: .init(day: Int(day), hour: Int(hour))) else {
            return nil
        }
        
        remarks.removeSubrange(result.range)
        return .windChange(wind: wind, after: after)
    }
}
