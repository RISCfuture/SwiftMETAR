import Foundation
import Regex

struct RelativeHumidityParser: RemarkParser {
    var urgency = Remark.Urgency.routine
    
    private static let regex = Regex(#"\bRH\/(\d{1,3})\b"#)
    
    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let result = Self.regex.firstMatch(in: remarks) else { return nil }
        
        guard let humidityStr = result.captures[0] else { return nil }
        guard let humidity = UInt(humidityStr) else { return nil }
        
        remarks.removeSubrange(result.range)
        return .relativeHumidity(humidity)
    }
}
