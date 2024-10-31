import Foundation
@preconcurrency import RegexBuilder

final class VariableCeilingHeightParser: RemarkParser {
    var urgency = Remark.Urgency.routine

    private let lowRef = Reference<UInt>()
    private let highRef = Reference<UInt>()

    private lazy var rx = Regex {
        Anchor.wordBoundary
        "CIG "
        Capture(as: lowRef) { Repeat(.digit, count: 3) } transform: { UInt($0)!*100 }
        "V"
        Capture(as: highRef) { Repeat(.digit, count: 3) } transform: { UInt($0)!*100 }
        Anchor.wordBoundary
    }
    
    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let result = try rx.firstMatch(in: remarks) else { return nil }
        let low = result[lowRef], high = result[highRef]
        
        remarks.removeSubrange(result.range)
        return .variableCeilingHeight(low: low, high: high)
    }
}
