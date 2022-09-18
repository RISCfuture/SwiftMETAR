import Foundation
import Regex

struct RapidSnowIncreaseParser: RemarkParser {
    var urgency = Remark.Urgency.caution
    
    private static let regex = Regex(#"\bSNINCR (\d+)\/(\d+)\b"#)
    
    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let result = Self.regex.firstMatch(in: remarks) else { return nil }
        
        guard let increase = UInt(result.captures[0]!) else { return nil }
        guard let total = UInt(result.captures[1]!) else { return nil }
        
        remarks.removeSubrange(result.range)
        return .rapidSnowIncrease(increase, totalDepth: total)
    }
}
