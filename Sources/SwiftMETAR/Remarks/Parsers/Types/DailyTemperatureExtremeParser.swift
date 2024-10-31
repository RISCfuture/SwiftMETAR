import Foundation
@preconcurrency import RegexBuilder

final class DailyTemperatureExtremeParser: RemarkParser {
    var urgency = Remark.Urgency.routine

    private let highParser = NumericSignedIntegerParser(width: 3)
    private let lowParser = NumericSignedIntegerParser(width: 3)

    private lazy var rx = Regex {
        Anchor.wordBoundary
        "4"
        highParser.rx
        lowParser.rx
        Anchor.wordBoundary
    }

    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let result = try rx.firstMatch(in: remarks),
              let highNum = highParser.parse(result),
              let lowNum = lowParser.parse(result) else { return nil }

        let high: Float = Float(highNum)/10.0,
            low: Float = Float(lowNum)/10.0

        remarks.removeSubrange(result.range)
        return .dailyTemperatureExtremes(low: low, high: high)
    }
}
