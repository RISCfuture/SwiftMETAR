import Foundation

actor TAFParser {
    static let shared = TAFParser()

    private let periodParser = PeriodParser()
    private let windParser = WindParser()
    private let visibilityParser = VisibilityParser()
    private let weatherParser = WeatherParser()
    private let conditionsParser = ConditionsParser()
    private let windshearParser = WindshearParser()
    private let icingParser = IcingParser()
    private let turbulenceParser = TurbulenceParser()
    private let altimeterParser = AltimeterParser()
    private let temperatureParser = TAFTemperatureParser()

    private init() {}

    func parse(_ codedTAF: String, on referenceDate: Date? = nil) async throws -> TAF {
        var parts = codedTAF.split(separator: .whitespacesAndNewlines)

        let issuance = try parseIssuance(&parts)
        let locationID = try parseLocationID(&parts)
        let dateParser = DayHourMinuteParser()
        let date: DateComponents? = if try dateParser.matchesNext(parts) {
            try DayHourMinuteParser().parse(&parts, referenceDate: referenceDate)
        } else {
            nil
        }
        let refDateForRemarks = date ?? zuluCal.dateComponents(in: zulu, from: Date())

        var groups = Array<TAF.Group>()
        var pendingGroupRemarks = Array<String.SubSequence>()
        var temperatures = Array<TAF.Temperature>()
        var TAFRemarks = Array<RemarkEntry>()
        var TAFRemarksString: String? = nil

        var originalParts = Array(parts)

        while !parts.isEmpty {
            if let period = try periodParser.parse(&parts, referenceDate: date?.date) {
                if !pendingGroupRemarks.isEmpty {
                    guard !groups.isEmpty else { throw Error.badFormat }
                    let (lastGroupRemarks, lastGroupRemarksStr) = try await RemarksParser.shared.parse(&pendingGroupRemarks, date: refDateForRemarks, lenientRemarks: true)
                    groups.indices.last.map {
                        groups[$0].remarks = lastGroupRemarks
                        groups[$0].remarksString = lastGroupRemarksStr
                    }
                }

                let wind = try windParser.parse(&parts)

                let visibility = try visibilityParser.parse(&parts)

                let weather = try weatherParser.parse(&parts)
                let conditions = try conditionsParser.parse(&parts)

                let windshear = try windshearParser.parse(&parts)
                let windshearConditions = try parseWindshearConditions(&parts)

                var icingForecasts = Array<Icing>()
                while let icing = try icingParser.parse(&parts) {
                    icingForecasts.append(icing)
                }

                var turbForecasts = Array<Turbulence>()
                while let turbulence = try turbulenceParser.parse(&parts) {
                    turbForecasts.append(turbulence)
                }

                let altimeter = try altimeterParser.parseTAF(&parts)

                let removedParts = parts.removedItems(from: originalParts)
                originalParts = Array(parts)
                groups.append(TAF.Group(text: removedParts.joined(separator: " "),
                                        period: period,
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
            } else if let temps = try temperatureParser.parse(&parts, date: refDateForRemarks) {
                if !pendingGroupRemarks.isEmpty {
                    guard !groups.isEmpty else { throw Error.badFormat }
                    let (lastGroupRemarks, lastGroupRemarksStr) = try await RemarksParser.shared.parse(&pendingGroupRemarks, date: refDateForRemarks, lenientRemarks: true)
                    groups.indices.last.map {
                        groups[$0].remarks = lastGroupRemarks
                        groups[$0].remarksString = lastGroupRemarksStr
                    }
                    TAFRemarks.removeAll()
                    TAFRemarksString = nil
                }

                temperatures = temps
            } else if parts.first == "RMK" {
                (TAFRemarks, TAFRemarksString) = try await RemarksParser.shared.parse(&parts, date: refDateForRemarks, lenientRemarks: false)
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

    private func parseIssuance(_ parts: inout Array<String.SubSequence>) throws -> TAF.Issuance {
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
}
