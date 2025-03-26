import Foundation
@preconcurrency import RegexBuilder

final class CloudTypesParser: RemarkParser {
    var urgency = Remark.Urgency.routine

    private let lowRef = Reference<Remark.LowCloudType>()
    private let midRef = Reference<Remark.MiddleCloudType>()
    private let highRef = Reference<Remark.HighCloudType>()

    // swiftlint:disable force_try
    private lazy var rx = Regex {
        Anchor.wordBoundary
        "8/"
        Capture(as: lowRef) { try! Remark.LowCloudType.rx } transform: { .init(rawValue: String($0))! }
        Capture(as: midRef) { try! Remark.MiddleCloudType.rx } transform: { .init(rawValue: String($0))! }
        Capture(as: highRef) { try! Remark.HighCloudType.rx } transform: { .init(rawValue: String($0))! }
    }
    // swiftlint:enable force_try

    func parse(remarks: inout String, date _: DateComponents) throws -> Remark? {
        guard let result = try rx.firstMatch(in: remarks) else { return nil }
        let low = result[lowRef], mid = result[midRef], high = result[highRef]

        remarks.removeSubrange(result.range)
        return .cloudTypes(low: low, middle: mid, high: high)
    }
}
