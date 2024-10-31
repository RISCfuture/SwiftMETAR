import Foundation
@preconcurrency import RegexBuilder

final class ObservedVisibilityParser: RemarkParser {
    var urgency = Remark.Urgency.routine

    private let sourceRef = Reference<Remark.VisibilitySource>()
    private let visibilityParser = FractionParser()

    private lazy var rx = Regex {
        Anchor.wordBoundary
        Capture(as: sourceRef) {
            try! Remark.VisibilitySource.rx
        } transform: { .init(rawValue: String($0))! }
        " VIS "
        visibilityParser.rx
        Anchor.wordBoundary
    }

    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let result = try rx.firstMatch(in: remarks) else { return nil }
        let source = result[sourceRef], distance = visibilityParser.parse(result)

        remarks.removeSubrange(result.range)
        return .observedVisibility(source: source, distance: distance)
    }
}