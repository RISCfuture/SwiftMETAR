import Foundation
@preconcurrency import RegexBuilder

final class NoSPECIParser: RemarkParser {
    private static let rx = Regex {
        Anchor.wordBoundary
        "NOSPECI"
        Anchor.wordBoundary
    }

    var urgency = Remark.Urgency.routine

    func parse(remarks: inout String, date _: DateComponents) throws -> Remark? {
        guard let result = try Self.rx.firstMatch(in: remarks) else { return nil }

        remarks.removeSubrange(result.range)
        return .noSPECI
    }
}
