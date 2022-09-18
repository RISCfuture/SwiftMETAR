import Foundation
import Regex

struct VariableWindDirectionParser: RemarkParser {
    var urgency = Remark.Urgency.routine
    
    private static let regex = Regex(#"WND (\d{3})V(\d{3})"#)
    
    func parse(remarks: inout String, date: DateComponents) -> Remark? {
        guard let result = Self.regex.firstMatch(in: remarks) else { return nil }
        
        guard let dir1Str = result.captures[0],
              let dir2Str = result.captures[1],
              let dir1 = UInt16(dir1Str),
              let dir2 = UInt16(dir2Str) else { return nil }
        
        remarks.removeSubrange(result.range)
        return .variableWindDirection(dir1, dir2)
    }
}
