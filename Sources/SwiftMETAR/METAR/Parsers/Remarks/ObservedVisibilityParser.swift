import Foundation
import Regex

fileprivate let nocapVisSourceRegex = Remark.VisibilitySource.allCases.map { $0.rawValue }.joined(separator: "|")
fileprivate let visSourceRegex = "(\(nocapVisSourceRegex))"

struct ObservedVisibilityParser: RemarkParser {
    var urgency = Remark.Urgency.routine
    
    private static let regex = try! Regex(string: "\\b\(visSourceRegex) VIS \(metarVisibilityRegex)\\b")
    
    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let result = Self.regex.firstMatch(in: remarks) else { return nil }
        
        guard let source = Remark.VisibilitySource(rawValue: result.captures[0]!) else { return nil }
        guard let distance = parseVisibility(from: result, index: 1) else { return nil }
        
        remarks.removeSubrange(result.range)
        return .observedVisibility(source: source, distance: distance)
    }
}
