import Foundation
import Regex

struct HourlyPrecipitationAmountParser: RemarkParser {
    var urgency = Remark.Urgency.routine
    
    private static let regex = Regex(#"\bP(\d{4})\b"#)
    
    func parse(remarks: inout String, date: DateComponents) -> Remark? {
        guard let result = Self.regex.firstMatch(in: remarks) else { return nil }
        
        guard let amount = UInt(result.captures[0]!) else { return nil }
        
        remarks.removeSubrange(result.range)
        return .hourlyPrecipitationAmount(Float(amount)/100.0)
    }
}
