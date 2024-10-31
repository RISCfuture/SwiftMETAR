import Foundation
@preconcurrency import RegexBuilder

final class ThunderstormLocationParser: RemarkParser {
    var urgency = Remark.Urgency.urgent

    private let proximityRef = Reference<Remark.Proximity?>()
    private let directionsParser = RemarkDirectionsParser()
    private let movingDirectionParser = RemarkDirectionParser()

    private lazy var rx = Regex {
        Anchor.wordBoundary
        "TS"
        Optionally {
            " "
            Capture(as: proximityRef) { try! Remark.Proximity.rx } transform: { .init(rawValue: String($0)) }
        }
        Optionally {
            CharacterClass.anyOf(" -")
            directionsParser.rx
        }
        Optionally {
            " MOV"
            Optionally("G")
            " "
            movingDirectionParser.rx
        }
        Anchor.wordBoundary
    }
    
    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let result = try rx.firstMatch(in: remarks) else { return nil }
        let proximity = result[proximityRef],
            directions = directionsParser.parse(result),
            movingDirection = movingDirectionParser.parse(result)

        remarks.removeSubrange(result.range)
        return .thunderstormLocation(proximity: proximity,
                                     directions: directions ?? Set(),
                                     movingDirection: movingDirection)
    }
}
