import Foundation
@preconcurrency import RegexBuilder

final class ThunderstormBeginEndParser: RemarkParser {
    var urgency = Remark.Urgency.caution

    private let typeRef = Reference<Remark.EventType>()
    private let timeParser = HourMinuteParser()
    private lazy var eventRx = Regex {
        Capture(as: typeRef) { try! Remark.EventType.rx } transform: { .init(rawValue: String($0))! }
        timeParser.hourOptionalRx
    }

    private let eventsRef = Reference<Substring>()
    private lazy var rx = Regex {
        Anchor.wordBoundary
        "TS"
        Capture(as: eventsRef) {
            OneOrMore(eventRx)
        }
        Anchor.wordBoundary
    }

    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let result = try rx.firstMatch(in: remarks) else { return nil }
        let eventsStr = result[eventsRef],
            referenceDate = zuluCal.date(from: date),
            events = try parseEvents(String(eventsStr), referenceDate: referenceDate)

        remarks.removeSubrange(result.range)
        return .thunderstormBeginEnd(events: events)
    }

    private func parseEvents(_ string: String, referenceDate: Date? = nil) throws -> Array<Remark.ThunderstormEvent> {
        let result = string.matches(of: eventRx)
        return try result.map { match in
            let type = match[typeRef],
                time = try timeParser.parse(match: match, referenceDate: referenceDate, originalString: string)
            return .init(type: type, time: time)
        }
    }
}
