import Foundation
import Regex

struct TemperatureDewpointParser: RemarkParser {
    var urgency = Remark.Urgency.routine
    
    private static let regex = try! Regex(string: "\\bT\(multiplierSignRegex)(\\d{3})(?:\(multiplierSignRegex)(\\d{3})\\b|\\/{4})?")
    
    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let result = Self.regex.firstMatch(in: remarks) else { return nil }
        
        guard let tempMultiplier = multiplierFromSignString[result.captures[0]!],
              let temperature = UInt(result.captures[1]!) else { return nil }
        
        var dewpoint: Float? = nil
        if let dewpointMultStr = result.captures[2],
           let dewpointStr = result.captures[3] {
            guard let dewpointMultiplier = multiplierFromSignString[dewpointMultStr],
                  let dewpointInt = UInt(dewpointStr) else { return nil }
            dewpoint = Float(dewpointInt)/10.0*Float(dewpointMultiplier)
        }
        
        remarks.removeSubrange(result.range)
        return .temperatureDewpoint(temperature: Float(temperature)/10.0*Float(tempMultiplier),
                                    dewpoint: dewpoint)
    }
}
