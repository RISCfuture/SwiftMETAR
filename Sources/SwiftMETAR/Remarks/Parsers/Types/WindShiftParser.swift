import Foundation
@preconcurrency import RegexBuilder

final class WindShiftParser: RemarkParser {
    var urgency = Remark.Urgency.caution

    private let timeParser = HourMinuteParser()
    private let frontalPassageRef = Reference<Bool>()

    private lazy var rx = Regex {
        Anchor.wordBoundary
        "WSHFT "
        timeParser.hourOptionalRx
        Capture(as: frontalPassageRef) {
            Optionally {
                " FROPA"
            }
        } transform: { $0 == " FROPA" }
        Anchor.wordBoundary
    }

    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let result = try rx.firstMatch(in: remarks) else { return nil }
        let originalString = String(remarks[result.range]),
            referenceDate = zuluCal.date(from: date),
            date = try timeParser.parse(match: result, referenceDate: referenceDate, originalString: originalString),
            frontalPassage = result[frontalPassageRef]

        remarks.removeSubrange(result.range)
        return .windShift(time: date, frontalPassage: frontalPassage)
    }
}
