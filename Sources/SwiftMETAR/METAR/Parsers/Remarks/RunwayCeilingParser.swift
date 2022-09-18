import Foundation
import Regex

struct RunwayCeilingParser: RemarkParser {
    var urgency = Remark.Urgency.routine
    
    private static let regex = Regex(#"\bCIG (\d{3}) RWY(\w{2,3})\b"#)
    
    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let result = Self.regex.firstMatch(in: remarks) else { return nil }
        
        guard let height = UInt(result.captures[0]!) else { return nil }
        let runway = result.captures[1]!
        
        remarks.removeSubrange(result.range)
        return .runwayCeiling(runway: runway, height: height*100)
    }
}
