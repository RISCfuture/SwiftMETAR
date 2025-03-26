import Foundation
@preconcurrency import RegexBuilder

final class RunwayCeilingParser: RemarkParser {
    var urgency = Remark.Urgency.routine

    private let heightRef = Reference<UInt>()
    private let runwayRef = Reference<Substring>()

    private lazy var rx = Regex {
        Anchor.wordBoundary
        "CIG "
        Capture(as: heightRef) { Repeat(.digit, count: 3) } transform: { .init($0)! * 100 }
        " RWY"
        Capture(as: runwayRef) { Repeat(.word, 2...3) }
        Anchor.wordBoundary
    }

    func parse(remarks: inout String, date _: DateComponents) throws -> Remark? {
        guard let result = try rx.firstMatch(in: remarks) else { return nil }
        let height = result[heightRef], runway = result[runwayRef]

        remarks.removeSubrange(result.range)
        return .runwayCeiling(runway: String(runway), height: height)
    }
}
