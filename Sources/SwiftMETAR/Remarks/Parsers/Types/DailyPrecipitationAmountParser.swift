import Foundation
@preconcurrency import RegexBuilder

final class DailyPrecipitationAmountParser: RemarkParser {
    var urgency = Remark.Urgency.routine

    private let amountRef = Reference<UInt?>()
    private let missingRef = Reference<Bool?>()

    private lazy var rx = Regex {
        Anchor.wordBoundary
        "7"
        ChoiceOf {
            Regex {
                Capture(as: amountRef) {
                    Repeat(.digit, count: 4)
                } transform: { .init($0) }
                Anchor.wordBoundary
            }
            Capture(as: missingRef) { Repeat("/", count: 4) } transform: { _ in true }
        }
    }

    func parse(remarks: inout String, date _: DateComponents) throws -> Remark? {
        guard let result = try rx.firstMatch(in: remarks) else { return nil }

        if result[missingRef] == true {
            remarks.removeSubrange(result.range)
            return .dailyPrecipitationAmount(nil)
        }
        guard let num = result[amountRef] else { return nil }
        let amount = Float(num) / 100.0

        remarks.removeSubrange(result.range)
        return .dailyPrecipitationAmount(amount)
    }
}
