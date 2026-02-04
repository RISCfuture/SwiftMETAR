import ArgumentParser
import Foundation
import SwiftMETAR

@available(macOS 15.0, *)
@main
struct DecodeWindsAloft: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    abstract: "Decodes a Winds and Temperatures Aloft (FB) product.",
    discussion: """
      This tool downloads winds aloft data from the AWC API and decodes it
      into human-readable text. You can specify the altitude level, forecast
      period, and region.
      """
  )

  @Option(name: .shortAndLong, help: "Altitude level: 'low' or 'high'.")
  var level: String = "low"

  @Option(name: .shortAndLong, help: "Forecast period in hours (e.g., 06, 12, 24).")
  var forecast: String = "06"

  @Option(name: .shortAndLong, help: "Region code (e.g., 'all', 'bos', 'mia').")
  var region: String = "all"

  @Option(
    name: [.customLong("url"), .short],
    help: "Override the API URL.",
    transform: { .init(string: $0)! }
  )
  var apiURL: URL?

  @Argument(help: "A raw winds aloft product string to decode (instead of fetching).")
  var rawProduct: String?

  @Flag(name: .long, help: "Only show station IDs with parsing errors.")
  var errorsOnly = false

  private var session: URLSession { .init(configuration: .ephemeral) }

  func run() async throws {
    if let rawProduct {
      let result = try await WindsAloft.from(string: rawProduct)
      printProduct(result)
    } else {
      let url =
        apiURL
        ?? URL(
          string:
            "https://aviationweather.gov/api/data/windtemp?level=\(level)&fcst=\(forecast)&region=\(region)&layout=on"
        )!
      let result = try await fetchAndParse(url: url)
      printProduct(result)
    }
  }

  private func fetchAndParse(url: URL) async throws -> WindsAloft {
    print("Fetching winds aloft from \(url)...")
    print()

    let (data, response) = try await session.data(from: url)
    guard let response = response as? HTTPURLResponse else {
      throw Errors.badResponse
    }
    guard response.statusCode / 100 == 2 else {
      throw Errors.badStatus(response.statusCode)
    }
    guard let text = String(data: data, encoding: .utf8) else {
      throw Errors.badEncoding
    }

    return try await WindsAloft.from(string: text)
  }

  private func printProduct(_ product: WindsAloft) {
    if errorsOnly { return }

    print("Product: \(product.header.productID) \(product.header.bulletinID)")
    print("Issuing Office: \(product.header.issuingOffice)")
    print("Level: \(product.level)")
    if let basedOnDate = product.basedOn.date {
      print("Based On: \(basedOnDate)")
    }
    if let validDate = product.validAt.date {
      print("Valid At: \(validDate)")
    }
    print("Altitudes: \(product.altitudes.map { "\($0) ft" }.joined(separator: ", "))")
    print()

    for station in product.stations {
      printStation(station)
    }
  }

  private func printStation(_ station: WindsAloft.Station) {
    print("\(station.id):")
    for entry in station.entries {
      let dataStr: String
      switch entry.data {
        case .lightAndVariable:
          dataStr = "Light and variable"
        case let .wind(direction, speed, temperature):
          var parts = ["\(direction)° at"]
          switch speed {
            case .knots(let kt): parts.append("\(kt) kt")
            case .kph(let kph): parts.append("\(kph) kph")
            case .mps(let mps): parts.append("\(mps) m/s")
          }
          if let temp = temperature {
            parts.append("temp \(temp)°C")
          }
          dataStr = parts.joined(separator: " ")
      }
      print("  \(entry.altitude) ft: \(dataStr)")
    }
  }
}

enum Errors: Swift.Error, LocalizedError {
  case badResponse
  case badStatus(_ code: Int)
  case badEncoding

  var errorDescription: String? {
    switch self {
      case .badResponse: "Bad response from AWC API."
      case .badStatus(let code): "Bad status \(code) from AWC API."
      case .badEncoding: "Response was not valid UTF-8."
    }
  }
}
