import Foundation
@preconcurrency import RegexBuilder

final class SnowDepthParser: RemarkParser {
    var urgency = Remark.Urgency.routine

    private let depthRef = Reference<UInt>()
    private lazy var rx = Regex {
        Anchor.wordBoundary
        "4/"
        Capture(as: depthRef) { Repeat(.digit, count: 3) } transform: { UInt($0)! }
        Anchor.wordBoundary
    }
    
    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let result = try rx.firstMatch(in: remarks) else { return nil }
        let depth = result[depthRef]
        
        remarks.removeSubrange(result.range)
        return .snowDepth(depth)
    }
}
