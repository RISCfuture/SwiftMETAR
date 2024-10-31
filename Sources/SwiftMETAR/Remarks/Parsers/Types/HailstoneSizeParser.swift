import Foundation
@preconcurrency import RegexBuilder

final class HailstoneSizeParser: RemarkParser {
    var urgency = Remark.Urgency.urgent

    private let sizeParser = FractionParser()
    
    private lazy var rx = Regex {
        Anchor.wordBoundary
        "GR "
        sizeParser.rx
        Anchor.wordBoundary
    }
    
    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let result = try rx.firstMatch(in: remarks) else { return nil }
        let size = sizeParser.parse(result)
        
        remarks.removeSubrange(result.range)
        return .hailstoneSize(size)
    }
}
