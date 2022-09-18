import Foundation
import Regex

struct ThunderstormLocationParser: RemarkParser {
    var urgency = Remark.Urgency.urgent
    
    private static let regex = try! Regex(string: "\\bTS(?: \(remarkProximityRegex))?(?:[ \\-]\(remarkDirectionsRegex))?(?: MOVG? \(remarkDirectionRegex))?\\b")
    
    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let result = Self.regex.firstMatch(in: remarks) else { return nil }
        
        var proximity: Remark.Proximity? = nil
        if let proxStr = result.captures[0] {
            guard let prox = Remark.Proximity(rawValue: proxStr) else { return nil }
            proximity = prox
        }
        
        var directions = Set<Remark.Direction>()
        if result.captures[1] != nil {
            guard let dirs = parseDirections(from: result, index: 1) else { return nil }
            directions = dirs
        }
        
        var movingDirection: Remark.Direction? = nil
        if let dirStr = result.captures[4] {
            guard let dir = directionFromString[dirStr] else { return nil }
            movingDirection = dir
        }
        
        remarks.removeSubrange(result.range)
        return .thunderstormLocation(proximity: proximity,
                                     directions: directions,
                                     movingDirection: movingDirection)
    }
}
