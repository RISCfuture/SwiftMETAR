import Foundation
import Regex

struct SunshineDurationParser: RemarkParser {
    var urgency = Remark.Urgency.routine
    
    private static let regex = Regex(#"\b98(\d{3})\b"#)
    
    func parse(remarks: inout String, date: DateComponents) -> Remark? {
        guard let result = Self.regex.firstMatch(in: remarks) else { return nil }
        
        guard let duration = UInt(result.captures[0]!) else { return nil }
        
        remarks.removeSubrange(result.range)
        return .sunshineDuration(duration)
    }
}
