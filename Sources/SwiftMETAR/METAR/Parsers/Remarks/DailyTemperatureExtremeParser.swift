import Foundation
import Regex

struct DailyTemperatureExtremeParser: RemarkParser {
    var urgency = Remark.Urgency.routine
    
    private static let regex = try! Regex(string: "\\b4\(multiplierSignRegex)(\\d{3})\(multiplierSignRegex)(\\d{3})\\b")
    
    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let result = Self.regex.firstMatch(in: remarks) else { return nil }
        
        guard let highMultiplier = multiplierFromSignString[result.captures[0]!] else { return nil }
        guard let highNum = UInt(result.captures[1]!) else { return nil }
        let high: Float = Float(highNum)/10.0*Float(highMultiplier)
        
        guard let lowMultiplier = multiplierFromSignString[result.captures[2]!] else { return nil }
        guard let lowNum = UInt(result.captures[3]!) else { return nil }
        let low: Float = Float(lowNum)/10.0*Float(lowMultiplier)
        
        remarks.removeSubrange(result.range)
        return .dailyTemperatureExtremes(low: low, high: high)
    }
}
