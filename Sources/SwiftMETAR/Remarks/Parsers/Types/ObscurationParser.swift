import Foundation
@preconcurrency import RegexBuilder

final class ObscurationParser: RemarkParser {
    var urgency = Remark.Urgency.routine

    private let typeRef = Reference<Weather.Phenomenon>()
    private let coverageRef = Reference<Remark.Coverage?>()
    private let heightRef = Reference<UInt>()

    // swiftlint:disable force_try
    private lazy var rx = Regex {
        Anchor.wordBoundary
        Capture(as: typeRef) { try! Weather.Phenomenon.rx } transform: { .init(rawValue: String($0))! }
        " "
        Optionally {
            Capture(as: coverageRef) { try! Remark.Coverage.rx } transform: { .init(rawValue: String($0)) }
        }
        Capture(as: heightRef) { Repeat(.digit, count: 3) } transform: { .init($0)! * 100 }
        Anchor.wordBoundary
    }
    // swiftlint:enable force_try

    func parse(remarks: inout String, date _: DateComponents) throws -> Remark? {
        guard let result = try rx.firstMatch(in: remarks) else { return nil }
        let type = result[typeRef],
            coverage = result[coverageRef],
            height = result[heightRef]

        remarks.removeSubrange(result.range)
        return .obscuration(type: type, amount: coverage, height: height)
    }
}
