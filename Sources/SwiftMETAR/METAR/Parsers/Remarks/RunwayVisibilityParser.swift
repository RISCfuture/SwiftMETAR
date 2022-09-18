import Foundation
import Regex

struct RunwayVisibilityParser: RemarkParser {
    var urgency = Remark.Urgency.routine
    
    private static let regex = try! Regex(string: "\\bVIS \(metarVisibilityRegex) RWY(\\w{2,3})\\b")
    
    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let result = Self.regex.firstMatch(in: remarks) else { return nil }
        
        guard let distance = parseVisibility(from: result, index: 0) else { return nil }
        let runway = result.captures[6]!
        
        remarks.removeSubrange(result.range)
        return .runwayVisibility(runway: runway, distance: distance)
    }
}
