import Foundation
import Regex

struct VariableCeilingHeightParser: RemarkParser {
    var urgency = Remark.Urgency.routine
    
    private static let regex = Regex(#"\bCIG (\d{3})V(\d{3})\b"#)
    
    func parse(remarks: inout String, date: DateComponents) -> Remark? {
        guard let result = Self.regex.firstMatch(in: remarks) else { return nil }
        
        guard let low = UInt(result.captures[0]!) else { return nil }
        guard let high = UInt(result.captures[1]!) else { return nil }
        
        remarks.removeSubrange(result.range)
        return .variableCeilingHeight(low: low*100, high: high*100)
    }
}
