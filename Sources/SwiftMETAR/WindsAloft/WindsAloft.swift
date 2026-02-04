import Foundation

/**
 A parsed NWS Winds and Temperatures Aloft (FB/FD) product.

 Winds aloft forecasts are fixed-width tabular documents that provide wind
 direction, speed, and temperature at standard altitude levels for reporting
 stations across the US. They are issued for both low-level (3,000–39,000 ft)
 and high-level (24,000–53,000 ft) products.

 To parse a winds aloft product:

 ```swift
 let windsAloft = try await WindsAloft.from(string: rawText)
 for station in windsAloft.stations {
     print(station.id)
     for entry in station.entries {
         print("  \(entry.altitude) ft: \(entry.data)")
     }
 }
 ```
 */
public struct WindsAloft: Codable, Equatable, Sendable {

  /// The raw text of the product.
  public let text: String?

  /// The WMO header information for this product.
  public let header: Header

  /// Whether this is a low-level or high-level product.
  public let level: Level

  /// The observation time the forecast data is based on.
  public let basedOn: DateComponents

  /// The time this forecast is valid at.
  public let validAt: DateComponents

  /// The use period for this forecast.
  public let usePeriod: DateComponentsInterval

  /// The ordered altitude levels in feet from the column header.
  public let altitudes: [UInt]

  /// The per-station data rows.
  public let stations: [Station]

  /// The altitude levels as `Measurement` values, convertible to other units.
  public var altitudeMeasurements: [Measurement<UnitLength>] {
    altitudes.map { .init(value: Double($0), unit: .feet) }
  }

  /**
   Parse a Winds and Temperatures Aloft product from its text.
  
   - Parameter string: The raw product text.
   - Parameter date: A reference date for resolving partial date components.
                     Defaults to the current date.
   - Returns: A parsed ``WindsAloft`` value.
   */
  public static func from(string: String, on date: Date? = nil) async throws -> Self {
    try await WindsAloftParser.shared.parse(string, on: date)
  }

  /// The WMO header block of a winds aloft product.
  public struct Header: Codable, Equatable, Sendable {
    /// The WMO product identifier (e.g., `FBUS31`).
    public let productID: String

    /// The issuing office identifier (e.g., `KWNO`).
    public let issuingOffice: String

    /// The issuance date/time.
    public let issuanceDate: DateComponents

    /// The bulletin identifier (e.g., `FD1US1`).
    public let bulletinID: String
  }

  /// Whether the product covers low-level or high-level altitudes.
  public enum Level: String, Codable, Sendable {
    /// Low-level product (typically 3,000–39,000 ft).
    case low
    /// High-level product (typically 24,000–53,000 ft).
    case high
  }

  /// A reporting station with its winds aloft data at each altitude.
  public struct Station: Codable, Equatable, Sendable {

    /// The station identifier (e.g., `ABI`).
    public let id: String

    /// The data entries ordered by altitude.
    public let entries: [Entry]

    /// Look up data by altitude in feet.
    public subscript(altitude: UInt) -> WindsAloftEntry? {
      entries.first(where: { $0.altitude == altitude })?.data
    }

    /// A single altitude/data pair within a station.
    public struct Entry: Codable, Equatable, Sendable {

      /// The altitude in feet.
      public let altitude: UInt

      /// The decoded wind and temperature data at this altitude.
      public let data: WindsAloftEntry

      /// The altitude as a `Measurement`, convertible to other units.
      public var altitudeMeasurement: Measurement<UnitLength> {
        .init(value: Double(altitude), unit: .feet)
      }
    }
  }
}
