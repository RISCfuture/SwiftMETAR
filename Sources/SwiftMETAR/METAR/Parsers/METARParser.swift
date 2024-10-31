import Foundation

actor METARParser {
    static let shared = METARParser()

    private let windParser = WindParser()
    private let visibilityParser = VisibilityParser()
    private let rvrParser = RVRParser()
    private let weatherParser = WeatherParser()
    private let conditionsParser = ConditionsParser()
    private let temperatureParser = METARTemperatureParser()
    private let altimeterParser = AltimeterParser()

    private init() {}

    func parse(_ codedMETAR: String, on referenceDate: Date? = nil, lenientRemarks: Bool = false) async throws -> METAR {
        var parts = codedMETAR.split(separator: .whitespacesAndNewlines)
        let issuance = try parseIssuance(&parts)
        let stationID = try parseLocationID(&parts)
        let date = try DayHourMinuteParser().parse(&parts, referenceDate: referenceDate)
        let observer = try parseObserver(&parts)
        let wind = try orMissing(&parts, defaultValue: nil) { try windParser.parse(&$0) }

        let visibility: Visibility?,
            runwayViz: Array<RunwayVisibility>,
            weather: Array<Weather>?,
            conditions: Array<Condition>
        if parts.first == "CAVOK" {
            parts.removeFirst()
            visibility = .greaterThan(.meters(9999))
            runwayViz = []
            weather = []
            conditions = [.cavok]
        } else {
            visibility = try orMissing(&parts, defaultValue: nil) { try visibilityParser.parse(&$0) }
            runwayViz = try rvrParser.parse(&parts)
            weather = try orMissing(&parts, defaultValue: nil) { try weatherParser.parse(&$0) }
            conditions = try orMissing(&parts, defaultValue: []) { try conditionsParser.parse(&$0) }
        }
        let tempDewpoint = try orMissing(&parts, defaultValue: (nil, nil)) { try temperatureParser.parse(&$0) }
        let altimeter = try orMissing(&parts, defaultValue: nil) { try altimeterParser.parseMETAR(&$0) }
        let (remarks, remarksString) = try await RemarksParser.shared.parse(&parts, date: date, lenientRemarks: lenientRemarks)

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
                     remarks: remarks,
                     remarksString: remarksString)
    }

    private func parseIssuance(_ parts: inout Array<String.SubSequence>) throws -> METAR.Issuance {
        guard !parts.isEmpty else { throw Error.badFormat }

        let typeCode = String(parts[0])
        guard let type = METAR.Issuance(rawValue: typeCode) else {
            return .routine
        }
        parts.removeFirst()
        return type
    }

    private func parseObserver(_ parts: inout Array<String.SubSequence>) throws -> METAR.Observer {
        guard !parts.isEmpty else { throw Error.badFormat }

        let observer = METAR.Observer(rawValue: String(parts[0]))
        if observer != nil { parts.removeFirst() }
        return observer ?? .human
    }

    private func orMissing<T>(_ parts: inout Array<Substring>, defaultValue: T, _ parser: (_ parts: inout Array<Substring>) throws -> T) rethrows -> T {
        if parts.first == "M" {
            parts.removeFirst()
            return defaultValue
        }
        return try parser(&parts)
    }
}
