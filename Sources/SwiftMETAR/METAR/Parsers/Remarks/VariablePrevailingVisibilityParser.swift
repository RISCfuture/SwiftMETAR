import Foundation
import Regex

struct VariablePrevailingVisibilityParser: RemarkParser {
    var urgency = Remark.Urgency.routine
    
    private static let regex = try! Regex(string: "\\bVIS \(metarVisibilityRegex)V\(metarVisibilityRegex)\\b")
    
    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let result = Self.regex.firstMatch(in: remarks) else { return nil }
        
        guard let low = parseVisibility(from: result, index: 0) else { return nil }
        guard let high = parseVisibility(from: result, index: 6) else { return nil }
        
        remarks.removeSubrange(result.range)
        return .variablePrevailingVisibility(low: low, high: high)
    }
}
