import Foundation
import Regex

struct WaterEquivalentDepthParser: RemarkParser {
    var urgency = Remark.Urgency.routine
    
    private static let regex = Regex(#"\b933(\d{3})\b"#)
    
    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let result = Self.regex.firstMatch(in: remarks) else { return nil }
        
        guard let depth = UInt(result.captures[0]!) else { return nil }
        
        remarks.removeSubrange(result.range)
        return .waterEquivalentDepth(Float(depth)/10.0)
    }
}
