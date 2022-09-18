import Foundation
import Regex

struct ObscurationParser: RemarkParser {
    var urgency = Remark.Urgency.routine
    
    private static let regex = try! Regex(string: "\\b\(obscurationTypeRegex) \(coverageRegex)?(\\d{3})\\b")
    
    func parse(remarks: inout String, date: DateComponents) -> Remark? {
        guard let result = Self.regex.firstMatch(in: remarks) else { return nil }
        
        guard let type = Weather.Phenomenon(rawValue: result.captures[0]!) else { return nil }
        
        var coverage: Remark.Coverage? = nil
        if let coverageStr = result.captures[1] {
            guard let cov = Remark.Coverage(rawValue: coverageStr) else { return nil }
            coverage = cov
        }
        
        guard let height = UInt(result.captures[2]!) else { return nil }
        
        remarks.removeSubrange(result.range)
        return .obscuration(type: type, amount: coverage, height: height*100)
    }
}
