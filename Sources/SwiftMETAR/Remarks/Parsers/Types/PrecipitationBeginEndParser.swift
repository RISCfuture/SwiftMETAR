import Foundation
@preconcurrency import RegexBuilder

final class PrecipitationBeginEndParser: RemarkParser {
    var urgency = Remark.Urgency.routine


    private let typeRef = Reference<Remark.EventType>()
    private let timeParser = HourMinuteParser()
    private lazy var timeRx = Regex {
        Capture(as: typeRef) { try! Remark.EventType.rx } transform: { .init(rawValue: String($0))! }
        timeParser.hourOptionalRx
    }

    private let descriptorRef = Reference<Weather.Descriptor?>()
    private let phenomenonRef = Reference<Weather.Phenomenon>()
    private let timesRef = Reference<Substring>()
    private lazy var eventRx = Regex {
        Capture(as: descriptorRef) {
            try! Optionally(Weather.Descriptor.rx)
        } transform: { .init(rawValue: String($0)) }
        Capture(as: phenomenonRef) { try! Weather.Phenomenon.rx } transform: { .init(rawValue: String($0))! }
        Capture(as: timesRef) { OneOrMore(timeRx) }
    }

    private let eventsRef = Reference<Substring>()
    private lazy var rx = Regex {
        Anchor.wordBoundary
        Capture(as: eventsRef) { OneOrMore(eventRx) }
        Anchor.wordBoundary
    }

    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let result = try rx.firstMatch(in: remarks) else { return nil }

        let originalString = String(remarks[result.range]),
            referenceDate = zuluCal.date(from: date)

        let eventsStr = result[eventsRef]
        let events = try parseEvents(from: String(eventsStr), referenceDate: referenceDate, originalString: originalString)
        guard !events.isEmpty else { return nil }

        remarks.removeSubrange(result.range)
        return .precipitationBeginEnd(events: events)
    }

    private func parseEvents(from string: String, referenceDate: Date?, originalString: String) throws -> Array<Remark.PrecipitationEvent> {
        let result = string.matches(of: eventRx)
        guard !result.isEmpty else { return [] }

        var events = Array<Remark.PrecipitationEvent>()
        for match in result {
            let eventStr = String(string[match.range])
            guard let eventResult = try eventRx.wholeMatch(in: eventStr) else {
                preconditionFailure("eventsRx should have matched inside rx")
            }
            let descriptor = eventResult[descriptorRef],
                phenomenon = eventResult[phenomenonRef],
                timesStr = eventResult[timesRef],
                times = try parseTimes(from: String(timesStr), referenceDate: referenceDate, originalString: originalString)

            for (type, time) in times {
                events.append(.init(event: type,
                                    phenomenon: phenomenon,
                                    descriptor: descriptor,
                                    time: time))
            }
        }
        return events
    }

    private func parseTimes(from string: String, referenceDate: Date?, originalString: String) throws -> Array<(Remark.EventType, DateComponents)> {
        let result = string.matches(of: timeRx)
        guard !result.isEmpty else { return [] }
        return try result.map { match in
            let type = match[typeRef],
                time = try timeParser.parse(match: match, referenceDate: referenceDate, originalString: originalString)
            return (type, time)
        }
    }
}
