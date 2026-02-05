import ArgumentParser
import Foundation
import METARFormatting
import SwiftMETAR

enum InputFormat: String, ExpressibleByArgument, CaseIterable {
  case text = "txt"
  case xml
}

enum OutputFormat: String, ExpressibleByArgument, CaseIterable {
  case text = "txt"
  case json
}

@available(macOS 15.0, *)
@main
struct DecodeMETAR: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    abstract: "Decodes a METAR into human-readable text.",
    discussion: """
      This tool can be used with an airport code (in ICAO format [i.e., include the "K"]),
      in which case it will download the latest METARs from AWC; or it can be used with
      a raw METAR string, in which case that string will be parsed.
      """
  )

  @Argument(help: "The ICAO code of an airport, or a METAR string to decode")
  var airportCodeOrMETAR: String?

  @Option(
    name: [.customLong("metar-url"), .short],
    help: "The URL to load the METAR CSV from.",
    transform: { .init(string: $0)! }
  )
  var METAR_URL = URL(string: "https://aviationweather.gov/data/cache/metars.cache.csv")!

  @Option(
    name: .customLong("metar-xml-url"),
    help: "The URL to load the METAR XML from.",
    transform: { .init(string: $0)! }
  )
  var METAR_XML_URL = URL(string: "https://aviationweather.gov/data/cache/metars.cache.xml")!

  @Option(name: .long, help: "Input format (txt or xml)")
  var format: InputFormat = .text

  @Option(name: .long, help: "Output format (txt or json)")
  var output: OutputFormat = .text

  @Flag(name: .long, inversion: .prefixedNo, help: "Include raw METAR text")
  var raw = false

  @Flag(name: .shortAndLong, inversion: .prefixedNo, help: "Include remarks")
  var remarks = true

  @Flag(name: .long, help: "Parse and decode all METARs (!)")
  var all = false

  @Flag(
    name: .long,
    help: "Only show stations with parsing errors (intended to be used with `--all`"
  )
  var errorsOnly = false

  private var session: URLSession { .init(configuration: .ephemeral) }

  func run() async throws {
    if format == .xml && !all {
      throw ValidationError("--format xml requires --all")
    }
    try await all ? parseAll() : parsePrompt()
  }

  private func parseAll() async throws {
    if format == .xml {
      let metars = try await loadMETARsFromXML { raw, error in
        print(raw ?? "unknown")
        print("  Parse error: \(error.localizedDescription)")
        print()
      }
      switch output {
        case .text:
          if !errorsOnly {
            for metar in metars { printMETAR(metar) }
          }
        case .json:
          try printJSON(metars)
      }
    } else {
      let METARs = try await loadMETARs { raw, error in
        print(raw)
        print("  Parse error: \(error.localizedDescription)")
        print()
      }
      switch output {
        case .text:
          if !errorsOnly {
            for metar in METARs.values { printMETAR(metar) }
          }
        case .json:
          try printJSON(Array(METARs.values))
      }
    }
  }

  private func parsePrompt() async throws {
    let airportCodeOrMETAR = promptMETAR()
    let metar =
      try await airportCodeOrMETAR.count == 4
      ? parse(code: airportCodeOrMETAR) : parse(raw: airportCodeOrMETAR)
    switch output {
      case .text: printMETAR(metar)
      case .json: try printJSON(metar)
    }
  }

  private func promptMETAR() -> String {
    var airportCodeOrMETAR = self.airportCodeOrMETAR

    while airportCodeOrMETAR == nil || airportCodeOrMETAR!.isEmpty {
      print("Enter airport code or METAR: ", terminator: "")
      airportCodeOrMETAR = readLine(strippingNewline: true)
    }

    return airportCodeOrMETAR!
  }

  private func parse(code: String) async throws -> METAR {
    guard let metar = try await getMETAR(airportCode: code) else {
      throw Errors.unknownAirportID(code)
    }
    return metar
  }

  private func parse(raw: String) async throws -> METAR {
    try await METAR.from(string: raw)
  }

  private func loadMETARsFromXML(
    errorHandler: (String?, Swift.Error) -> Void
  ) async throws -> [METAR] {
    logMessage("Loading METARs from XML…\n")

    let (data, response) = try await session.data(from: METAR_XML_URL)
    guard let response = response as? HTTPURLResponse else {
      throw Errors.badResponse(response)
    }
    guard response.statusCode / 100 == 2 else {
      throw Errors.badStatus(response: response)
    }

    var metars = [METAR]()
    for await result in METAR.from(xml: data) {
      switch result {
        case .success(let metar):
          metars.append(metar)
        case .failure(let error, _):
          errorHandler(nil, error)
      }
    }
    return metars
  }

  private func loadMETARs(errorHandler: ((String, Swift.Error) throws -> Void)) async throws
    -> [String: METAR]
  {
    logMessage("Loading METARs…\n")

    let (data, response) = try await session.bytes(from: METAR_URL)
    guard let response = response as? HTTPURLResponse else {
      throw Errors.badResponse(response)
    }
    guard response.statusCode / 100 == 2 else {
      throw Errors.badStatus(response: response)
    }

    var METARs = [String: METAR]()
    for try await line in data.lines {
      let columns = line.split(separator: ",", maxSplits: 2)
      guard columns.count >= 2 else { continue }

      // Column 0: raw_text (quoted), Column 1: station_id
      let stationID = String(columns[1])
      guard stationID.starts(with: "K") else { continue }

      // Strip quotes from raw_text
      var rawText = String(columns[0])
      if rawText.hasPrefix("\"") { rawText.removeFirst() }
      if rawText.hasSuffix("\"") { rawText.removeLast() }

      do {
        let metar = try await METAR.from(string: rawText)
        METARs[metar.stationID] = metar
      } catch {
        try errorHandler(rawText, error)
      }
    }

    return METARs
  }

  private func getMETAR(airportCode: String) async throws -> METAR? {
    let METARs = try await loadMETARs { raw, _ in
      // Raw text format: "METAR KSFO ..." or "SPECI KSFO ..."
      if raw.contains(" \(airportCode) ") {
        throw Errors.badMETAR(raw: raw)
      }
    }

    return METARs[airportCode]
  }

  private func printMETAR(_ metar: METAR) {
    print("Airport: \(metar.stationID)")
    if raw, let text = metar.text {
      print(text)
    }

    lprint("Issued: \(metar.date, format: .dateTime) (\(metar.issuance, format: .issuance))")
    lprint("Observer: \(metar.observer, format: .observer)")
    if let wind = metar.wind {
      lprint("Wind: \(wind, format: .wind)")
    }
    if let visibility = metar.visibility {
      lprint("Visibility: \(visibility, format: .visibility)")
    }
    for visibility in metar.runwayVisibility {
      lprint("\(visibility.runwayID) Visibility: \(visibility.visibility, format: .visibility)")
    }
    if let weathers = metar.weather, !weathers.isEmpty {
      lprint("Weather: \(weathers, format: .list(memberStyle: .weather, type: .and))")
    }
    if !metar.conditions.isEmpty {
      lprint("Conditions: \(metar.conditions, format: .list(memberStyle: .condition, type: .and))")
    }
    if let temperature = metar.temperatureMeasurement {
      lprint(
        "Temperature: \(temperature, format: .measurement(width: .abbreviated, usage: .asProvided))"
      )
    }
    if let dewpoint = metar.dewpointMeasurement {
      lprint("Dewpoint: \(dewpoint, format: .measurement(width: .abbreviated, usage: .asProvided))")
    }
    if let altimeter = metar.altimeter?.measurement {
      lprint(
        "Altimeter: \(altimeter, format: .measurement(width: .abbreviated, usage: .asProvided))"
      )
    }

    if remarks {
      print()
      printRemarks(metar: metar)
    }

    print()
  }

  private func printRemarks(metar: METAR) {
    for remark in metar.remarks.sorted(using: RemarkComparator()) {
      print(RemarkEntry.FormatStyle.remark().format(remark))
    }
  }

  private func printJSON<T: Encodable>(_ value: T) throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try encoder.encode(value)
    print(String(data: data, encoding: .utf8)!)
  }

  private func lprint(_ str: LocalizedStringResource) {
    print(String(localized: str))
  }

  private func logMessage(_ message: String) {
    FileHandle.standardError.write(Data(message.utf8))
  }
}

enum Errors: Swift.Error {
  case badResponse(_ response: URLResponse)
  case badStatus(response: URLResponse)
  case unknownAirportID(_ ID: String)
  case badMETAR(raw: String)
}

extension Errors: LocalizedError {
  public var errorDescription: String? {
    switch self {
      case .badResponse(let response): "Bad response from AWC API: \(response)"
      case .badStatus(let response): "Bad status from AWC API: \(response)"
      case .unknownAirportID(let ID): "Airport ID “\(ID)” was not found"
      case .badMETAR(let raw): "Couldn’t parse METAR: \(raw)"
    }
  }

  var failureReason: String? {
    switch self {
      case .badResponse, .badStatus:
        "The AWC API may have changed, or may not be functioning properly."
      case .unknownAirportID: "The airport is not in the AWC METAR database."
      case .badMETAR: "Either the METAR is incorrectly formatted, or SwiftMETAR should be fixed."
    }
  }
}
