import Foundation
@preconcurrency import RegexBuilder

final class AircraftMishapParser: RemarkParser {
    private static let rx = Regex {
        Anchor.wordBoundary
        "ACFT MSHP"
        Anchor.wordBoundary
    }

    var urgency = Remark.Urgency.urgent

    func parse(remarks: inout String, date _: DateComponents) throws -> Remark? {
        guard let match = try Self.rx.firstMatch(in: remarks) else { return nil }

        remarks.removeSubrange(match.range)
        return .aircraftMishap
    }
}
