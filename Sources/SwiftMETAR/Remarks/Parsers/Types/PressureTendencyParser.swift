import Foundation
@preconcurrency import RegexBuilder

final class PressureTendencyParser: RemarkParser {
    var urgency = Remark.Urgency.routine

    private let characterRef = Reference<Remark.PressureCharacter>()
    private let amountRef = Reference<Float>()

    // swiftlint:disable force_try
    private lazy var rx = Regex {
        Anchor.wordBoundary
        "5"
        Capture(as: characterRef) { try! Remark.PressureCharacter.rx } transform: { .init(rawValue: String($0))! }
        Capture(as: amountRef) { Repeat(.digit, count: 3) } transform: { Float($0)! / 10.0 }
        Anchor.wordBoundary
    }
    // swiftlint:enable force_try

    func parse(remarks: inout String, date _: DateComponents) throws -> Remark? {
        guard let result = try rx.firstMatch(in: remarks) else { return nil }

        let character = result[characterRef]
        var amount = result[amountRef]

        switch character {
            case .inflectedDown, .deceleratingDown, .steadyDown, .acceleratingDown:
                amount *= -1
            default: break
        }

        remarks.removeSubrange(result.range)
        return .pressureTendency(character: character, change: amount)
    }
}
