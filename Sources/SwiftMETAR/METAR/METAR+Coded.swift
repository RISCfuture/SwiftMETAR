import Foundation

extension METAR: CodedRepresentable {

  /**
   The canonical coded representation of this observation, e.g.
   `"METAR KSFO 121953Z 03015KT 10SM FEW020 18/12 A2992 RMK AO2"`.

   The body is regenerated from the observation's components in report order;
   the remarks section is emitted verbatim from ``remarksString`` (parsed remark
   values are not re-serialized). Because some components have more than one
   valid coded spelling, this is a canonical form and may differ from the
   original ``text``.
   */
  public var codedString: String {
    var tokens = [issuance.rawValue, stationID, Self.zuluTimestamp(calendarDate)]
    if !observer.rawValue.isEmpty { tokens.append(observer.rawValue) }
    if let wind { tokens.append(wind.codedString) }

    if conditions.contains(.cavok) {
      tokens.append("CAVOK")
    } else {
      if let visibility { tokens.append(visibility.codedString) }
      tokens.append(contentsOf: runwayVisibility.map(\.codedString))
      if let weather { tokens.append(contentsOf: weather.map(\.codedString)) }
      tokens.append(contentsOf: conditions.map(\.codedString))
    }

    if temperature != nil || dewpoint != nil {
      tokens.append(Self.coded(temperature: temperature, dewpoint: dewpoint))
    }
    if let altimeter { tokens.append(altimeter.codedString) }

    if let remarksString, !remarksString.isEmpty {
      tokens.append("RMK")
      tokens.append(remarksString)
    }

    return tokens.joined(separator: " ")
  }

  /**
   Parses a coded METAR, e.g.
   `"METAR KSFO 121953Z 03015KT 10SM FEW020 18/12 A2992 RMK AO2"`. This is the
   synchronous decoding path used by `Codable`; unlike ``from(string:on:lenientRemarks:)``
   it takes no reference date, so dates resolve against the current date. It
   shares the same cached, pre-warmed parsers as the async path.

   - Parameter coded: The coded METAR string.
   - Throws: An ``Error`` if `coded` is not a valid METAR.
   */
  public init(coded: String) throws {
    self = try METARParser.parseSynchronously(coded)
  }

  static func zuluTimestamp(_ components: DateComponents) -> String {
    String(
      format: "%02d%02d%02dZ",
      components.day ?? 0,
      components.hour ?? 0,
      components.minute ?? 0
    )
  }

  static func coded(temperature: Int8?, dewpoint: Int8?) -> String {
    "\(codedTemperature(temperature))/\(codedTemperature(dewpoint))"
  }

  private static func codedTemperature(_ value: Int8?) -> String {
    guard let value else { return "" }
    let magnitude = String(format: "%02d", abs(Int(value)))
    return value < 0 ? "M\(magnitude)" : magnitude
  }
}
