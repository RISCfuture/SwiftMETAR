import Foundation
@preconcurrency import RegexBuilder

final class PressureTendencyParser: RemarkParser {
    var urgency = Remark.Urgency.routine

    private let characterRef = Reference<Remark.PressureCharacter>()
    private let amountRef = Reference<Float>()

    private lazy var rx = Regex {
        Anchor.wordBoundary
        "5"
        Capture(as: characterRef) { try! Remark.PressureCharacter.rx } transform: { .init(rawValue: String($0))! }
        Capture(as: amountRef) { Repeat(.digit, count: 3) } transform: { Float($0)!/10.0 }
        Anchor.wordBoundary
    }

    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let result = try rx.firstMatch(in: remarks) else { return nil }

        let character = result[characterRef],
            amount = result[amountRef]

        remarks.removeSubrange(result.range)
        return .pressureTendency(character: character, change: amount)
    }
}
