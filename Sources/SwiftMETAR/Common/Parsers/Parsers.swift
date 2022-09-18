import Foundation
import Regex

func parseLocationID(_ parts: inout Array<String.SubSequence>) throws -> String {
    guard !parts.isEmpty else { throw Error.badFormat }
    return String(parts.removeFirst())
}

fileprivate let dateRx = Regex(#"^(\d{2}\d{2}\d{2})Z?$"#)

func parseDate(_ parts: inout Array<String.SubSequence>, referenceDate: Date? = nil) throws -> DateComponents? {
    guard !parts.isEmpty else { throw Error.badFormat }
    
    if rangePeriodRx.matches(String(parts[0])) {
        // TAF doesn't have a date, instead rolls right on to the period (e.g., "1200/1500")
        return nil
    }
    
    let dateStr = String(parts.removeFirst())
    guard let match = dateRx.firstMatch(in: dateStr),
          let dayHourMinuteStr = match.captures[0] else { throw Error.invalidDate(dateStr) }
    return try parseDayHourMinute(dayHourMinuteStr, referenceDate: referenceDate)
}

func parseDayHourMinute(_ string: String, referenceDate: Date? = nil) throws -> DateComponents {
    let dayRange = string.startIndex...string.index(string.startIndex, offsetBy: 1)
    let hourRange = string.index(string.startIndex, offsetBy: 2)...string.index(string.startIndex, offsetBy: 3)
    let minuteRange = string.index(string.startIndex, offsetBy: 4)...string.index(string.startIndex, offsetBy: 5)
    
    guard let day = UInt8(string[dayRange]) else { throw Error.invalidDate(String(string)) }
    guard var hour = UInt8(string[hourRange]) else { throw Error.invalidDate(String(string)) }
    guard let minute = UInt8(string[minuteRange]) else { throw Error.invalidDate(String(string)) }
    
    var addDay = false
    if hour == 24 { hour = 0; addDay = true }
    
    guard let components = applyComponents(
            .init(timeZone: zulu, day: Int(day), hour: Int(hour), minute: Int(minute)),
            within: .month,
            ofDate: referenceDate ?? Date()) else {
        throw Error.invalidDate(String(string))
    }
    
    if addDay {
        guard let day = zuluCal.date(from: components) else {
            throw Error.invalidDate(String(string))
        }
        guard let nextDay = zuluCal.date(byAdding: .day, value: 1, to: day) else {
            throw Error.invalidDate(String(string))
        }
        return zuluCal.dateComponents(in: zulu, from: nextDay)
    }
    
    return components
}

func parseDayHour(_ string: String, referenceDate: Date? = nil) throws -> DateComponents {
    let dayRange = string.startIndex...string.index(string.startIndex, offsetBy: 1)
    let hourRange = string.index(string.startIndex, offsetBy: 2)...string.index(string.startIndex, offsetBy: 3)
    
    guard let day = UInt8(string[dayRange]) else { throw Error.invalidDate(String(string)) }
    guard var hour = UInt8(string[hourRange]) else { throw Error.invalidDate(String(string)) }
    
    var addDay = false
    if hour == 24 { hour = 0; addDay = true }
    
    guard let components = applyComponents(
            .init(timeZone: zulu, day: Int(day), hour: Int(hour)),
            within: .month,
            ofDate: referenceDate ?? Date()) else {
        throw Error.invalidDate(String(string))
    }
    
    if addDay {
        guard let day = zuluCal.date(from: components) else {
            throw Error.invalidDate(String(string))
        }
        guard let nextDay = zuluCal.date(byAdding: .day, value: 1, to: day) else {
            throw Error.invalidDate(String(string))
        }
        return zuluCal.dateComponents(in: zulu, from: nextDay)
    }
    
    return components
}

func parseRemarks(_ parts: inout Array<String.SubSequence>, date: DateComponents, lenientRemarks: Bool = false) throws -> Array<RemarkEntry> {
    if parts.isEmpty { return [] }
    if parts.count == 1 && parts[0] == "" { return [] } // extra space after METAR
    
    if lenientRemarks {
        if parts[0] == "RMK" { parts.removeFirst() }
    } else {
        guard parts.removeFirst() == "RMK" else { throw Error.badFormat }
    }
    if parts.isEmpty { return [] }
    
    var remarksString = parts.joined(separator: " ")
    var remarks = Array<RemarkEntry>()
    for parser in remarkParsers {
        let parserInstance = parser.init()
        while let remark = parserInstance.parse(remarks: &remarksString, date: date) {
            remarks.append(.init(remark: remark, urgency: parserInstance.urgency))
        }
    }
    
    let trimmedRemarks = remarksString.trimmingCharacters(in: .whitespaces)
    if !trimmedRemarks.isEmpty {
        remarks.append(.init(remark: .unknown(trimmedRemarks), urgency: .unknown))
    }
    
    return remarks
}
