import Foundation
import Regex

struct SnowDepthParser: RemarkParser {
    var urgency = Remark.Urgency.routine
    
    private static let regex = Regex(#"\b4\/(\d{3})\b"#)
    
    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let result = Self.regex.firstMatch(in: remarks) else { return nil }
        
        guard let depth = UInt(result.captures[0]!) else { return nil }
        
        remarks.removeSubrange(result.range)
        return .snowDepth(depth)
    }
}
