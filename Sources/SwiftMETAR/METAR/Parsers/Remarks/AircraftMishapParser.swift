import Foundation

struct AircraftMishapParser: RemarkParser {
    var urgency = Remark.Urgency.urgent
    
    private static let regex = #"\bACFT MSHP\b"#
    
    func parse(remarks: inout String, date: DateComponents) -> Remark? {
        guard let range = remarks.range(of: Self.regex, options: .regularExpression) else { return nil }
        
        remarks.removeSubrange(range)
        return .aircraftMishap
    }
}
