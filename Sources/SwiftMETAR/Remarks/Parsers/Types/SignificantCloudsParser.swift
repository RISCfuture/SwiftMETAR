import Foundation
@preconcurrency import RegexBuilder

final class SignificantCloudsParser: RemarkParser {
    var urgency = Remark.Urgency.caution

    private let apparentRef = Reference<Bool>()
    private let cloudTypeRef = Reference<Remark.SignificantCloudType>()
    private let distantRef = Reference<Bool>()
    private let directionsParser = RemarkDirectionsParser()
    private let movingDirectionParser = RemarkDirectionParser()

    // swiftlint:disable force_try
    private lazy var rx = Regex {
        Anchor.wordBoundary
        Capture(as: apparentRef) { Optionally("APRNT ") } transform: { !$0.isEmpty }
        Capture(as: cloudTypeRef) { try! Remark.SignificantCloudType.rx } transform: { .from(raw: String($0))! }
        " "
        Capture(as: distantRef) { Optionally("DSNT ") } transform: { !$0.isEmpty }
        directionsParser.rx
        Optionally {
            " MOV"
            Optionally("G")
            " "
            movingDirectionParser.rx
        }
        Anchor.wordBoundary
    }
    // swiftlint:enable force_try

    func parse(remarks: inout String, date _: DateComponents) throws -> Remark? {
        guard let result = try rx.firstMatch(in: remarks) else { return nil }

        let apparent = result[apparentRef],
            type = result[cloudTypeRef],
            distant = result[distantRef],
            directions = directionsParser.parse(result),
            movingDirection = movingDirectionParser.parse(result)

        remarks.removeSubrange(result.range)
        return .significantClouds(type: type,
                                  directions: directions ?? Set(),
                                  movingDirection: movingDirection,
                                  distant: distant,
                                  apparent: apparent)
    }
}

extension Remark.SignificantCloudType {
    static func from(raw: String) -> Self? {
        if raw == "ROTOR CLD" { return .rotor }
        return .init(rawValue: raw)
    }
}
