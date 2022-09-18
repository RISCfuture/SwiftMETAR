import Foundation
import Regex

struct VariableSkyConditionParser: RemarkParser {
    var urgency = Remark.Urgency.routine
    
    private static let regex = try! Regex(string: "\\b\(coverageRegex)(\\d{3})? V \(coverageRegex)\\b")
    
    func parse(remarks: inout String, date: DateComponents) -> Remark? {
        guard let result = Self.regex.firstMatch(in: remarks) else { return nil }
        
        guard let coverage1 = Remark.Coverage(rawValue: result.captures[0]!) else { return nil }
        guard let coverage2 = Remark.Coverage(rawValue: result.captures[2]!) else { return nil }
        
        var height: UInt? = nil
        if let heightStr = result.captures[1] {
            guard let h = UInt(heightStr) else { return nil }
            height = h*100
        }
        
        remarks.removeSubrange(result.range)
        return .variableSkyCondition(low: coverage1, high: coverage2, height: height)
    }
}
