import Foundation
import Regex

func parsePeriod(_ parts: inout Array<String.SubSequence>, referenceDate: Date? = nil) throws -> TAF.Group.Period? {
    if let from = try parseFromPeriod(&parts, referenceDate: referenceDate ?? Date()) {
        return from
    }
    
    if let tempo = try parseTemporaryPeriod(&parts, referenceDate: referenceDate ?? Date()) {
        return tempo
    }
    
    if let tempo = try parseBecomingPeriod(&parts, referenceDate: referenceDate ?? Date()) {
        return tempo
    }
    
    if let prob = try parseProbabilityPeriod(&parts, referenceDate: referenceDate ?? Date()) {
        return prob
    }
    
    if let range = try parseRangePeriod(&parts, referenceDate: referenceDate ?? Date()) {
        return range
    }
    
    return nil
}

fileprivate let fromRx = Regex(#"^FM(\d{2}\d{2}\d{2})$"#)

fileprivate func parseFromPeriod(_ parts: inout Array<String.SubSequence>, referenceDate: Date) throws -> TAF.Group.Period? {
    guard !parts.isEmpty else { return nil }
    
    let periodStr = String(parts[0])
    guard let match = fromRx.firstMatch(in: periodStr) else { return nil }
    parts.removeFirst()
    
    guard let dayHourMinuteStr = match.captures[0] else { return nil }
    return .from(try parseDayHourMinute(dayHourMinuteStr, referenceDate: referenceDate))
}

fileprivate func parseTemporaryPeriod(_ parts: inout Array<String.SubSequence>, referenceDate: Date) throws -> TAF.Group.Period? {
    guard !parts.isEmpty else { return nil }
    guard parts[0] == "TEMPO" else { return nil }
    parts.removeFirst()
    
    guard let range = try parseRangePeriod(&parts, referenceDate: referenceDate) else {
        throw Error.invalidPeriod(String(parts[0]))
    }
    
    guard case let .range(period) = range else {
        preconditionFailure("Period enum not of type .range")
    }
    return .temporary(period)
}

fileprivate func parseBecomingPeriod(_ parts: inout Array<String.SubSequence>, referenceDate: Date) throws -> TAF.Group.Period? {
    guard !parts.isEmpty else { return nil }
    guard parts[0] == "BECMG" else { return nil }
    parts.removeFirst()
    
    guard let range = try parseRangePeriod(&parts, referenceDate: referenceDate) else {
        throw Error.invalidPeriod(String(parts[0]))
    }
    
    guard case let .range(period) = range else {
        preconditionFailure("Period enum not of type .range")
    }
    return .becoming(period)
}

fileprivate let probRx = Regex(#"^PROB(\d+)$"#)

fileprivate func parseProbabilityPeriod(_ parts: inout Array<String.SubSequence>, referenceDate: Date) throws -> TAF.Group.Period? {
    guard !parts.isEmpty else { return nil }
    
    let probStr = String(parts[0])
    guard let match = probRx.firstMatch(in: probStr) else { return nil }
    parts.removeFirst()
    
    guard let probStr = match.captures[0],
          let probability = UInt8(probStr) else { throw Error.invalidPeriod(probStr) }
    
    guard let range = try parseRangePeriod(&parts, referenceDate: referenceDate) else {
        throw Error.invalidPeriod(probStr)
    }
    
    guard case let .range(period) = range else {
        preconditionFailure("Period enum not of type .range")
    }
    return .probability(probability, period: period)
}

fileprivate let rangePeriodRx = Regex(#"^(\d{4})\/(\d{4})$"#)

fileprivate func parseRangePeriod(_ parts: inout Array<String.SubSequence>, referenceDate: Date) throws -> TAF.Group.Period? {
    guard !parts.isEmpty else { return nil }
    let periodStr = String(parts[0])
    guard let match = rangePeriodRx.firstMatch(in: periodStr) else { return nil }
    parts.removeFirst()
    
    guard let startStr = match.captures[0],
          let endStr = match.captures[1] else { throw Error.invalidPeriod(periodStr) }
    let start = try parsePeriodRangeDate(startStr, referenceDate: referenceDate)
    let end = try parsePeriodRangeDate(endStr, referenceDate: referenceDate)
    
    return .range(DateComponentsInterval(start: start, end: end))
}

fileprivate let periodRangeRx = Regex(#"^(\d{2}\d{2})$"#)

fileprivate func parsePeriodRangeDate(_ string: String, referenceDate: Date) throws -> DateComponents {
    guard let match = periodRangeRx.firstMatch(in: string),
          let dayHourStr = match.captures[0]  else { throw Error.invalidPeriod(string) }
    return try parseDayHour(dayHourStr, referenceDate: referenceDate)
}
