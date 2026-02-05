import Foundation

actor TAFXMLParser {

  // MARK: - Properties

  static let shared = TAFXMLParser()

  private init() {}

  // MARK: - Type Methods

  private static func buildTAF(from entry: Entry) throws -> TAF {
    guard let stationID = entry.stationID else {
      throw Error.badFormat
    }

    let originDate: DateComponents? =
      if let issueTime = entry.issueTime {
        try XMLParsing.parseISO8601(issueTime)
      } else {
        nil
      }

    var groups = [TAF.Group]()
    for (index, forecast) in entry.forecasts.enumerated() {
      let group = try buildGroup(from: forecast, isFirst: index == 0)
      groups.append(group)
    }

    guard !groups.isEmpty else {
      throw Error.badFormat
    }

    return TAF(
      text: entry.rawText,
      issuance: .routine,
      airportID: stationID,
      originCalendarDate: originDate,
      groups: groups,
      temperatures: [],
      remarks: [],
      remarksString: entry.remarks
    )
  }

  private static func buildGroup(from forecast: ForecastEntry, isFirst: Bool) throws -> TAF.Group {
    let period = try buildPeriod(from: forecast, isFirst: isFirst)

    let wind = try XMLParsing.buildWind(
      dirDegrees: forecast.windDirDegrees,
      speedKt: forecast.windSpeedKt,
      gustKt: forecast.windGustKt
    )

    let visibility = try XMLParsing.buildVisibility(forecast.visibilityStatuteMi)
    let weather = try XMLParsing.buildWeather(forecast.wxString)
    let conditions = try XMLParsing.buildConditions(
      skyConditions: forecast.skyConditions,
      vertVisFt: forecast.vertVisFt
    )

    let windshear = buildWindshear(from: forecast)

    let turbulence = try forecast.turbulenceConditions.map { try buildTurbulence(from: $0) }
    let icing = try forecast.icingConditions.map { try buildIcing(from: $0) }

    let altimeter = try XMLParsing.buildAltimeter(forecast.altimInHg)

    return TAF.Group(
      text: nil,
      period: period,
      wind: wind,
      visibility: visibility,
      weather: weather,
      conditions: conditions,
      windshear: windshear,
      windshearConditions: false,
      icing: icing,
      turbulence: turbulence,
      altimeter: altimeter,
      remarks: [],
      remarksString: nil
    )
  }

  private static func buildPeriod(from forecast: ForecastEntry, isFirst _: Bool) throws
    -> TAF
    .Group
    .Period
  {
    guard let fromStr = forecast.timeFrom else {
      throw Error.invalidPeriod(forecast.timeTo ?? "")
    }
    guard let toStr = forecast.timeTo else {
      throw Error.invalidPeriod(fromStr)
    }
    let fromDate = try XMLParsing.parseISO8601(fromStr)
    let toDate = try XMLParsing.parseISO8601(toStr)

    let interval = DateComponentsInterval(start: fromDate, end: toDate)

    switch forecast.changeIndicator {
      case "FM":
        return .from(fromDate)
      case "TEMPO":
        return .temporary(interval)
      case "BECMG":
        return .becoming(interval)
      case "PROB":
        if let probStr = forecast.probability, let prob = UInt8(probStr) {
          return .probability(prob, period: interval)
        }
        return .probability(30, period: interval)
      default:
        // First group or absent indicator → range
        return .range(interval)
    }
  }

  private static func buildWindshear(from forecast: ForecastEntry) -> Windshear? {
    guard let heightStr = forecast.windShearHgtFtAgl,
      let height = UInt16(heightStr),
      let dirStr = forecast.windShearDirDegrees,
      let dir = UInt16(dirStr),
      let speedStr = forecast.windShearSpeedKt,
      let speed = UInt16(speedStr)
    else { return nil }

    return Windshear(
      height: height,
      wind: .direction(dir, speed: .knots(speed))
    )
  }

  private static func buildTurbulence(from entry: TurbulenceEntry) throws -> Turbulence {
    guard let intensityStr = entry.intensity else {
      throw Error.invalidTurbulence("")
    }

    var intensity = Turbulence.Intensity.none
    var location: Turbulence.Location?
    var frequency: Turbulence.Frequency?

    switch intensityStr {
      case "0":
        break
      case "1":
        intensity = .light
      case "2":
        intensity = .moderate
        location = .clearAir
        frequency = .occasional
      case "3":
        intensity = .moderate
        location = .clearAir
        frequency = .frequent
      case "4":
        intensity = .moderate
        location = .inCloud
        frequency = .occasional
      case "5":
        intensity = .moderate
        location = .inCloud
        frequency = .frequent
      case "6":
        intensity = .severe
        location = .clearAir
        frequency = .occasional
      case "7":
        intensity = .severe
        location = .clearAir
        frequency = .frequent
      case "8":
        intensity = .severe
        location = .inCloud
        frequency = .occasional
      case "9":
        intensity = .severe
        location = .inCloud
        frequency = .frequent
      case "X":
        intensity = .extreme
      default:
        throw Error.invalidTurbulence(intensityStr)
    }

    let minAlt: UInt =
      if let s = entry.minAltFtAgl, let v = UInt(s) { v } else { 0 }
    let maxAlt: UInt =
      if let s = entry.maxAltFtAgl, let v = UInt(s) { v } else { 0 }
    let depth: UInt = maxAlt > minAlt ? maxAlt - minAlt : 0

    return Turbulence(
      location: location,
      intensity: intensity,
      frequency: frequency,
      base: minAlt,
      depth: depth
    )
  }

  private static func buildIcing(from entry: IcingEntry) throws -> Icing {
    guard let intensityStr = entry.intensity else {
      throw Error.invalidIcing("")
    }
    guard let type = Icing.IcingType(rawValue: intensityStr) else {
      throw Error.invalidIcing(intensityStr)
    }

    let minAlt: UInt =
      if let s = entry.minAltFtAgl, let v = UInt(s) { v } else { 0 }
    let maxAlt: UInt =
      if let s = entry.maxAltFtAgl, let v = UInt(s) { v } else { 0 }
    let depth: UInt = maxAlt > minAlt ? maxAlt - minAlt : 0

    return Icing(type: type, base: minAlt, depth: depth)
  }

  // MARK: - Instance Methods

  func parse(data: Data) -> [XMLParseResult<TAF>] {
    let delegate = XMLDelegate()
    let xmlParser = XMLParser(data: data)
    xmlParser.delegate = delegate
    xmlParser.parse()

    return delegate.entries.map { entry in
      do {
        return .success(try Self.buildTAF(from: entry))
      } catch {
        return .failure(error, entry.rawText)
      }
    }
  }

  // MARK: - Subtypes

  private struct Entry: Sendable {
    var rawText: String?
    var stationID: String?
    var issueTime: String?
    var remarks: String?
    var forecasts: [ForecastEntry] = []
  }

  private struct ForecastEntry: Sendable {
    var changeIndicator: String?
    var timeFrom: String?
    var timeTo: String?
    var probability: String?
    var windDirDegrees: String?
    var windSpeedKt: String?
    var windGustKt: String?
    var visibilityStatuteMi: String?
    var wxString: String?
    var skyConditions: [XMLParsing.SkyCondition] = []
    var vertVisFt: String?
    var windShearHgtFtAgl: String?
    var windShearDirDegrees: String?
    var windShearSpeedKt: String?
    var turbulenceConditions: [TurbulenceEntry] = []
    var icingConditions: [IcingEntry] = []
    var altimInHg: String?
  }

  private struct TurbulenceEntry: Sendable {
    var intensity: String?
    var minAltFtAgl: String?
    var maxAltFtAgl: String?
  }

  private struct IcingEntry: Sendable {
    var intensity: String?
    var minAltFtAgl: String?
    var maxAltFtAgl: String?
  }

  private final class XMLDelegate: NSObject, XMLParserDelegate {
    var entries = [Entry]()

    private var currentEntry: Entry?
    private var currentForecast: ForecastEntry?
    private var currentElement: String?
    private var characterBuffer = ""
    private var inForecast = false

    func parser(
      _: XMLParser,
      didStartElement elementName: String,
      namespaceURI _: String?,
      qualifiedName _: String?,
      attributes attributeDict: [String: String] = [:]
    ) {
      currentElement = elementName

      if elementName == "TAF" {
        currentEntry = Entry()
      } else if elementName == "forecast" {
        currentForecast = ForecastEntry()
        inForecast = true
      } else if elementName == "sky_condition", inForecast {
        let sky = XMLParsing.SkyCondition(
          skyCover: attributeDict["sky_cover"] ?? "",
          cloudBaseFtAgl: attributeDict["cloud_base_ft_agl"],
          cloudType: attributeDict["cloud_type"]
        )
        currentForecast?.skyConditions.append(sky)
      } else if elementName == "turbulence_condition", inForecast {
        let turb = TurbulenceEntry(
          intensity: attributeDict["turbulence_intensity"],
          minAltFtAgl: attributeDict["turbulence_min_alt_ft_agl"],
          maxAltFtAgl: attributeDict["turbulence_max_alt_ft_agl"]
        )
        currentForecast?.turbulenceConditions.append(turb)
      } else if elementName == "icing_condition", inForecast {
        let ice = IcingEntry(
          intensity: attributeDict["icing_intensity"],
          minAltFtAgl: attributeDict["icing_min_alt_ft_agl"],
          maxAltFtAgl: attributeDict["icing_max_alt_ft_agl"]
        )
        currentForecast?.icingConditions.append(ice)
      }

      characterBuffer = ""
    }

    func parser(
      _: XMLParser,
      didEndElement elementName: String,
      namespaceURI _: String?,
      qualifiedName _: String?
    ) {
      let text = characterBuffer.trimmingCharacters(in: .whitespacesAndNewlines)

      if elementName == "TAF" {
        if let entry = currentEntry {
          entries.append(entry)
        }
        currentEntry = nil
      } else if elementName == "forecast" {
        if let forecast = currentForecast {
          currentEntry?.forecasts.append(forecast)
        }
        currentForecast = nil
        inForecast = false
      } else if currentEntry != nil, !text.isEmpty {
        if inForecast {
          switch elementName {
            case "change_indicator":
              currentForecast?.changeIndicator = text
            case "fcst_time_from":
              currentForecast?.timeFrom = text
            case "fcst_time_to":
              currentForecast?.timeTo = text
            case "probability":
              currentForecast?.probability = text
            case "wind_dir_degrees":
              currentForecast?.windDirDegrees = text
            case "wind_speed_kt":
              currentForecast?.windSpeedKt = text
            case "wind_gust_kt":
              currentForecast?.windGustKt = text
            case "visibility_statute_mi":
              currentForecast?.visibilityStatuteMi = text
            case "wx_string":
              currentForecast?.wxString = text
            case "vert_vis_ft":
              currentForecast?.vertVisFt = text
            case "wind_shear_hgt_ft_agl":
              currentForecast?.windShearHgtFtAgl = text
            case "wind_shear_dir_degrees":
              currentForecast?.windShearDirDegrees = text
            case "wind_shear_speed_kt":
              currentForecast?.windShearSpeedKt = text
            case "altim_in_hg":
              currentForecast?.altimInHg = text
            default:
              break
          }
        } else {
          switch elementName {
            case "raw_text":
              currentEntry?.rawText = text
            case "station_id":
              currentEntry?.stationID = text
            case "issue_time":
              currentEntry?.issueTime = text
            case "remarks":
              currentEntry?.remarks = text
            default:
              break
          }
        }
      }

      currentElement = nil
    }

    func parser(_: XMLParser, foundCharacters string: String) {
      characterBuffer += string
    }

    func parser(_: XMLParser, foundCDATA CDATABlock: Data) {
      if let string = String(data: CDATABlock, encoding: .utf8) {
        characterBuffer += string
      }
    }
  }
}
