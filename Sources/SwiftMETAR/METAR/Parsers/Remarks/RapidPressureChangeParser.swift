import Foundation
import Regex

fileprivate let nocapRapidPressureChangeRx = Remark.RapidPressureChange.allCases.map { $0.rawValue }.joined(separator: "|")

struct RapidPressureChangeParser: RemarkParser {
    var urgency = Remark.Urgency.caution
    
    private static let regex = try! Regex(string: "\(nocapRapidPressureChangeRx)\\b")
    
    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let result = Self.regex.firstMatch(in: remarks) else { return nil }
        
        guard let change = Remark.RapidPressureChange(rawValue: result.matchedString) else { return nil }
        
        remarks.removeSubrange(result.range)
        return .rapidPressureChange(change)
    }
}
