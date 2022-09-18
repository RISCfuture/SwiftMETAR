import Foundation
import Regex

struct ObservationTypeParser: RemarkParser {
    var urgency = Remark.Urgency.routine
    
    private static let regex = Regex(#"\b(A[O0]\d)(A?)\b"#)
    
    func parse(remarks: inout String, date: DateComponents) -> Remark? {
        guard let result = Self.regex.firstMatch(in: remarks) else { return nil }
        
        guard let type = Remark.ObservationType.from(raw: result.captures[0]!) else { return nil }
        let augmented = result.captures[1] == "A"
        
        remarks.removeSubrange(result.range)
        return .observationType(type, augmented: augmented)
    }
}

extension Remark.ObservationType {
    static func from(raw: String) -> Self? {
        switch raw {
            case "A01": return .init(rawValue: "AO1")
            case "A02": return .init(rawValue: "AO2")
            case "A02A": return .init(rawValue: "AO2A")
            default: return .init(rawValue: raw)
        }
    }
}
