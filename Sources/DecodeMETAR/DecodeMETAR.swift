import ArgumentParser
import Foundation
import METARFormatting
import SwiftMETAR

@available(macOS 15.0, *)
@main
struct DecodeMETAR: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Decodes a METAR into human-readable text.",
        discussion: """
            This tool can be used with an airport code (in ICAO format [i.e., include the "K"]),
            in which case it will download the latest METARs from AWC; or it can be used with
            a raw METAR string, in which case that string will be parsed.
            """)

    @Argument(help: "The ICAO code of an airport, or a METAR string to decode")
    var airportCodeOrMETAR: String?

    @Option(name: [.customLong("metar-url"), .short], help: "The URL to load the METAR CSV from.", transform: { .init(string: $0)! })
    var METAR_URL = URL(string: "https://aviationweather.gov/data/cache/metars.cache.csv")!

    @Flag(name: .long, inversion: .prefixedNo, help: "Include raw METAR text")
    var raw = false

    @Flag(name: .shortAndLong, inversion: .prefixedNo, help: "Include remarks")
    var remarks = true

    @Flag(name: .long, help: "Parse and decode all METARs (!)")
    var all = false

    @Flag(name: .long, help: "Only show stations with parsing errors (intended to be used with `--all`")
    var errorsOnly = false

    private var session: URLSession { .init(configuration: .ephemeral) }

    func run() async throws {
        try await all ? parseAll() : parsePrompt()
    }

    private func parseAll() async throws {
        let METARs = try await loadMETARs { raw, error in
            print(raw)
            print("  Parse error: \(error.localizedDescription)")
            print()
        }
        if !errorsOnly {
            for metar in METARs.values {
                printMETAR(metar)
            }
        }
    }

    private func parsePrompt() async throws {
        let airportCodeOrMETAR = promptMETAR()
        let metar = try await airportCodeOrMETAR.count == 4 ? parse(code: airportCodeOrMETAR) : parse(raw: airportCodeOrMETAR)
        printMETAR(metar)
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

    private func loadMETARs(errorHandler: ((String, Swift.Error) throws -> Void)) async throws -> [String: METAR] {
        print("Loading METARs…")
        print()

        let (data, response) = try await session.bytes(from: METAR_URL)
        guard let response = response as? HTTPURLResponse else {
            throw Errors.badResponse(response)
        }
        guard response.statusCode / 100 == 2 else {
            throw Errors.badStatus(response: response)
        }

        var METARs = [String: METAR]()
        for try await line in data.lines {
            guard let range = line.rangeOfCharacter(from: CharacterSet(charactersIn: ",")) else { continue }
            let string = String(line[line.startIndex..<range.lowerBound])
            guard string.starts(with: "K") else { continue }
            do {
                let metar = try await METAR.from(string: string)
                METARs[metar.stationID] = metar
            } catch {
                try errorHandler(string, error)
            }
        }

        return METARs
    }

    private func getMETAR(airportCode: String) async throws -> METAR? {
        let METARs = try await loadMETARs { raw, _ in
            if raw.starts(with: airportCode) {
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
            lprint("Temperature: \(temperature, format: .measurement(width: .abbreviated, usage: .asProvided))")
        }
        if let dewpoint = metar.dewpointMeasurement {
            lprint("Dewpoint: \(dewpoint, format: .measurement(width: .abbreviated, usage: .asProvided))")
        }
        if let altimeter = metar.altimeter?.measurement {
            lprint("Altimeter: \(altimeter, format: .measurement(width: .abbreviated, usage: .asProvided))")
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

    private func lprint(_ str: LocalizedStringResource) {
        print(String(localized: str))
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
            case let .badResponse(response): "Bad response from AWC API: \(response)"
            case let .badStatus(response): "Bad status from AWC API: \(response)"
            case let .unknownAirportID(ID): "Airport ID “\(ID)” was not found"
            case let .badMETAR(raw): "Couldn’t parse METAR: \(raw)"
        }
    }

    var failureReason: String? {
        switch self {
            case .badResponse, .badStatus: "The AWC API may have changed, or may not be functioning properly."
            case .unknownAirportID: "The airport is not in the AWC METAR database."
            case .badMETAR: "Either the METAR is incorrectly formatted, or SwiftMETAR should be fixed."
        }
    }
}
