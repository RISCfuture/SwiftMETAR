import Foundation
import RegexBuilder

final class ThunderstormBeginEndParser: RemarkParser, @unchecked Sendable {
  var urgency = Remark.Urgency.caution

  private let typeRef = Reference<Remark.EventType>()
  private let timeParser = HourMinuteParser()
  // swiftlint:disable force_try
  private lazy var eventRx = LockedRegex(
    Regex {
      Capture(as: typeRef) {
        try! Remark.EventType.rx
      } transform: {
        .init(rawValue: String($0))!
      }
      timeParser.hourOptionalRx
    }
  )
  // swiftlint:enable force_try

  private let eventsRef = Reference<Substring>()
  private lazy var rx = LockedRegex(
    Regex {
      Anchor.wordBoundary
      "TS"
      Capture(as: eventsRef) {
        OneOrMore(eventRx.composable)
      }
      Anchor.wordBoundary
    }
  )

  func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
    guard let result = try rx.firstMatch(in: remarks) else { return nil }
    let eventsStr = result[eventsRef]
    let referenceDate = zuluCal.date(from: date)
    let events = try parseEvents(String(eventsStr), referenceDate: referenceDate)

    remarks.removeSubrange(result.range)
    return .thunderstormBeginEnd(events: events)
  }

  private func parseEvents(_ string: String, referenceDate: Date? = nil) throws -> [Remark
    .ThunderstormEvent]
  {
    let result = eventRx.allMatches(in: string)
    return try result.map { match in
      let type = match[typeRef]
      let time = try timeParser.parse(
        match: match,
        referenceDate: referenceDate,
        originalString: string
      )
      return .init(type: type, time: time)
    }
  }
}
