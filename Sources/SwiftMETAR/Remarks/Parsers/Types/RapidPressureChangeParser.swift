import Foundation
@preconcurrency import RegexBuilder

final class RapidPressureChangeParser: RemarkParser {
    var urgency = Remark.Urgency.caution

    private let changeRef = Reference<Remark.RapidPressureChange>()
    // swiftlint:disable force_try
    private lazy var rx = Regex {
        Anchor.wordBoundary
        Capture(as: changeRef) { try! Remark.RapidPressureChange.rx } transform: { .init(rawValue: String($0))! }
        Anchor.wordBoundary
    }
    // swiftlint:enable force_try

    func parse(remarks: inout String, date _: DateComponents) throws -> Remark? {
        guard let result = try rx.firstMatch(in: remarks) else { return nil }
        let change = result[changeRef]

        remarks.removeSubrange(result.range)
        return .rapidPressureChange(change)
    }
}
