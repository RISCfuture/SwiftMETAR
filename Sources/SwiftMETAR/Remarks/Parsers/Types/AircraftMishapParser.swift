import Foundation
@preconcurrency import RegexBuilder

final class AircraftMishapParser: RemarkParser {
    var urgency = Remark.Urgency.urgent
    
    private static let rx = Regex {
        Anchor.wordBoundary
        "ACFT MSHP"
        Anchor.wordBoundary
    }

    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let match = try Self.rx.firstMatch(in: remarks) else { return nil }

        remarks.removeSubrange(match.range)
        return .aircraftMishap
    }
}
