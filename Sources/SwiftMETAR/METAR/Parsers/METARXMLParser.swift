import Foundation

actor METARXMLParser {

  // MARK: - Properties

  static let shared = METARXMLParser()

  private init() {}

  // MARK: - Type Methods

  private static func buildMETAR(from entry: Entry) throws -> METAR {
    guard let stationID = entry.stationID else {
      throw Error.badFormat
    }
    guard let observationTime = entry.observationTime else {
      throw Error.invalidDate("")
    }
    let calendarDate = try XMLParsing.parseISO8601(observationTime)

    let issuance: METAR.Issuance =
      switch entry.metarType {
        case "SPECI": .special
        default: .routine
      }

    let observer: METAR.Observer =
      if entry.corrected { .corrected } else if entry.auto { .automated } else { .human }

    let wind = try XMLParsing.buildWind(
      dirDegrees: entry.windDirDegrees,
      speedKt: entry.windSpeedKt,
      gustKt: entry.windGustKt
    )

    let visibility = try XMLParsing.buildVisibility(entry.visibilityStatuteMi)

    let weather = try XMLParsing.buildWeather(entry.wxString)

    let conditions = try XMLParsing.buildConditions(
      skyConditions: entry.skyConditions,
      vertVisFt: entry.vertVisFt
    )

    let temperature: Int8? =
      if let tempStr = entry.tempC, let tempFloat = Float(tempStr) {
        Int8(tempFloat.roundedHalfTowardZero())
      } else {
        nil
      }

    let dewpoint: Int8? =
      if let dewStr = entry.dewpointC, let dewFloat = Float(dewStr) {
        Int8(dewFloat.roundedHalfTowardZero())
      } else {
        nil
      }

    let altimeter = try XMLParsing.buildAltimeter(entry.altimInHg)

    return METAR(
      text: entry.rawText,
      issuance: issuance,
      stationID: stationID,
      calendarDate: calendarDate,
      observer: observer,
      wind: wind,
      visibility: visibility,
      runwayVisibility: [],
      weather: weather,
      conditions: conditions,
      temperature: temperature,
      dewpoint: dewpoint,
      altimeter: altimeter,
      remarks: [],
      remarksString: nil
    )
  }

  // MARK: - Instance Methods

  func parse(data: Data) -> [XMLParseResult<METAR>] {
    let delegate = XMLDelegate()
    let xmlParser = XMLParser(data: data)
    xmlParser.delegate = delegate
    xmlParser.parse()

    return delegate.entries.map { entry in
      do {
        return .success(try Self.buildMETAR(from: entry))
      } catch {
        return .failure(error, entry.rawText)
      }
    }
  }

  // MARK: - Subtypes

  private struct Entry: Sendable {
    var rawText: String?
    var metarType: String?
    var stationID: String?
    var observationTime: String?
    var corrected: Bool = false
    var auto: Bool = false
    var windDirDegrees: String?
    var windSpeedKt: String?
    var windGustKt: String?
    var visibilityStatuteMi: String?
    var wxString: String?
    var skyConditions: [XMLParsing.SkyCondition] = []
    var vertVisFt: String?
    var tempC: String?
    var dewpointC: String?
    var altimInHg: String?
  }

  private final class XMLDelegate: NSObject, XMLParserDelegate {
    var entries = [Entry]()

    private var currentEntry: Entry?
    private var currentElement: String?
    private var characterBuffer = ""
    private var inQualityControlFlags = false

    func parser(
      _: XMLParser,
      didStartElement elementName: String,
      namespaceURI _: String?,
      qualifiedName _: String?,
      attributes attributeDict: [String: String] = [:]
    ) {
      currentElement = elementName

      if elementName == "METAR" {
        currentEntry = Entry()
      } else if elementName == "quality_control_flags" {
        inQualityControlFlags = true
      } else if elementName == "sky_condition", currentEntry != nil {
        var sky = XMLParsing.SkyCondition(skyCover: attributeDict["sky_cover"] ?? "")
        sky.cloudBaseFtAgl = attributeDict["cloud_base_ft_agl"]
        sky.cloudType = attributeDict["cloud_type"]
        currentEntry?.skyConditions.append(sky)
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

      if elementName == "METAR" {
        if let entry = currentEntry {
          entries.append(entry)
        }
        currentEntry = nil
      } else if elementName == "quality_control_flags" {
        inQualityControlFlags = false
      } else if currentEntry != nil, !text.isEmpty {
        if inQualityControlFlags {
          switch elementName {
            case "corrected":
              if text == "TRUE" { currentEntry?.corrected = true }
            case "auto":
              if text == "TRUE" { currentEntry?.auto = true }
            default:
              break
          }
        } else {
          switch elementName {
            case "raw_text":
              currentEntry?.rawText = text
            case "metar_type":
              currentEntry?.metarType = text
            case "station_id":
              currentEntry?.stationID = text
            case "observation_time":
              currentEntry?.observationTime = text
            case "wind_dir_degrees":
              currentEntry?.windDirDegrees = text
            case "wind_speed_kt":
              currentEntry?.windSpeedKt = text
            case "wind_gust_kt":
              currentEntry?.windGustKt = text
            case "visibility_statute_mi":
              currentEntry?.visibilityStatuteMi = text
            case "wx_string":
              currentEntry?.wxString = text
            case "vert_vis_ft":
              currentEntry?.vertVisFt = text
            case "temp_c":
              currentEntry?.tempC = text
            case "dewpoint_c":
              currentEntry?.dewpointC = text
            case "altim_in_hg":
              currentEntry?.altimInHg = text
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
