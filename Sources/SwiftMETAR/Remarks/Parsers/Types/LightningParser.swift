import Foundation
@preconcurrency import RegexBuilder

final class LightningParser: RemarkParser {
    var urgency = Remark.Urgency.urgent

    private let directionsParser = RemarkDirectionsParser()
    private let frequencyRef = Reference<Remark.Frequency?>()
    private let typesRef = Reference<Substring?>()
    private let proximityRef = Reference<Remark.Proximity?>()

    // swiftlint:disable force_try
    private lazy var rx = Regex {
        Anchor.wordBoundary
        Optionally {
            Capture(as: frequencyRef) { try! Remark.Frequency.rx } transform: { .init(rawValue: String($0)) }
            " "
        }
        "LTG"
        Optionally {
            Capture(as: typesRef) { OneOrMore { try! Remark.LightningType.rx } } transform: { $0 }
        }
        Optionally {
            " "
            Capture(as: proximityRef) { try! Remark.Proximity.rx } transform: { .init(rawValue: String($0)) }
        }
        Optionally {
            " "
            directionsParser.rx
        }
        Anchor.wordBoundary
    }
    // swiftlint:enable force_try

    func parse(remarks: inout String, date _: DateComponents) throws -> Remark? {
        guard let result = try rx.firstMatch(in: remarks) else { return nil }

        let frequency = result[frequencyRef],
            typesStr = result[typesRef],
            proximity = result[proximityRef],
            directions = directionsParser.parse(result)

        var types = Set<Remark.LightningType>()
        if let typesStr {
            if !typesStr.isEmpty {
                for typeStr in String(typesStr).partition(by: 2) {
                    guard let type = Remark.LightningType(rawValue: typeStr) else { return nil }
                    types.insert(type)
                }
            }
        }

        remarks.removeSubrange(result.range)
        return .lightning(frequency: frequency,
                          types: types,
                          proximity: proximity,
                          directions: directions ?? Set())
    }
}
