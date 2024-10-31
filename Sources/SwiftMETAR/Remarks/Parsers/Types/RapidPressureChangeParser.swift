import Foundation
@preconcurrency import RegexBuilder

final class RapidPressureChangeParser: RemarkParser {
    var urgency = Remark.Urgency.caution

    private let changeRef = Reference<Remark.RapidPressureChange>()
    private lazy var rx = Regex {
        Anchor.wordBoundary
        Capture(as: changeRef) { try! Remark.RapidPressureChange.rx } transform: { .init(rawValue: String($0))! }
        Anchor.wordBoundary
    }

    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let result = try rx.firstMatch(in: remarks) else { return nil }
        let change = result[changeRef]
        
        remarks.removeSubrange(result.range)
        return .rapidPressureChange(change)
    }
}
