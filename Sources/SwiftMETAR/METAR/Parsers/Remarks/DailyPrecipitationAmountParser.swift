import Foundation
import Regex

struct DailyPrecipitationAmountParser: RemarkParser {
    var urgency = Remark.Urgency.routine
    
    private static let regex = Regex(#"\b7(?:(\d{4})\b|(\/{4}))"#)
    
    func parse(remarks: inout String, date: DateComponents) -> Remark? {
        guard let result = Self.regex.firstMatch(in: remarks) else { return nil }
        
        var amount: Float? = nil
        if let numStr = result.captures[0] {
            guard let num = UInt(numStr) else { return nil }
            amount = Float(num)/100.0
        }
        
        remarks.removeSubrange(result.range)
        return .dailyPrecipitationAmount(amount)
    }
}
