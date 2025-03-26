import Foundation
@preconcurrency import RegexBuilder

final class SeaLevelPressureParser: RemarkParser {
    var urgency = Remark.Urgency.routine

    private let pressureRef = Reference<UInt?>()
    private let noRef = Reference<Bool?>()

    private lazy var rx = Regex {
        Anchor.wordBoundary
        "SLP"
        ChoiceOf {
            Capture(as: pressureRef) { Repeat(.digit, count: 3) } transform: { .init($0) }
            Capture(as: noRef) { "NO" } transform: { _ in true }
        }
        Anchor.wordBoundary
    }

    func parse(remarks: inout String, date _: DateComponents) throws -> Remark? {
        guard let result = try rx.firstMatch(in: remarks) else { return nil }

        if let pressure = result[pressureRef] {
            let value = Float(pressure) / 10.0 + 900
            remarks.removeSubrange(result.range)
            return .seaLevelPressure(value)
        }
        if result[noRef] == true {
            remarks.removeSubrange(result.range)
            return .seaLevelPressure(nil)
        }

        return nil
    }
}
