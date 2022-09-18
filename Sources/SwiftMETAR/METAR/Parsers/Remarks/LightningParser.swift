import Foundation
import Regex

fileprivate let lightningTypesRegex = Remark.LightningType.allCases.map { $0.rawValue }.joined(separator: "|")

struct LightningParser: RemarkParser {
    var urgency = Remark.Urgency.urgent
    
    private static let regex = try! Regex(string: "\\b(?:\(remarkFrequencyRegex) )?LTG((?:\(lightningTypesRegex))*)(?: \(remarkProximityRegex))?(?: \(remarkDirectionsRegex))?\\b")
    
    func parse(remarks: inout String, date: DateComponents) -> Remark? {
        guard let result = Self.regex.firstMatch(in: remarks) else { return nil }
        
        var frequency: Remark.Frequency? = nil
        if let freqStr = result.captures[0] {
            frequency = Remark.Frequency(rawValue: freqStr)
        }
        
        var types = Set<Remark.LightningType>()
        if let typesStr = result.captures[1] {
            for typeStr in typesStr.partition(by: 2) {
                guard let type = Remark.LightningType(rawValue: typeStr) else { return nil }
                types.insert(type)
            }
        }
        
        var proximity: Remark.Proximity? = nil
        if let proxStr = result.captures[2] {
            proximity = Remark.Proximity(rawValue: proxStr)
        }
        
        var directions = Set<Remark.Direction>()
        if result.captures[3] != nil {
            directions = parseDirections(from: result, index: 3) ?? Set<Remark.Direction>()
        }
        
        remarks.removeSubrange(result.range)
        return .lightning(frequency: frequency, types: types, proximity: proximity, directions: directions)
    }
}
