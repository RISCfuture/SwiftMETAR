import Foundation

actor RemarksParser {
  static let shared = RemarksParser()

  private let remarkParsers: [RemarkParser] = [
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

  private init() {}

  func parse(
    _ parts: inout [String.SubSequence],
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
    for parser in remarkParsers {
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
