import Foundation
@preconcurrency import RegexBuilder

final class ObservationTypeParser: RemarkParser {
    var urgency = Remark.Urgency.routine

    private let typeRef = Reference<Substring>()
    private let augmentedRef = Reference<Bool>()

    private lazy var rx = Regex {
        Anchor.wordBoundary
        Capture(as: typeRef) {
            "A"
            CharacterClass.anyOf("O0") // sometimes forecasters write "A02" instead of "AO2"
            CharacterClass.digit
        }
        Capture(as: augmentedRef) { Optionally { "A" } } transform: { $0 == "A" }
        Anchor.wordBoundary
    }
    
    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let result = try rx.firstMatch(in: remarks) else { return nil }
        let typeStr = String(result[typeRef]).replacingOccurrences(of: "0", with: "O"),
            augmented = result[augmentedRef]
        guard let type = Remark.ObservationType(rawValue: typeStr) else { return nil }

        remarks.removeSubrange(result.range)
        return .observationType(type, augmented: augmented)
    }
}
