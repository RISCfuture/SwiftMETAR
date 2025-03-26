import Foundation
@preconcurrency import RegexBuilder

final class RelativeHumidityParser: RemarkParser {
    var urgency = Remark.Urgency.routine

    private let humidityRef = Reference<UInt>()
    private lazy var rx = Regex {
        Anchor.wordBoundary
        "RH/"
        Capture(as: humidityRef) { Repeat(.digit, 1...3) } transform: { .init($0)! }
        Anchor.wordBoundary
    }

    func parse(remarks: inout String, date _: DateComponents) throws -> Remark? {
        guard let result = try rx.firstMatch(in: remarks) else { return nil }
        let humidity = result[humidityRef]

        remarks.removeSubrange(result.range)
        return .relativeHumidity(humidity)
    }
}
