import Foundation
@preconcurrency import RegexBuilder

final class TornadicActivityParser: RemarkParser {
    var urgency = Remark.Urgency.urgent

    private let typeRef = Reference<Remark.TornadicActivityType>()
    private let eventTypeRef = Reference<Remark.EventType>()
    private let timeParser = HourMinuteParser()
    private let distanceRef = Reference<UInt>()
    private let directionParser = RemarkDirectionParser()
    private let movingDirectionParser = RemarkDirectionParser()

    private lazy var rx = Regex {
        Anchor.wordBoundary
        Capture(as: typeRef) { try! Remark.TornadicActivityType.rx } transform: { .init(rawValue: String($0))! }
        " "
        Capture(as: eventTypeRef) { try! Remark.EventType.rx } transform: { .init(rawValue: String($0))! }
        timeParser.hourOptionalRx
        " "
        Capture(as: distanceRef) { OneOrMore(.digit) } transform: { UInt($0)! }
        " "
        directionParser.rx
        Optionally {
            " MOV"
            Optionally("G")
            " "
            movingDirectionParser.rx
        }

        Anchor.wordBoundary
    }

    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let result = try rx.firstMatch(in: remarks),
              let direction = directionParser.parse(result) else { return nil }
        let type = result[typeRef],
            eventType = result[eventTypeRef],
            referenceDate = zuluCal.date(from: date),
            originalString = String(remarks[result.range]),
            time = try timeParser.parse(match: result, referenceDate: referenceDate, originalString: originalString),
            distance = result[distanceRef],
            movingDirection = movingDirectionParser.parse(result)

        var begin: DateComponents? = nil
        var end: DateComponents? = nil
        switch eventType {
            case .began: begin = time
            case .ended: end = time
        }

        remarks.removeSubrange(result.range)
        return .tornadicActivity(type: type,
                                 begin: begin,
                                 end: end,
                                 location: .init(direction: direction, distance: distance),
                                 movingDirection: movingDirection)
    }
}
