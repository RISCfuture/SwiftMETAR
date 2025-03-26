import Foundation
@preconcurrency import RegexBuilder

final class VariableWindDirectionParser: RemarkParser {
    var urgency = Remark.Urgency.routine

    private let dir1Ref = Reference<UInt16>()
    private let dir2Ref = Reference<UInt16>()

    private lazy var rx = Regex {
        Anchor.wordBoundary
        "WND "
        Capture(as: dir1Ref) { Repeat(.digit, count: 3) } transform: { .init($0)! }
        "V"
        Capture(as: dir2Ref) { Repeat(.digit, count: 3) } transform: { .init($0)! }
        Anchor.wordBoundary
    }

    func parse(remarks: inout String, date _: DateComponents) throws -> Remark? {
        guard let result = try rx.firstMatch(in: remarks) else { return nil }
        let dir1 = result[dir1Ref], dir2 = result[dir2Ref]

        remarks.removeSubrange(result.range)
        return .variableWindDirection(dir1, dir2)
    }
}
