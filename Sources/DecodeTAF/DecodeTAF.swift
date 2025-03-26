import ArgumentParser
import Foundation
import METARFormatting
import SwiftMETAR

@available(macOS 15.0, *)
@main
struct DecodeTAF: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Decodes a TAF into human-readable text.",
        discussion: """
            This tool can be used with an airport code (in ICAO format [i.e., include the "K"]),
            in which case it will download the latest TAFs from AWC; or it can be used with
            a raw TAF string, in which case that string will be parsed.
            """)

    @Argument(help: "The ICAO code of an airport, or a TAF string to decode")
    var airportCodeOrTAF: String?

    @Option(name: [.customLong("taf-url"), .short], help: "The URL to load the TAF CSV from.", transform: { .init(string: $0)! })
    var TAF_URL = URL(string: "https://aviationweather.gov/data/cache/tafs.cache.csv")!

    @Flag(name: .long, inversion: .prefixedNo, help: "Include raw TAF text")
    var raw = false

    @Flag(name: .shortAndLong, inversion: .prefixedNo, help: "Include remarks")
    var remarks = true

    @Flag(name: .long, help: "Parse and decode all TAFs (!)")
    var all = false

    @Flag(name: .long, help: "Only show stations with parsing errors (intended to be used with `--all`")
    var errorsOnly = false

    private var session: URLSession { .init(configuration: .ephemeral) }

    func run() async throws {
        try await all ? parseAll() : parsePrompt()
    }

    private func parseAll() async throws {
        let TAFs = try await loadTAFs { raw, error in
            print(raw)
            print("  Parse error: \(error.localizedDescription)")
            print()
        }
        if !errorsOnly {
            for taf in TAFs.values {
                printTAF(taf)
            }
        }
    }

    private func parsePrompt() async throws {
        let airportCodeOrTAF = promptTAF()
        let taf = try await airportCodeOrTAF.count == 4 ? parse(code: airportCodeOrTAF) : parse(raw: airportCodeOrTAF)
        printTAF(taf)
    }

    private func promptTAF() -> String {
        var airportCodeOrTAF = self.airportCodeOrTAF

        while airportCodeOrTAF == nil || airportCodeOrTAF!.isEmpty {
            print("Enter airport code or TAF: ", terminator: "")
            airportCodeOrTAF = readLine(strippingNewline: true)
        }

        return airportCodeOrTAF!
    }

    private func parse(code: String) async throws -> TAF {
        guard let taf = try await getTAF(airportCode: code) else {
            throw Errors.unknownAirportID(code)
        }
        return taf
    }

    private func parse(raw: String) async throws -> TAF {
        try await TAF.from(string: raw)
    }

    private func loadTAFs(errorHandler: ((String, Swift.Error) throws -> Void)) async throws -> [String: TAF] {
        print("Loading TAFs…")
        print()

        let (data, response) = try await session.bytes(from: TAF_URL)
        guard let response = response as? HTTPURLResponse else {
            throw Errors.badResponse(response)
        }
        guard response.statusCode / 100 == 2 else {
            throw Errors.badStatus(response: response)
        }

        var TAFs = [String: TAF]()
        for try await line in data.lines {
            guard let range = line.rangeOfCharacter(from: CharacterSet(charactersIn: ",")) else { continue }
            let string = String(line[line.startIndex..<range.lowerBound])
            guard string.starts(with: "K") else { continue }
            do {
                let taf = try await TAF.from(string: string)
                TAFs[taf.airportID] = taf
            } catch {
                try errorHandler(string, error)
            }
        }

        return TAFs
    }

    private func getTAF(airportCode: String) async throws -> TAF? {
        let TAFs = try await loadTAFs { raw, _ in
            if raw.starts(with: airportCode) {
                throw Errors.badTAF(raw: raw)
            }
        }

        return TAFs[airportCode]
    }

    private func printTAF(_ taf: TAF) {
        if errorsOnly { return }

        print("Airport: \(taf.airportID)")
        if raw, let text = taf.text {
            print(text)
        }

        if let date = taf.originDate {
            lprint("Issued: \(date, format: .dateTime) (\(taf.issuance, format: .issuance))")
        }
        for group in taf.groups {
            printGroup(group)
        }
        if !taf.temperatures.isEmpty {
            let temps = taf.temperatures.map { TAF.Temperature.FormatStyle.temperature.format($0) }.joined(separator: ", ")
            print("Temperature: \(temps)")
        }

        if remarks {
            print()
            printRemarks(taf: taf)
        }

        print()
    }

    private func printGroup(_ group: TAF.Group) {
        lprint("\(group.period, format: .period):")
        if let wind = group.wind {
            lprint("  Wind: \(wind, format: .wind)")
        }
        if let visibility = group.visibility {
            lprint("  Visibility: \(visibility, format: .visibility)")
        }
        if let weathers = group.weather, !weathers.isEmpty {
            lprint("  Weather: \(weathers, format: .list(memberStyle: .weather, type: .and))")
        }
        if !group.conditions.isEmpty {
            lprint("  Conditions: \(group.conditions, format: .list(memberStyle: .condition, type: .and))")
        }
        if let windshear = group.windshear {
            lprint("  Windshear: \(windshear, format: .windshear)")
        } else if group.windshearConditions {
            print("  Windshear conditions present")
        }
        if !group.icing.isEmpty {
            let icing = group.icing.map { Icing.FormatStyle.icing.format($0) }.joined(separator: ", ")
            lprint("  Icing: \(icing)")
        }
        if !group.turbulence.isEmpty {
            let turbulence = group.turbulence.map { Turbulence.FormatStyle.turbulence.format($0) }.joined(separator: ", ")
            lprint("  Turbulence: \(turbulence)")
        }
        if let altimeter = group.altimeter {
            lprint("  Altimeter: \(altimeter.measurement, format: .measurement(width: .abbreviated, usage: .asProvided))")
        }
    }

    private func printRemarks(taf: TAF) {
        for remark in taf.remarks.sorted(using: RemarkComparator()) {
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
    case badTAF(raw: String)
}

extension Errors: LocalizedError {
    public var errorDescription: String? {
        switch self {
            case let .badResponse(response): "Bad response from AWC API: \(response)"
            case let .badStatus(response): "Bad status from AWC API: \(response)"
            case let .unknownAirportID(ID): "Airport ID “\(ID)” was not found"
            case let .badTAF(raw): "Couldn’t parse TAF: \(raw)"
        }
    }

    var failureReason: String? {
        switch self {
            case .badResponse, .badStatus: "The AWC API may have changed, or may not be functioning properly."
            case .unknownAirportID: "The airport is not in the AWC TAF database."
            case .badTAF: "Either the TAF is incorrectly formatted, or SwiftMETAR should be fixed."
        }
    }
}
