import Foundation
import Regex

struct CorrectionParser: RemarkParser {
    var urgency = Remark.Urgency.routine
    
    private static let regex = Regex(#"\bCOR (\d{2})(\d{2})\b"#)
    
    func parse(remarks: inout String, date: DateComponents) -> Remark? {
        guard let result = Self.regex.firstMatch(in: remarks) else { return nil }
        
        guard let hourStr = result.captures[0],
              let hour = UInt8(hourStr),
              let minuteStr = result.captures[1],
              let minute = UInt8(minuteStr) else { return nil }
        
        guard let afterDate = date.merged(with: .init(hour: Int(hour), minute: Int(minute))) else { return nil }
        
        remarks.removeSubrange(result.range)
        return .correction(time: afterDate)
    }
}
