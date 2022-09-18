import Foundation

func parseMETAR(_ codedMETAR: String, on referenceDate: Date? = nil, lenientRemarks: Bool = false) throws -> METAR {
    var parts = codedMETAR.split(separator: .whitespacesAndNewlines)
    let issuance = try parseIssuance(&parts)
    let stationID = try parseLocationID(&parts)
    let date = try parseDate(&parts, referenceDate: referenceDate)!
    let observer = try parseObserver(&parts)
    let wind = try parseWind(&parts)
    let visibility = try parseVisibility(&parts)
    let runwayViz = try parseRunwayVisibility(&parts)
    let weather = try parseWeather(&parts)
    let conditions = try parseConditions(&parts)
    let tempDewpoint = try parseTempDewpoint(&parts)
    let altimeter = try parseMETARAltimeter(&parts)
    let remarks = try parseRemarks(&parts, date: date, lenientRemarks: lenientRemarks)
    
    return METAR(text: codedMETAR,
                 issuance: issuance,
                 stationID: stationID,
                 calendarDate: date,
                 observer: observer,
                 wind: wind,
                 visibility: visibility,
                 runwayVisibility: runwayViz,
                 weather: weather,
                 conditions: conditions,
                 temperature: tempDewpoint.0,
                 dewpoint: tempDewpoint.1,
                 altimeter: altimeter,
                 remarks: remarks)
}

fileprivate func parseIssuance(_ parts: inout Array<String.SubSequence>) throws -> METAR.Issuance {
    guard !parts.isEmpty else { throw Error.badFormat }
    
    let typeCode = String(parts[0])
    guard let type = METAR.Issuance(rawValue: typeCode) else {
        return .routine
    }
    parts.removeFirst()
    return type
}

fileprivate func parseObserver(_ parts: inout Array<String.SubSequence>) throws -> METAR.Observer {
    guard !parts.isEmpty else { throw Error.badFormat }
    
    let observer = METAR.Observer(rawValue: String(parts[0]))
    if observer != nil { parts.removeFirst() }
    return observer ?? .human
}
