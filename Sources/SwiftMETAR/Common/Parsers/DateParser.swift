import Foundation
import RegexBuilder

final class DayHourMinuteParser: WarmableParser, @unchecked Sendable {
  private let dateRef = Reference<(UInt8, UInt8, UInt8)>()

  lazy var rx = Regex {
    Capture(as: dateRef) {
      Repeat(.digit, count: 6)
    } transform: { string in
      let dayRange = string.startIndex...string.index(string.startIndex, offsetBy: 1)
      let hourRange =
        string.index(string.startIndex, offsetBy: 2)...string.index(string.startIndex, offsetBy: 3)
      let minuteRange =
        string.index(string.startIndex, offsetBy: 4)...string.index(string.startIndex, offsetBy: 5)

      guard let day = UInt8(string[dayRange]),
        var hour = UInt8(string[hourRange]),
        let minute = UInt8(string[minuteRange])
      else { throw Error.invalidDate(String(string)) }

      return (day, hour, minute)
    }
    Optionally("Z")
  }

  private lazy var anchoredRx = LockedRegex(
    Regex {
      Anchor.startOfSubject
      rx
      Anchor.endOfSubject
    }
  )

  func warmUp() {
    _ = try? anchoredRx.wholeMatch(in: "")
  }

  func parse(_ parts: inout [String.SubSequence], referenceDate: Date? = nil) throws
    -> DateComponents
  {
    guard !parts.isEmpty else { throw Error.badFormat }

    let dateStr = String(parts.removeFirst())
    guard let match = try anchoredRx.wholeMatch(in: dateStr) else {
      throw Error.invalidDate(dateStr)
    }
    return try parse(match: match, referenceDate: referenceDate, originalString: dateStr)
  }

  func matchesNext(_ parts: [String.SubSequence]) throws -> Bool {
    guard let str = parts.first else { return false }
    return try anchoredRx.matches(String(str))
  }

  func parse<T>(match: Regex<T>.Match, referenceDate: Date? = nil, originalString: String) throws
    -> DateComponents
  {
    var (day, hour, minute) = match[dateRef]
    var addDay = false
    if hour == 24 {
      hour = 0
      addDay = true
    }

    guard
      let components = applyComponents(
        .init(timeZone: zulu, day: Int(day), hour: Int(hour), minute: Int(minute)),
        within: .month,
        ofDate: referenceDate ?? Date()
      )
    else {
      throw Error.invalidDate(originalString)
    }

    if addDay {
      guard let day = zuluCal.date(from: components),
        let nextDay = zuluCal.date(byAdding: .day, value: 1, to: day)
      else {
        throw Error.invalidDate(originalString)
      }
      return zuluCal.dateComponents(in: zulu, from: nextDay)
    }

    return components
  }
}

class DayHourParser {
  private let dateRef = Reference<(UInt8, UInt8)>()

  lazy var rx = Regex {
    Capture(as: dateRef) {
      Repeat(.digit, count: 4)
    } transform: { string in
      let dayRange = string.startIndex...string.index(string.startIndex, offsetBy: 1)
      let hourRange =
        string.index(string.startIndex, offsetBy: 2)...string.index(string.startIndex, offsetBy: 3)

      guard let day = UInt8(string[dayRange]) else { throw Error.invalidDate(String(string)) }
      guard var hour = UInt8(string[hourRange]) else { throw Error.invalidDate(String(string)) }

      return (day, hour)
    }
  }

  func parse<T>(
    match: Regex<T>.Match,
    referenceDate: Date? = nil,
    afterDate afterDateComponents: DateComponents? = nil,
    originalString string: String
  ) throws -> DateComponents {
    var (day, hour) = match[dateRef]
    var addDay = false
    if hour == 24 {
      hour = 0
      addDay = true
    }

    guard
      let components = applyComponents(
        .init(timeZone: zulu, day: Int(day), hour: Int(hour)),
        within: .month,
        ofDate: referenceDate ?? Date()
      )
    else {
      throw Error.invalidDate(String(string))
    }

    if addDay {
      guard let day = zuluCal.date(from: components),
        let nextDay = zuluCal.date(byAdding: .day, value: 1, to: day)
      else {
        throw Error.invalidDate(String(string))
      }
      return zuluCal.dateComponents(in: zulu, from: nextDay)
    }

    if let afterDateComponents,
      let afterDate = zuluCal.date(from: afterDateComponents),
      let day = zuluCal.date(from: components),
      day < afterDate
    {
      guard let nextMonth = zuluCal.date(byAdding: .month, value: 1, to: day) else {
        throw Error.invalidDate(String(string))
      }
      return zuluCal.dateComponents(in: zulu, from: nextMonth)
    }

    return components
  }
}

class HourMinutePeriodParser {
  private static let minutesPerDay = 1440

