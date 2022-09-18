import Foundation

struct MaintenanceParser: RemarkParser {
    var urgency = Remark.Urgency.routine
    
    private static let regex = #"(\s+\$\s+|\s+\$\s*$)"#
    
    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let range = remarks.range(of: Self.regex, options: .regularExpression) else { return nil }
        
        remarks.removeSubrange(range)
        return .maintenance
    }
}
