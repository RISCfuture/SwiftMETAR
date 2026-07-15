import Foundation

actor METARParser {
  static let shared = METARParser()

  nonisolated private static let visibilityParser = warmed(VisibilityParser())
  nonisolated private static let rvrParser = warmed(RVRParser())
  nonisolated private static let weatherParser = warmed(WeatherParser())
  nonisolated private static let conditionsParser = warmed(ConditionsParser())
  nonisolated private static let temperatureParser = warmed(METARTemperatureParser())
  nonisolated private static let altimeterParser = warmed(AltimeterParser())
  nonisolated private static let dateParser = warmed(DayHourMinuteParser())

  private init() {}

  /// Parses a METAR synchronously off the actor, using the shared warmed parsers.
  /// Used by the synchronous `Codable` decode path.
  static func parseSynchronously(
    _ codedMETAR: String,
    on referenceDate: Date? = nil,
    lenientRemarks: Bool = false
  ) throws -> METAR {
    let remarkParsers = RemarksParser.sharedParsers
    return try assemble(codedMETAR, referenceDate: referenceDate) { parts, date in
      try RemarksParser.parse(
        &parts,
        using: remarkParsers,
        date: date,
        lenientRemarks: lenientRemarks
      )
    }
  }

  /// The isolation-free parsing core, shared by the async and synchronous paths.
  /// It matches against the shared warmed component-parser singletons; only
  /// `parseRemarks` differs between callers.
  private static func assemble(
    _ codedMETAR: String,
    referenceDate: Date?,
    parseRemarks: (_ parts: inout [Substring], _ date: DateComponents) throws -> (
      [RemarkEntry], String?
    )
  ) throws -> METAR {
    var parts = codedMETAR.split(separator: .whitespacesAndNewlines)
    let issuance = try parseIssuance(&parts)
    let stationID = try parseLocationID(&parts)
    let date = try dateParser.parse(&parts, referenceDate: referenceDate)
    let observer = try parseObserver(&parts)
    let wind = try orMissing(&parts, defaultValue: nil) { try WindParser.parse(&$0) }

    let visibility: Visibility?
    let runwayViz: [RunwayVisibility]
    let weather: [Weather]?
    let conditions: [Condition]
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
    let tempDewpoint = try orMissing(&parts, defaultValue: (nil, nil)) {
      try temperatureParser.parse(&$0)
    }
    let altimeter = try orMissing(&parts, defaultValue: nil) { try altimeterParser.parseMETAR(&$0) }
    let (remarks, remarksString) = try parseRemarks(&parts, date)

    return METAR(
      text: codedMETAR,
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
      remarksString: remarksString
    )
  }

  private static func parseIssuance(_ parts: inout [String.SubSequence]) throws -> METAR.Issuance {
    guard !parts.isEmpty else { throw Error.badFormat }

    let typeCode = String(parts[0])
    guard let type = METAR.Issuance(rawValue: typeCode) else {
      return .routine
    }
    parts.removeFirst()
    return type
  }

  private static func parseObserver(_ parts: inout [String.SubSequence]) throws -> METAR.Observer {
    guard !parts.isEmpty else { throw Error.badFormat }

    let observer = METAR.Observer(rawValue: String(parts[0]))
    if observer != nil { parts.removeFirst() }
    return observer ?? .human
  }

  private static func orMissing<T>(
    _ parts: inout [Substring],
    defaultValue: T,
    _ parser: (_ parts: inout [Substring]) throws -> T
  ) rethrows -> T {
    if parts.first == "M" {
      parts.removeFirst()
      return defaultValue
    }
    return try parser(&parts)
  }

  func parse(_ codedMETAR: String, on referenceDate: Date? = nil, lenientRemarks: Bool = false)
    throws -> METAR
  {
    try Self.assemble(codedMETAR, referenceDate: referenceDate) { parts, date in
      try RemarksParser.parse(
        &parts,
        using: RemarksParser.sharedParsers,
        date: date,
        lenientRemarks: lenientRemarks
      )
    }
  }
}
