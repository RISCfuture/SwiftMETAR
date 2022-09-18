import Foundation
import Regex

struct HailstoneSizeParser: RemarkParser {
    var urgency = Remark.Urgency.urgent
    
    private static let regex = try! Regex(string: "\\bGR \(metarVisibilityRegex)\\b")
    
    func parse(remarks: inout String, date: DateComponents) -> Remark? {
        guard let result = Self.regex.firstMatch(in: remarks) else { return nil }
        
        guard let size = parseVisibility(from: result, index: 0) else { return nil }
        remarks.removeSubrange(result.range)
        return .hailstoneSize(size)
    }
}
