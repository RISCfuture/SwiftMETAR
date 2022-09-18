import Foundation
import Regex

struct CloudTypesParser: RemarkParser {
    var urgency = Remark.Urgency.routine
    
    private static let regex = Regex(#"\b8\/(\d)(\d|\/)(\d|\/)"#)
    
    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let result = Self.regex.firstMatch(in: remarks) else { return nil }
        
        guard let lowStr = result.captures[0],
              let low = Remark.LowCloudType(rawValue: lowStr) else { return nil }
        guard let midStr = result.captures[1],
              let mid = Remark.MiddleCloudType(rawValue: midStr) else { return nil }
        guard let highStr = result.captures[2],
              let high = Remark.HighCloudType(rawValue: highStr) else { return nil }
        
        remarks.removeSubrange(result.range)
            return .cloudTypes(low: low, middle: mid, high: high)
    }
}
