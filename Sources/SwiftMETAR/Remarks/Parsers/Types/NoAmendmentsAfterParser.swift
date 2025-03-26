import Foundation
@preconcurrency import RegexBuilder

final class NoAmendmentsAfterParser: RemarkParser {
    var urgency = Remark.Urgency.routine

    private let timeParser = DayHourParser()

    private lazy var rx = Regex {
        Anchor.wordBoundary
        "NO AMD"
        Optionally("S")
        " AFT "
        timeParser.rx
        Anchor.wordBoundary
    }

    func parse(remarks: inout String, date _: DateComponents) throws -> Remark? {
        guard let result = try rx.firstMatch(in: remarks) else { return nil }
        let originalString = String(remarks[result.range]),
            afterDate = try timeParser.parse(match: result, originalString: originalString)

        remarks.removeSubrange(result.range)
        return .noAmendmentsAfter(afterDate)
    }
}
