import Foundation
@preconcurrency import RegexBuilder

class DayHourMinuteParser {
    private let dateRef = Reference<(UInt8, UInt8, UInt8)>()

    lazy var rx = Regex {
        Capture(as: dateRef) {
            Repeat(.digit, count: 6)
        } transform: { string in
            let dayRange = string.startIndex...string.index(string.startIndex, offsetBy: 1)
            let hourRange = string.index(string.startIndex, offsetBy: 2)...string.index(string.startIndex, offsetBy: 3)
            let minuteRange = string.index(string.startIndex, offsetBy: 4)...string.index(string.startIndex, offsetBy: 5)

            guard let day = UInt8(string[dayRange]),
                  var hour = UInt8(string[hourRange]),
                  let minute = UInt8(string[minuteRange]) else { throw Error.invalidDate(String(string)) }

            return (day, hour, minute)
        }
        Optionally("Z")
    }

    private lazy var anchoredRx = Regex {
        Anchor.startOfSubject
        rx
        Anchor.endOfSubject
    }

    func parse(_ parts: inout [String.SubSequence], referenceDate: Date? = nil) throws -> DateComponents {
        guard !parts.isEmpty else { throw Error.badFormat }

        let dateStr = String(parts.removeFirst())
        guard let match = try anchoredRx.wholeMatch(in: dateStr) else { throw Error.invalidDate(dateStr) }
        return try parse(match: match, referenceDate: referenceDate, originalString: dateStr)
    }

    func matchesNext(_ parts: [String.SubSequence]) throws -> Bool {
        guard let str = parts.first else { return false }
        return try anchoredRx.matches(String(str))
    }

    func parse<T>(match: Regex<T>.Match, referenceDate: Date? = nil, originalString: String) throws -> DateComponents {
        var (day, hour, minute) = match[dateRef]
        var addDay = false
        if hour == 24 { hour = 0; addDay = true }

        guard let components = applyComponents(
            .init(timeZone: zulu, day: Int(day), hour: Int(hour), minute: Int(minute)),
            within: .month,
            ofDate: referenceDate ?? Date()) else {
            throw Error.invalidDate(originalString)
        }

        if addDay {
            guard let day = zuluCal.date(from: components),
                  let nextDay = zuluCal.date(byAdding: .day, value: 1, to: day) else {
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
            let hourRange = string.index(string.startIndex, offsetBy: 2)...string.index(string.startIndex, offsetBy: 3)

            guard let day = UInt8(string[dayRange]) else { throw Error.invalidDate(String(string)) }
            guard var hour = UInt8(string[hourRange]) else { throw Error.invalidDate(String(string)) }

            return (day, hour)
        }
    }

    func parse<T>(match: Regex<T>.Match, referenceDate: Date? = nil, afterDate afterDateComponents: DateComponents? = nil, originalString string: String) throws -> DateComponents {
        var (day, hour) = match[dateRef]
        var addDay = false
        if hour == 24 { hour = 0; addDay = true }

        guard let components = applyComponents(
            .init(timeZone: zulu, day: Int(day), hour: Int(hour)),
            within: .month,
            ofDate: referenceDate ?? Date()) else {
            throw Error.invalidDate(String(string))
        }

        if addDay {
            guard let day = zuluCal.date(from: components),
                  let nextDay = zuluCal.date(byAdding: .day, value: 1, to: day) else {
                throw Error.invalidDate(String(string))
            }
            return zuluCal.dateComponents(in: zulu, from: nextDay)
        }

        if let afterDateComponents,
           let afterDate = zuluCal.date(from: afterDateComponents),
           let day = zuluCal.date(from: components),
           day < afterDate {
            guard let nextMonth = zuluCal.date(byAdding: .month, value: 1, to: day) else {
                throw Error.invalidDate(String(string))
            }
            return zuluCal.dateComponents(in: zulu, from: nextMonth)
        }

        return components
    }
}

class HourMinuteParser {
    private let dateRef = Reference<(UInt8?, UInt8)>()

    lazy var hourRequiredRx = Regex {
        Capture(as: dateRef) {
            Repeat(.digit, count: 4)
        } transform: { string in
            let hourRange = string.startIndex...string.index(string.startIndex, offsetBy: 1)
            let minuteRange = string.index(string.startIndex, offsetBy: 2)...string.index(string.startIndex, offsetBy: 3)

            guard let hour = UInt8(string[hourRange]),
                  var minute = UInt8(string[minuteRange]) else { throw Error.invalidDate(String(string)) }

            return (hour, minute)
        }
    }

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
            let minuteRange = string.index(string.startIndex, offsetBy: 2)...string.index(string.startIndex, offsetBy: 3)

            guard let hour = UInt8(string[hourRange]),
                  let minute = UInt8(string[minuteRange]) else { throw Error.invalidDate(String(string)) }

            return (hour, minute)
        }
    }

    func parse<T>(match: Regex<T>.Match, referenceDate: Date? = nil, originalString string: String) throws -> DateComponents {
        let (hour, minute) = match[dateRef]

        guard let components = if let hour {
            applyComponents(
                .init(timeZone: zulu, hour: Int(hour), minute: Int(minute)),
                within: .day,
                ofDate: referenceDate ?? Date())
        } else {
            applyComponents(
                .init(timeZone: zulu, minute: Int(minute)),
                within: .hour,
                ofDate: referenceDate ?? Date())
        } else {
            throw Error.invalidDate(String(string))
        }

        return components
    }
}
