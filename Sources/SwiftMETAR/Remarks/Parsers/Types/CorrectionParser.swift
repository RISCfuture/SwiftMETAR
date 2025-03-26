import Foundation
@preconcurrency import RegexBuilder

final class CorrectionParser: RemarkParser {
    var urgency = Remark.Urgency.routine

    private let hourRef = Reference<UInt8>()
    private let minuteRef = Reference<UInt8>()

    private lazy var rx = Regex {
        Anchor.wordBoundary
        "COR "
        Capture(as: hourRef) { Repeat(.digit, count: 2) } transform: { .init($0)! }
        Capture(as: minuteRef) { Repeat(.digit, count: 2) } transform: { .init($0)! }
        Anchor.wordBoundary
    }

    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let result = try rx.firstMatch(in: remarks) else { return nil }
        let hour = result[hourRef], minute = result[minuteRef]
        guard let afterDate = date.merged(with: .init(hour: Int(hour), minute: Int(minute))) else { return nil }

        remarks.removeSubrange(result.range)
        return .correction(time: afterDate)
    }
}
