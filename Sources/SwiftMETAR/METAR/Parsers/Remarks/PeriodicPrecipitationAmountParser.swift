import Foundation
import Regex

fileprivate let indeterminate = "////"

struct PeriodicPrecipitationAmountParser: RemarkParser {
    var urgency = Remark.Urgency.routine
    
    private static let regex = Regex(#"\b6(\d{4}\b|\/{4})"#)
    
    func parse(remarks: inout String, date: DateComponents) -> Remark? {
        guard let result = Self.regex.firstMatch(in: remarks) else { return nil }
        
        let period: UInt
        switch date.hour {
            case 0, 6, 12, 18: period = 6
            case 23, 5, 11, 17: period = 6
            case 3, 9, 15, 21: period = 3
            case 2, 8, 14, 20: period = 3
            default: return nil
        }
        
        if result.captures[0] == indeterminate {
            remarks.removeSubrange(result.range)
            return .periodicPrecipitationAmount(period: period, amount: nil)
        }
        
        guard let amountStr = result.captures[0] else { return nil }
        guard let amount = UInt(amountStr) else { return nil }
        
        remarks.removeSubrange(result.range)
        return .periodicPrecipitationAmount(period: period, amount: Float(amount)/100.0)
    }
}
