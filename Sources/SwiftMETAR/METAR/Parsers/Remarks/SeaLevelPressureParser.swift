import Foundation
import Regex

fileprivate let noSLP = "NO"

struct SeaLevelPressureParser: RemarkParser {
    var urgency = Remark.Urgency.routine
    
    private static let regex = Regex(#"\bSLP(\d{3}|NO)\b"#)
    
    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let result = Self.regex.firstMatch(in: remarks) else { return nil }
        
        var pressure: Float? = nil
        if result.captures[0] != noSLP {
            guard let pressureInt = UInt(result.captures[0]!) else { return nil }
            pressure = Float(pressureInt)/10.0 + 900
        }
        
        remarks.removeSubrange(result.range)
        return .seaLevelPressure(pressure)
    }
}
