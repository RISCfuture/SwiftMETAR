import Foundation

enum RemarksParser {

  /// One shared set of remark parsers, built and warmed once. Warming compiles every
  /// parser's regexes single-threaded here, so both the async and synchronous parsing
  /// paths reuse the same compiled regexes and never build them concurrently.
  static let sharedParsers: [any RemarkParser] = {
    let parsers = makeParsers()
    for parser in parsers { parser.warmUp() }
    return parsers
  }()

  /// Builds the set of remark parsers. Called once to populate ``sharedParsers``,
  /// which every parsing path then reuses.
  static func makeParsers() -> [any RemarkParser] {
    [
      ThunderstormBeginEndParser(),

      AircraftMishapParser(), CloudTypesParser(), DailyPrecipitationAmountParser(),
      DailyTemperatureExtremeParser(), HailstoneSizeParser(), HourlyPrecipitationAmountParser(),
      LightningParser(), NoSPECIParser(), ObscurationParser(),
      ObservationTypeParser(), ObservedPrecipitationParser(), ObservedVisibilityParser(),
      PeakWindsParser(), PeriodicIceAccretionAmountParser(), PeriodicPrecipitationAmountParser(),
      PrecipitationBeginEndParser(), PressureTendencyParser(), RapidPressureChangeParser(),
      RapidSnowIncreaseParser(), RunwayCeilingParser(), RunwayVisibilityParser(),
      SeaLevelPressureParser(), SectorVisibilityParser(), SensorStatusParser(),
      SignificantCloudsParser(), SixHourTemperatureExtremeParser(), SnowDepthParser(),
      SunshineDurationParser(), TemperatureDewpointParser(),
      ThunderstormLocationParser(), TornadicActivityParser(), VariableCeilingHeightParser(),
      VariablePrevailingVisibilityParser(), VariableSkyConditionParser(),
      WaterEquivalentDepthParser(),
      WindShiftParser(), RelativeHumidityParser(), WindDataEstimatedParser(),
      LastParser(), NextParser(), NoAmendmentsAfterParser(), NavalForecasterParser(),

      WindChangeParser(), VariableWindDirectionParser(),

      MaintenanceParser(), CorrectionParser(),

      NOSIGParser()
    ]
  }

  /// The synchronous, isolation-free parsing core, shared by the async parsing
  /// path and the `Codable` decode path. Both pass ``sharedParsers``.
  static func parse(
    _ parts: inout [String.SubSequence],
    using parsers: [any RemarkParser],
    date: DateComponents,
    lenientRemarks: Bool = false
  ) throws -> ([RemarkEntry], String?) {
    if parts.isEmpty { return ([], nil) }
    if parts.count == 1 && parts[0].isEmpty { return ([], nil) }  // extra space after METAR

    if lenientRemarks {
      if parts[0] == "RMK" { parts.removeFirst() }
    } else {
      guard parts.removeFirst() == "RMK" else { throw Error.badFormat }
    }
    if parts.isEmpty { return ([], nil) }

    var remarksString = parts.joined(separator: " ")
    let originalRemarksString = String(remarksString)
    var remarks = [RemarkEntry]()
    for parser in parsers {
      while let remark = try parser.parse(remarks: &remarksString, date: date) {
        remarks.append(.init(remark: remark, urgency: parser.urgency))
      }
    }

    let trimmedRemarks = remarksString.trimmingCharacters(in: .whitespaces)
    if !trimmedRemarks.isEmpty {
      remarks.append(.init(remark: .unknown(trimmedRemarks), urgency: .unknown))
    }

    parts.removeAll()
    return (remarks, originalRemarksString)
  }
}
