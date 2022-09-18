import Foundation
import Regex

struct PeakWindsParser: RemarkParser {
    var urgency = Remark.Urgency.routine
    
    private static let regex = try! Regex(string: "\\bPK WND \(metarWindRegex)\\/\(remarkTimeRegex)\\b")
    
    func parse(remarks: inout String, date: DateComponents) -> Remark? {
        guard let result = Self.regex.firstMatch(in: remarks) else { return nil }
        
        guard let wind = parseWind(from: result, index: 0) else { return nil }
        guard let time = parseDate(from: result, index: 2, base: date) else { return nil }
        
        remarks.removeSubrange(result.range)
        return .peakWinds(wind, time: time)
    }
}
