import Foundation

extension WindsAloft: CodedRepresentable {

  /// The station field width in the regenerated table: a 3-character ID plus
  /// one trailing space, matching ``WindsAloftParser``'s fixed station width.
  private static var stationWidth: Int { 4 }

  /// The width of each altitude column in the regenerated table. Every
  /// altitude number (≤ 5 characters) and data group (≤ 7 characters) is
  /// right-aligned within this width, guaranteeing at least one space of
  /// separation so the columns re-parse unambiguously.
  private static var columnWidth: Int { 8 }

  /**
   The canonical coded representation of this product.

   When ``text`` is present it is the original bulletin and is returned
   verbatim, since the raw fixed-width document is the lossless coded form.
   Otherwise a valid, re-parseable bulletin is regenerated from the parsed
   components: the WMO header block, the `FT` column line, and one
   right-aligned row per station.

   The regenerated table is not guaranteed to be byte-identical to an official
   NWS product — column spacing is uniform, and six-digit high-altitude groups
   are re-emitted in the canonical signed form (e.g. `770853` becomes
   `7708-53`). It is guaranteed to re-parse to structurally equal values.
   */
  public var codedString: String {
    if let text { return text }
    return regeneratedBulletin
  }

  private var regeneratedBulletin: String {
    var lines = [
      "000",
      "\(header.productID) \(header.issuingOffice) \(Self.dayHourMinute(header.issuanceDate))",
      header.bulletinID,
      "DATA BASED ON \(Self.dayHourMinute(basedOn))Z",
      "VALID \(Self.dayHourMinute(validAt))Z   FOR USE \(Self.usePeriodString(usePeriod))."
        + " TEMPS NEG ABV 24000",
      "",
      Self.columnHeaderLine(altitudes: altitudes)
    ]
    lines.append(contentsOf: stations.map { Self.stationRow($0, altitudes: altitudes) })
    return lines.joined(separator: "\n")
  }

  /**
   Parses a coded winds aloft bulletin. This is the synchronous decoding path
   used by `Codable`; unlike ``from(string:on:)`` it takes no reference date,
   so partial dates resolve against the current date, and it builds its parsers
   fresh, making it suited to occasional decoding rather than high-volume
   parsing.

   - Parameter coded: The coded winds aloft bulletin.
   - Throws: An ``Error`` if `coded` is not a valid winds aloft bulletin.
   */
  public init(coded: String) throws {
    self = try WindsAloftParser.parseSynchronously(coded)
  }

  private static func columnHeaderLine(altitudes: [UInt]) -> String {
    var line = padded("FT")
    for altitude in altitudes {
      line += rightAligned(String(altitude))
    }
    return line
  }

  private static func stationRow(_ station: Station, altitudes: [UInt]) -> String {
    var line = padded(station.id)
    for altitude in altitudes {
      line += rightAligned(station[altitude]?.codedString ?? "")
    }
    return line
  }

  private static func dayHourMinute(_ components: DateComponents) -> String {
    String(
      format: "%02d%02d%02d",
      components.day ?? 0,
      components.hour ?? 0,
      components.minute ?? 0
    )
  }

  private static func usePeriodString(_ interval: DateComponentsInterval) -> String {
    String(
      format: "%02d%02d-%02d%02dZ",
      interval.start.hour ?? 0,
      interval.start.minute ?? 0,
      interval.end.hour ?? 0,
      interval.end.minute ?? 0
    )
  }

  /// Left-justifies a station-field value (`"FT"` or a station ID) within the
  /// fixed station width.
  private static func padded(_ string: String) -> String {
    string.padding(toLength: stationWidth, withPad: " ", startingAt: 0)
  }

  /// Right-aligns a cell value within an altitude column's fixed width.
  private static func rightAligned(_ string: String) -> String {
    guard string.count < columnWidth else { return string }
    return String(repeating: " ", count: columnWidth - string.count) + string
  }
}
