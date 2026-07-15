import Foundation

actor TAFParser {
  static let shared = TAFParser()

  nonisolated private static let periodParser = warmed(PeriodParser())
  nonisolated private static let visibilityParser = warmed(VisibilityParser())
  nonisolated private static let weatherParser = warmed(WeatherParser())
  nonisolated private static let conditionsParser = warmed(ConditionsParser())
  nonisolated private static let windshearParser = warmed(WindshearParser())
  nonisolated private static let icingParser = warmed(IcingParser())
  nonisolated private static let turbulenceParser = warmed(TurbulenceParser())
  nonisolated private static let altimeterParser = warmed(AltimeterParser())
  nonisolated private static let temperatureParser = warmed(TAFTemperatureParser())
  nonisolated private static let dateParser = warmed(DayHourMinuteParser())

  private init() {}

  /// Parses a TAF synchronously. Used by the synchronous `Codable` decode path; shares
  /// the same cached parsers as the async path.
  static func parseSynchronously(_ codedTAF: String, on referenceDate: Date? = nil) throws -> TAF {
    try assemble(codedTAF, referenceDate: referenceDate) { parts, date, lenient in
      try RemarksParser.parse(
        &parts,
        using: RemarksParser.sharedParsers,
        date: date,
        lenientRemarks: lenient
      )
    }
  }

  /// The isolation-free parsing core, shared by the async and synchronous paths.
  /// Only `parseRemarks` differs between callers.
  private static func assemble(
    _ codedTAF: String,
    referenceDate: Date?,
    parseRemarks: (_ parts: inout [Substring], _ date: DateComponents, _ lenient: Bool) throws -> (
      [RemarkEntry], String?
    )
  ) throws -> TAF {
    var parts = codedTAF.split(separator: .whitespacesAndNewlines)

    let issuance = try parseIssuance(&parts)
    let locationID = try parseLocationID(&parts)
    let date: DateComponents? =
      if try dateParser.matchesNext(parts) {
        try dateParser.parse(&parts, referenceDate: referenceDate)
      } else {
        nil
      }
    let refDateForRemarks = date ?? zuluCal.dateComponents(in: zulu, from: Date())

    var groups = [TAF.Group]()
    var pendingGroupRemarks = [String.SubSequence]()
    var temperatures = [TAF.Temperature]()
    var TAFRemarks = [RemarkEntry]()
    var TAFRemarksString: String?

    var originalParts = Array(parts)

    while !parts.isEmpty {
      if let period = try periodParser.parse(&parts, referenceDate: date?.date) {
        if !pendingGroupRemarks.isEmpty {
          guard !groups.isEmpty else { throw Error.badFormat }
          let (lastGroupRemarks, lastGroupRemarksStr) = try parseRemarks(
            &pendingGroupRemarks,
            refDateForRemarks,
            true
          )
          groups.indices.last.map { i in
            groups[i].remarks = lastGroupRemarks
            groups[i].remarksString = lastGroupRemarksStr
          }
        }

        let wind = try WindParser.parse(&parts)

        let visibility = try visibilityParser.parse(&parts)

        let weather = try weatherParser.parse(&parts)
        let conditions = try conditionsParser.parse(&parts)

        let windshear = try windshearParser.parse(&parts)
        let windshearConditions = try parseWindshearConditions(&parts)

        var icingForecasts = [Icing]()
        while let icing = try icingParser.parse(&parts) {
          icingForecasts.append(icing)
        }

        var turbForecasts = [Turbulence]()
        while let turbulence = try turbulenceParser.parse(&parts) {
          turbForecasts.append(turbulence)
        }

        let altimeter = try altimeterParser.parseTAF(&parts)

        let removedParts = parts.removedItems(from: originalParts)
        originalParts = Array(parts)
        groups.append(
          TAF.Group(
            text: removedParts.joined(separator: " "),
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
            remarksString: nil
          )
        )
      } else if let temps = try temperatureParser.parse(&parts, date: refDateForRemarks) {
        if !pendingGroupRemarks.isEmpty {
          guard !groups.isEmpty else { throw Error.badFormat }
          let (lastGroupRemarks, lastGroupRemarksStr) = try parseRemarks(
            &pendingGroupRemarks,
            refDateForRemarks,
            true
          )
          groups.indices.last.map { i in
            groups[i].remarks = lastGroupRemarks
            groups[i].remarksString = lastGroupRemarksStr
          }
          TAFRemarks.removeAll()
          TAFRemarksString = nil
        }

        temperatures = temps
      } else if parts.first == "RMK" {
        (TAFRemarks, TAFRemarksString) = try parseRemarks(&parts, refDateForRemarks, false)
      } else {
        pendingGroupRemarks.append(parts.removeFirst())
      }
    }

    return TAF(
      text: codedTAF,
      issuance: issuance,
      airportID: locationID,
      originCalendarDate: date,
      groups: groups,
      temperatures: temperatures,
      remarks: TAFRemarks,
      remarksString: TAFRemarksString
    )
  }

  /// Parses a single forecast group from its coded string (e.g.
  /// `"FM130200 05005KT P6SM SCT040"`), synchronously. Used by
  /// `TAF.Group.init(coded:)`.
  static func parseGroup(_ coded: String) throws -> TAF.Group {
    var parts = coded.split(separator: .whitespacesAndNewlines)
    guard let period = try periodParser.parse(&parts, referenceDate: nil) else {
      throw Error.invalidPeriod(coded)
    }

    let wind = try WindParser.parse(&parts)
    let visibility = try visibilityParser.parse(&parts)
    let weather = try weatherParser.parse(&parts)
    let conditions = try conditionsParser.parse(&parts)
    let windshear = try windshearParser.parse(&parts)
    let windshearConditions = try parseWindshearConditions(&parts)

    var icing = [Icing]()
    while let forecast = try icingParser.parse(&parts) { icing.append(forecast) }
    var turbulence = [Turbulence]()
    while let forecast = try turbulenceParser.parse(&parts) { turbulence.append(forecast) }

    let altimeter = try altimeterParser.parseTAF(&parts)

    var remarks = [RemarkEntry]()
    var remarksString: String?
    if !parts.isEmpty {
      let date = zuluCal.dateComponents(in: zulu, from: Date())
      (remarks, remarksString) = try RemarksParser.parse(
        &parts,
        using: RemarksParser.sharedParsers,
        date: date,
        lenientRemarks: true
      )
    }

    return TAF.Group(
      text: coded,
      period: period,
      wind: wind,
      visibility: visibility,
      weather: weather,
      conditions: conditions,
      windshear: windshear,
      windshearConditions: windshearConditions,
      icing: icing,
      turbulence: turbulence,
      altimeter: altimeter,
      remarks: remarks,
      remarksString: remarksString
    )
  }

  private static func parseIssuance(_ parts: inout [String.SubSequence]) throws -> TAF.Issuance {
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

  func parse(_ codedTAF: String, on referenceDate: Date? = nil) throws -> TAF {
    try Self.assemble(codedTAF, referenceDate: referenceDate) { parts, date, lenient in
      try RemarksParser.parse(
        &parts,
        using: RemarksParser.sharedParsers,
        date: date,
        lenientRemarks: lenient
      )
    }
  }
}
