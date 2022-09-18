import Foundation
import Regex

fileprivate let nocapObservedPrecipRegex = Remark.ObservedPrecipitationType.allCases.map { $0.rawValue }.joined(separator: "|")
fileprivate let observedPrecipRegex = "(\(nocapObservedPrecipRegex))"

struct ObservedPrecipitationParser: RemarkParser {
    var urgency = Remark.Urgency.routine
    
    private static let regex = try! Regex(string: "\\b\(observedPrecipRegex)(?: \(remarkProximityRegex))?(?: \(remarkDirectionsRegex))?\\b")
    
    func parse(remarks: inout String, date: DateComponents) -> Remark? {
        guard let result = Self.regex.firstMatch(in: remarks) else { return nil }
        
        guard let precip = Remark.ObservedPrecipitationType(rawValue: result.captures[0]!) else { return nil }
        
        var proximity: Remark.Proximity? = nil
        if let proximityStr = result.captures[1] {
            guard let prox = Remark.Proximity(rawValue: proximityStr) else { return nil }
            proximity = prox
        }
        
        var directions = Set<Remark.Direction>()
        if result.captures[2] != nil {
            guard let dirs = parseDirections(from: result, index: 2) else { return nil }
            directions = dirs
        }
        
        remarks.removeSubrange(result.range)
        return .observedPrecipitation(type: precip, proximity: proximity, directions: directions)
    }
}
