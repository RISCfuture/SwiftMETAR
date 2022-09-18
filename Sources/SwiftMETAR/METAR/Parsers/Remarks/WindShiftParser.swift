import Foundation
import Regex

struct WindShiftParser: RemarkParser {
    var urgency = Remark.Urgency.caution
    
    private static let regex = try! Regex(string: "\\bWSHFT \(remarkTimeRegex)(?: (FROPA))?\\b")
    
    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let result = Self.regex.firstMatch(in: remarks) else { return nil }
        
        guard let date = parseDate(from: result, index: 0, base: date) else { return nil }
        let frontalPassage = result.captures[2] != nil
        
        remarks.removeSubrange(result.range)
        return .windShift(time: date, frontalPassage: frontalPassage)
    }
}
