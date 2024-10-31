import Foundation
@preconcurrency import RegexBuilder

final class VicinityPrecipitationParser: RemarkParser {
    var urgency = Remark.Urgency.routine

    private let precipRef = Reference<Remark.ObservedPrecipitationType>()

    private lazy var rx = Regex {
        Anchor.wordBoundary
        "VC"
        Capture(as: precipRef) {
            try! Remark.ObservedPrecipitationType.rx
        } transform: { .init(rawValue: String($0))! }
        Anchor.wordBoundary
    }

    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let result = try rx.firstMatch(in: remarks) else { return nil }

        let precip = result[precipRef]

        remarks.removeSubrange(result.range)
        return .observedPrecipitation(type: precip, proximity: .vicinity, directions: Set())
    }
}