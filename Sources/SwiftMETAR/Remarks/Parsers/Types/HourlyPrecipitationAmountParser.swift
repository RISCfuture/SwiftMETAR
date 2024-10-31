import Foundation
@preconcurrency import RegexBuilder

final class HourlyPrecipitationAmountParser: RemarkParser {
    var urgency = Remark.Urgency.routine

    private let amountRef = Reference<Float>()

    private lazy var rx = Regex {
        Anchor.wordBoundary
        "P"
        Capture(as: amountRef) { Repeat(.digit, count: 4) } transform: { Float($0)!/100.0 }
        Anchor.wordBoundary
    }

    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let result = try rx.firstMatch(in: remarks) else { return nil }
        let amount = result[amountRef]

        remarks.removeSubrange(result.range)
        return .hourlyPrecipitationAmount(amount)
    }
}
