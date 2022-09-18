import Foundation

func parsePeriod(_ parts: inout Array<String.SubSequence>, referenceDate: Date? = nil) throws -> TAF.Group.Period {
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
    
    throw Error.badFormat
}

fileprivate let fromRxStr = #"^FM(\d{2}\d{2}\d{2})$"#
fileprivate let fromRx = try! NSRegularExpression(pattern: fromRxStr, options: [])

fileprivate func parseFromPeriod(_ parts: inout Array<String.SubSequence>, referenceDate: Date) throws -> TAF.Group.Period? {
    guard !parts.isEmpty else { return nil }
    
    let periodStr = String(parts[0])
    guard let match = fromRx.firstMatch(in: periodStr, options: [], range: periodStr.nsRange) else {
        return nil
    }
    parts.removeFirst()
    
    return .from(try parseDayHourMinute(periodStr.substring(with: match.range(at: 1)), referenceDate: referenceDate))
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

fileprivate let probRxStr = #"^PROB(\d+)$"#
fileprivate let probRx = try! NSRegularExpression(pattern: probRxStr, options: [])

fileprivate func parseProbabilityPeriod(_ parts: inout Array<String.SubSequence>, referenceDate: Date) throws -> TAF.Group.Period? {
    guard !parts.isEmpty else { return nil }
    
    let probStr = String(parts[0])
    guard let match = probRx.firstMatch(in: probStr, options: [], range: probStr.nsRange) else {
        return nil
    }
    parts.removeFirst()
    guard let probability = UInt8(probStr.substring(with: match.range(at: 1))) else {
        throw Error.invalidPeriod(probStr)
    }
    
    guard let range = try parseRangePeriod(&parts, referenceDate: referenceDate) else {
        throw Error.invalidPeriod(probStr)
    }
    
    guard case let .range(period) = range else {
        preconditionFailure("Period enum not of type .range")
    }
    return .probability(probability, period: period)
}

fileprivate let rangePeriodRxStr = #"^(\d{4})\/(\d{4})$"#
fileprivate let rangePeriodRx = try! NSRegularExpression(pattern: rangePeriodRxStr, options: [])

fileprivate func parseRangePeriod(_ parts: inout Array<String.SubSequence>, referenceDate: Date) throws -> TAF.Group.Period? {
    guard !parts.isEmpty else { return nil }
    let periodStr = String(parts[0])
    guard let match = rangePeriodRx.firstMatch(in: periodStr, options: [], range: periodStr.nsRange) else {
        return nil
    }
    parts.removeFirst()
    
    let startStr = String(periodStr.substring(with: match.range(at: 1)))
    let start = try parsePeriodRangeDate(startStr, referenceDate: referenceDate)
    let endStr = String(periodStr.substring(with: match.range(at: 2)))
    let end = try parsePeriodRangeDate(endStr, referenceDate: referenceDate)
    
    return .range(DateComponentsInterval(start: start, end: end))
}

fileprivate let periodRangeRxStr = #"^(\d{2}\d{2})$"#
fileprivate let periodRangeRx = try! NSRegularExpression(pattern: periodRangeRxStr, options: [])

fileprivate func parsePeriodRangeDate(_ string: String, referenceDate: Date) throws -> DateComponents {
    guard let match = periodRangeRx.firstMatch(in: string, options: [], range: string.nsRange) else {
        throw Error.invalidPeriod(string)
    }
    return try parseDayHour(string.substring(with: match.range(at: 1)), referenceDate: referenceDate)
}
