import Foundation
@preconcurrency import RegexBuilder

final class WindDataEstimatedParser: RemarkParser {
    var urgency = Remark.Urgency.routine

    private static let rx = Regex {
        Anchor.wordBoundary
        "WND DATA ESTMD"
        Anchor.wordBoundary
    }
    
    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let result = try Self.rx.firstMatch(in: remarks) else { return nil }

        remarks.removeSubrange(result.range)
        return .windDataEstimated
    }
}
