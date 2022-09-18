import Foundation
import Regex

struct PeriodicIceAccretionAmountParser: RemarkParser {
    var urgency = Remark.Urgency.routine
    
    private static let regex = Regex(#"\bI([136])(\d{3})\b"#)
    
    func parse(remarks: inout String, date: DateComponents) -> Remark? {
        guard let result = Self.regex.firstMatch(in: remarks) else { return nil }
        
        guard let period = UInt(result.captures[0]!) else { return nil }
        guard let amount = UInt(result.captures[1]!) else { return nil }
        
        remarks.removeSubrange(result.range)
        return .periodicIceAccretionAmount(period: period, amount: Float(amount)/100.0)
    }
}
