import Foundation
import Regex

fileprivate let nocapExtremesRegex = Remark.Extreme.allCases.map { $0.rawValue }.joined(separator: "|")

struct SixHourTemperatureExtremeParser: RemarkParser {
    var urgency = Remark.Urgency.routine
    
    private static let regex = try! Regex(string: "\\b(\(nocapExtremesRegex))\(multiplierSignRegex)(\\d{3})\\b")
    
    func parse(remarks: inout String, date: DateComponents) -> Remark? {
        guard let result = Self.regex.firstMatch(in: remarks) else { return nil }
        
        guard let type = Remark.Extreme(rawValue: result.captures[0]!) else { return nil }
        guard let multiplier = multiplierFromSignString[result.captures[1]!] else { return nil }
        guard let temperature = UInt(result.captures[2]!) else { return nil }
        
        remarks.removeSubrange(result.range)
        return .sixHourTemperatureExtreme(type: type, temperature: Float(temperature)/10.0*Float(multiplier))
    }
}
