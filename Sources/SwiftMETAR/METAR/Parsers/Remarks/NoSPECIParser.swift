import Foundation

struct NoSPECIParser: RemarkParser {
    var urgency = Remark.Urgency.routine
    
    private static let regex = #"\bNOSPECI\b"#
    
    func parse(remarks: inout String, date: DateComponents) -> Remark? {
        guard let range = remarks.range(of: Self.regex, options: .regularExpression) else { return nil }
        
        remarks.removeSubrange(range)
        return .noSPECI
    }
}