  private let startHourRef = Reference<UInt8>()
  private let startMinuteRef = Reference<UInt8>()
  private let endHourRef = Reference<UInt8>()
  private let endMinuteRef = Reference<UInt8>()

  lazy var rx = Regex {
    Capture(as: startHourRef) {
      Repeat(.digit, count: 2)
    } transform: {
      UInt8($0)!
    }
    Capture(as: startMinuteRef) {
      Repeat(.digit, count: 2)
    } transform: {
      UInt8($0)!
    }
    "-"
    Capture(as: endHourRef) {
      Repeat(.digit, count: 2)
    } transform: {
      UInt8($0)!
    }
    Capture(as: endMinuteRef) {
      Repeat(.digit, count: 2)
    } transform: {
      UInt8($0)!
    }
    Optionally("Z")
  }

  /**
   Resolves a period given only as times of day against a reference date.

   The period brackets the reference date rather than following it: it starts at
   the most recent occurrence of the start time at or before `referenceDate`, and
   ends one period-length later. A winds aloft `FOR USE` period, for example, is
   resolved against the product's valid time, which it always contains, so
   `FOR USE 2100-0600Z` on a product valid at 130000Z runs from 122100Z to
   130600Z.
   */
  func parse<T>(
    match: Regex<T>.Match,
    referenceDate: Date? = nil,
    originalString: String
  ) throws -> DateComponentsInterval {
    let startTime = try minuteOfDay(
      hour: match[startHourRef],
      minute: match[startMinuteRef],
      originalString: originalString
    )
    let endTime = try minuteOfDay(
      hour: match[endHourRef],
      minute: match[endMinuteRef],
      originalString: originalString
    )

    guard
      let start = mostRecentTime(atMinuteOfDay: startTime, atOrBefore: referenceDate ?? Date()),
      let end = zuluCal.date(
        byAdding: .minute,
        value: minutes(from: startTime, to: endTime),
        to: start
      )
    else { throw Error.invalidDate(originalString) }

    return DateComponentsInterval(
      start: zuluCal.dateComponents(in: zulu, from: start),
      end: zuluCal.dateComponents(in: zulu, from: end)
    )
  }

  /// Converts an `HHMM` time to minutes past midnight, treating `2400` as the end
  /// of the day the way ``DayHourMinuteParser`` does.
  private func minuteOfDay(hour: UInt8, minute: UInt8, originalString: String) throws -> Int {
    guard hour <= 24, minute <= 59, hour < 24 || minute == 0 else {
      throw Error.invalidDate(originalString)
    }
    return Int(hour) * 60 + Int(minute)
  }

  /// The most recent occurrence of a time of day at or before `date`.
  private func mostRecentTime(atMinuteOfDay minuteOfDay: Int, atOrBefore date: Date) -> Date? {
    guard let startOfDay = date.startOf(.day),
      let time = zuluCal.date(byAdding: .minute, value: minuteOfDay, to: startOfDay)
    else { return nil }

    guard time > date else { return time }
    return zuluCal.date(byAdding: .day, value: -1, to: time)
  }

  /// The length of a period in minutes, wrapping into the following day when the
  /// end time is not later in the day than the start time.
  private func minutes(from start: Int, to end: Int) -> Int {
    end > start ? end - start : end - start + Self.minutesPerDay
  }
}

class HourMinuteParser {
  private let dateRef = Reference<(UInt8?, UInt8)>()

  lazy var hourOptionalRx = Regex {
    Capture(as: dateRef) {
      Optionally { Repeat(.digit, count: 2) }
      Repeat(.digit, count: 2)
    } transform: { string in
      if string.count == 2 {
        guard let minute = UInt8(string) else { throw Error.invalidDate(String(string)) }
        return (nil, minute)
      }
      let hourRange = string.startIndex...string.index(string.startIndex, offsetBy: 1)
      let minuteRange =
        string.index(string.startIndex, offsetBy: 2)...string.index(string.startIndex, offsetBy: 3)

      guard let hour = UInt8(string[hourRange]),
        let minute = UInt8(string[minuteRange])
      else { throw Error.invalidDate(String(string)) }

      return (hour, minute)
    }
  }

  func parse<T>(match: Regex<T>.Match, referenceDate: Date? = nil, originalString string: String)
    throws -> DateComponents
  {
    let (hour, minute) = match[dateRef]

    guard
      let components =
        if let hour {
          applyComponents(
            .init(timeZone: zulu, hour: Int(hour), minute: Int(minute)),
            within: .day,
            ofDate: referenceDate ?? Date()
          )
        } else {
          applyComponents(
            .init(timeZone: zulu, minute: Int(minute)),
            within: .hour,
            ofDate: referenceDate ?? Date()
          )
        }
    else {
      throw Error.invalidDate(String(string))
    }

    return components
  }
}
