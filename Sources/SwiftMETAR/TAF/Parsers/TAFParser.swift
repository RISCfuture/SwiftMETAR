import Foundation

func parseTAF(_ codedTAF: String, on referenceDate: Date? = nil) throws -> TAF {
    var parts = codedTAF.split(separator: .whitespacesAndNewlines)
    
    let issuance = try parseIssuance(&parts)
    let locationID = try parseLocationID(&parts)
    let date = try parseDate(&parts, referenceDate: referenceDate)
    let refDateForRemarks = date ?? Calendar.current.dateComponents(in: zulu, from: Date())
    
    var groups = Array<TAF.Group>()
    var pendingGroupRemarks = Array<String.SubSequence>()
    var temperatures = Array<TAF.Temperature>()
    var TAFRemarks = Array<RemarkEntry>()
    var TAFRemarksString: String? = nil
    
    while !parts.isEmpty {
        if let period = try parsePeriod(&parts, referenceDate: date?.date) {
            if !pendingGroupRemarks.isEmpty {
                guard !groups.isEmpty else { throw Error.badFormat }
                let (lastGroupRemarks, lastGroupRemarksStr) = try parseRemarks(&pendingGroupRemarks, date: refDateForRemarks, lenientRemarks: true)
                groups.indices.last.map {
                    groups[$0].remarks = lastGroupRemarks
                    groups[$0].remarksString = lastGroupRemarksStr
                }
            }
            
            let wind = try parseWind(&parts)
            
            let visibility = try parseVisibility(&parts)
            
            let weather = try parseWeather(&parts)
            let conditions = try parseConditions(&parts)
            
            let windshear = try parseWindshear(&parts)
            let windshearConditions = try parseWindshearConditions(&parts)
            
            var icingForecasts = Array<Icing>()
            while let icing = try parseIcing(&parts) {
                icingForecasts.append(icing)
            }
            
            var turbForecasts = Array<Turbulence>()
            while let turbulence = try parseTurbulence(&parts) {
                turbForecasts.append(turbulence)
            }
            
            let altimeter = try parseTAFAltimeter(&parts)
            
            groups.append(TAF.Group(period: period,
                                    wind: wind,
                                    visibility: visibility,
                                    weather: weather,
                                    conditions: conditions,
                                    windshear: windshear,
                                    windshearConditions: windshearConditions,
                                    icing: icingForecasts,
                                    turbulence: turbForecasts,
                                    altimeter: altimeter,
                                    remarks: [],
                                    remarksString: nil))
        } else if let temps = try parseTemperatures(&parts, date: refDateForRemarks) {
            if !pendingGroupRemarks.isEmpty {
                guard !groups.isEmpty else { throw Error.badFormat }
                let (lastGroupRemarks, lastGroupRemarksStr) = try parseRemarks(&pendingGroupRemarks, date: refDateForRemarks, lenientRemarks: true)
                groups.indices.last.map {
                    groups[$0].remarks = lastGroupRemarks
                    groups[$0].remarksString = lastGroupRemarksStr
                }
                TAFRemarks.removeAll()
                TAFRemarksString = nil
            }
            
            temperatures = temps
        } else if parts.first == "RMK" {
            (TAFRemarks, TAFRemarksString) = try parseRemarks(&parts, date: refDateForRemarks, lenientRemarks: false)
        } else {
            pendingGroupRemarks.append(parts.removeFirst())
        }
    }
    
    return TAF(text: codedTAF,
               issuance: issuance,
               airportID: locationID,
               originCalendarDate: date,
               groups: groups,
               temperatures: temperatures,
               remarks: TAFRemarks,
               remarksString: TAFRemarksString)
}

fileprivate func parseIssuance(_ parts: inout Array<String.SubSequence>) throws -> TAF.Issuance {
    guard !parts.isEmpty else { throw Error.badFormat }

    if parts[0] != "TAF" { return .routine }
    parts.removeFirst()
    guard !parts.isEmpty else { throw Error.badFormat }
    
    switch parts[0] {
        case "AMD":
            parts.removeFirst()
            return .amended
        case "COR":
            parts.removeFirst()
            return .corrected
        default:
            return .routine
    }
}
