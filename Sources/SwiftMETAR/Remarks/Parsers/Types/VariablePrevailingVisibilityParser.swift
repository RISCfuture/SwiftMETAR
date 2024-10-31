import Foundation
@preconcurrency import RegexBuilder

final class VariablePrevailingVisibilityParser: RemarkParser {
    var urgency = Remark.Urgency.routine

    private let lowParser = FractionParser()
    private let highParser = FractionParser()

    private lazy var rx = Regex {
        Anchor.wordBoundary
        "VIS "
        lowParser.rx
        "V"
        highParser.rx
        Anchor.wordBoundary
    }
    
    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let result = try rx.firstMatch(in: remarks) else { return nil }
        let low = lowParser.parse(result), high = highParser.parse(result)
        
        remarks.removeSubrange(result.range)
        return .variablePrevailingVisibility(low: low, high: high)
    }
}
