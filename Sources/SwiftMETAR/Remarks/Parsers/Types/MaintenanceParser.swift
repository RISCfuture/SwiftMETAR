import Foundation
@preconcurrency import RegexBuilder

final class MaintenanceParser: RemarkParser {
    var urgency = Remark.Urgency.routine

    private static let rx = Regex {
        ChoiceOf {
            Regex {
                OneOrMore(.whitespace)
                "$"
                OneOrMore(.whitespace)
            }
            Regex {
                OneOrMore(.whitespace)
                "$"
                ZeroOrMore(.whitespace)
                Anchor.endOfSubject
            }
        }
    }
    
    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let result = try Self.rx.firstMatch(in: remarks) else { return nil }
        
        remarks.removeSubrange(result.range)
        return .maintenance
    }
}
