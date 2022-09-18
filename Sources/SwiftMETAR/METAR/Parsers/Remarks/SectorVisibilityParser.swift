import Foundation
import Regex

struct SectorVisibilityParser: RemarkParser {
    var urgency = Remark.Urgency.routine
    
    private static let regex = try! Regex(string: "\\bVIS \(remarkDirectionRegex) \(metarVisibilityRegex)\\b")
    
    func parse(remarks: inout String, date: DateComponents) -> Remark? {
        guard let result = Self.regex.firstMatch(in: remarks) else { return nil }
        
        guard let direction = directionFromString[result.captures[0]!] else { return nil }
        guard let distance = parseVisibility(from: result, index: 1) else { return nil }
        
        remarks.removeSubrange(result.range)
        return .sectorVisibility(direction: direction, distance: distance)
    }
}
