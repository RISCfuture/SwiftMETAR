import Foundation
import RegexBuilder

final class PrecipitationBeginEndParser: RemarkParser, @unchecked Sendable {
  var urgency = Remark.Urgency.routine

  private let typeRef = Reference<Remark.EventType>()
  private let timeParser = HourMinuteParser()
  private lazy var timeRx = LockedRegex(
    Regex {
      Capture(as: typeRef) {
        Remark.EventType.rx
      } transform: {
        .init(rawValue: String($0))!
      }
      timeParser.hourOptionalRx
    }
  )

  private let descriptorRef = Reference<Weather.Descriptor?>()
  private let phenomenonRef = Reference<Weather.Phenomenon>()
  private let timesRef = Reference<Substring>()
  private lazy var eventRx = LockedRegex(
    Regex {
      Capture(as: descriptorRef) {
        Optionally(Weather.Descriptor.rx)
      } transform: {
        .init(rawValue: String($0))
      }
      Capture(as: phenomenonRef) {
        Weather.Phenomenon.rx
      } transform: {
        .init(rawValue: String($0))!
      }
      Capture(as: timesRef) { OneOrMore(timeRx.composable) }
    }
  )

  private let eventsRef = Reference<Substring>()
  private lazy var rx = LockedRegex(
    Regex {
      Anchor.wordBoundary
      Capture(as: eventsRef) { OneOrMore(eventRx.composable) }
      Anchor.wordBoundary
    }
  )

  func parse(remarks: inout String, date: DateComponents) throws(Error) -> Remark? {
    guard let result = try rx.firstMatch(in: remarks) else { return nil }

    let originalString = String(remarks[result.range])
    let referenceDate = zuluCal.date(from: date)

    let eventsStr = result[eventsRef]
    let events = try parseEvents(
      from: String(eventsStr),
      referenceDate: referenceDate,
      originalString: originalString
    )
    guard !events.isEmpty else { return nil }

    remarks.removeSubrange(result.range)
    return .precipitationBeginEnd(events: events)
  }

  private func parseEvents(from string: String, referenceDate: Date?, originalString: String)
    throws(Error)
    -> [Remark.PrecipitationEvent]
  {
    let result = eventRx.allMatches(in: string)
    guard !result.isEmpty else { return [] }

    var events = [Remark.PrecipitationEvent]()
    for match in result {
      let eventStr = String(string[match.range])
      guard let eventResult = try eventRx.wholeMatch(in: eventStr) else {
        preconditionFailure("eventsRx should have matched inside rx")
      }
      let descriptor = eventResult[descriptorRef]
      let phenomenon = eventResult[phenomenonRef]
      let timesStr = eventResult[timesRef]
      let times = try parseTimes(
        from: String(timesStr),
        referenceDate: referenceDate,
        originalString: originalString
      )

      for (type, time) in times {
        events.append(
          .init(
            event: type,
            phenomenon: phenomenon,
            descriptor: descriptor,
            time: time
          )
        )
      }
    }
    return events
  }

  private func parseTimes(
    from string: String,
    referenceDate: Date?,
    originalString: String
  ) throws(Error) -> [(Remark.EventType, DateComponents)] {
    var times = [(Remark.EventType, DateComponents)]()
    for match in timeRx.allMatches(in: string) {
      let time = try timeParser.parse(
        match: match,
        referenceDate: referenceDate,
        originalString: originalString
      )
      times.append((match[typeRef], time))
    }
    return times
  }
}
