import Foundation
import Regex

struct NoAmendmentsAfterParser: RemarkParser {
    var urgency = Remark.Urgency.routine
    
    private static let regex = Regex(#"\bNO AMDS? AFT (\d{2})(\d{2})\b"#)
    
    func parse(remarks: inout String, date: DateComponents) -> Remark? {
        guard let result = Self.regex.firstMatch(in: remarks) else { return nil }
        
        guard let dayStr = result.captures[0],
              let day = UInt8(dayStr),
              let hourStr = result.captures[1],
              let hour = UInt8(hourStr) else { return nil }
        
        guard let afterDate = date.merged(with: .init(day: Int(day), hour: Int(hour))) else { return nil }
        
        remarks.removeSubrange(result.range)
        return .noAmendmentsAfter(afterDate)
    }
}
