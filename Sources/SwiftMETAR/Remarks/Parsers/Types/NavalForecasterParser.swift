import Foundation
@preconcurrency import RegexBuilder

private let nocapWeatherCenterRx = Remark.NavalWeatherCenter.allCases.map(\.rawValue).joined(separator: "|")

final class NavalForecasterParser: RemarkParser {
    var urgency = Remark.Urgency.routine

    private let centerRef = Reference<Remark.NavalWeatherCenter>()
    private let forecasterRef = Reference<UInt>()

    // swiftlint:disable force_try
    private lazy var rx = Regex {
        Anchor.wordBoundary
        "F"
        Capture(as: centerRef) { try! Remark.NavalWeatherCenter.rx } transform: { .init(rawValue: String($0))! }
        Capture(as: forecasterRef) { OneOrMore(.digit) } transform: { .init($0)! }
        Anchor.wordBoundary
    }
    // swiftlint:enable force_try

    func parse(remarks: inout String, date _: DateComponents) throws -> Remark? {
        guard let result = try rx.firstMatch(in: remarks) else { return nil }
        let center = result[centerRef], forecaster = result[forecasterRef]

        remarks.removeSubrange(result.range)
        return .navalForecaster(center: center, ID: forecaster)
    }
}
