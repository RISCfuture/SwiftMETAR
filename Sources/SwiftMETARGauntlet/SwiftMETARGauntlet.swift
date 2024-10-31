import Foundation
import SwiftMETAR
import ArgumentParser

@main
struct Argument: AsyncParsableCommand {
    @Option(name: [.customLong("metar-url"), .short], help: "The URL to load the METAR CSV from.", transform: { URL(string: $0)! })
    var METAR_URL = URL(string: "https://aviationweather.gov/data/cache/metars.cache.csv")!

    @Option(name: [.customLong("taf-url"), .short], help: "The URL to load the TAF CSV from.", transform: { URL(string: $0)! })
    var TAF_URL = URL(string: "https://aviationweather.gov/data/cache/tafs.cache.csv")!

    private var session: URLSession { .init(configuration: .ephemeral) }

    func run() async throws {
        async let metars: () = parseMETARs()
        async let tafs: () = parseTAFs()
        let _ = try await (metars, tafs)
    }

    private func parseMETARs() async throws {
        let (data, response) = try await session.bytes(from: METAR_URL)
        guard let response = response as? HTTPURLResponse else {
            throw Error.badResponse(response)
        }
        guard response.statusCode/100 == 2 else {
            throw Error.badStatus(response: response)
        }

        for try await line in data.lines {
            guard let range  = line.rangeOfCharacter(from: CharacterSet(charactersIn: ",")) else { continue }
            let string = String(line[line.startIndex..<range.lowerBound])
            guard string.starts(with: "K") else { continue }
            do {
                let metar = try await METAR.from(string: string)
                await checkRemarks(metar.remarks, string: string)
            } catch {
                await printError(product: string, error: error)
            }
        }
    }

    private func parseTAFs() async throws {
        let (data, response) = try await session.bytes(from: TAF_URL)
        guard let response = response as? HTTPURLResponse else {
            throw Error.badResponse(response)
        }
        guard response.statusCode/100 == 2 else {
            throw Error.badStatus(response: response)
        }

        for try await line in data.lines {
            guard let range  = line.rangeOfCharacter(from: CharacterSet(charactersIn: ",")) else { continue }
            let string = String(line[line.startIndex..<range.lowerBound])
            guard string.starts(with: "TAF K") else { continue }
            do {
                let taf = try await TAF.from(string: line)
                await checkRemarks(taf.remarks, string: line)
            } catch {
                await printError(product: string, error: error)
            }
        }
    }

    @MainActor
    private func printError(product: String, error: Swift.Error) {
        print(product)
        print(" -- \(error.localizedDescription)")
    }

    @MainActor
    private func checkRemarks(_ remarks: Array<RemarkEntry>, string: String) {
        for remark in remarks {
            if case let .unknown(remarkStr) = remark.remark {
                print(string)
                print("-- Unknown remark: \(remarkStr)")
            }
        }
    }
}

enum Error: Swift.Error {
    case badResponse(_ response: URLResponse)
    case badStatus(response: URLResponse)
}
