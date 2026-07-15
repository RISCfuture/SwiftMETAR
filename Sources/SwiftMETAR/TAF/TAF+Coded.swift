import Foundation

extension TAF: CodedRepresentable {

  /**
   The canonical coded representation of this forecast, e.g.
   `"TAF KSFO 121720Z 1218/1324 09010KT P6SM FEW020 FM130200 05005KT ..."`.

   The body is regenerated from the forecast's components (issuance, station,
   origin timestamp, groups, temperatures) in report order; remark sections are
   emitted verbatim from the stored `remarksString` values. Because some
   components have more than one valid coded spelling, this is a canonical form
   and may differ from the original ``text``.
   */
  public var codedString: String {
    var tokens = ["TAF"]
    if !issuance.rawValue.isEmpty { tokens.append(issuance.rawValue) }
    tokens.append(airportID)
    if let originCalendarDate {
      tokens.append(METAR.zuluTimestamp(originCalendarDate))
    }

    for group in groups { tokens.append(group.codedString) }
    for temperature in temperatures { tokens.append(temperature.codedString) }

    if let remarksString, !remarksString.isEmpty {
      tokens.append("RMK")
      tokens.append(remarksString)
    }

    return tokens.joined(separator: " ")
  }

  /**
   Parses a coded TAF. This is the synchronous decoding path used by `Codable`;
   unlike ``from(string:on:)`` it takes no reference date (dates resolve against
   the current date) and builds its parsers fresh, so it is intended for
   occasional decoding rather than high-volume parsing.

   - Parameter coded: The coded TAF string.
   - Throws: An ``Error`` if `coded` is not a valid TAF.
   */
  public init(coded: String) throws {
    self = try TAFParser.parseSynchronously(coded)
  }
}

extension TAF.Group: CodedRepresentable {

  /// The canonical coded representation of this forecast group, beginning with
  /// its period (e.g. `"FM130200 05005KT P6SM SCT040"`).
  public var codedString: String {
    var tokens = [period.codedString]
    if let wind { tokens.append(wind.codedString) }
    if let visibility { tokens.append(visibility.codedString) }
    if let weather { tokens.append(contentsOf: weather.map(\.codedString)) }
    tokens.append(contentsOf: conditions.map(\.codedString))
    if let windshear { tokens.append(windshear.codedString) }
    if windshearConditions { tokens.append("WSCONDS") }
    tokens.append(contentsOf: icing.map(\.codedString))
    tokens.append(contentsOf: turbulence.map(\.codedString))
    if let altimeter { tokens.append(Self.tafAltimeter(altimeter)) }

    if let remarksString, !remarksString.isEmpty {
      tokens.append("RMK")
      tokens.append(remarksString)
    }

    return tokens.joined(separator: " ")
  }

  /**
   Parses a coded TAF forecast group, e.g. `"FM130200 05005KT P6SM SCT040"`.
   This is the synchronous decoding path used by `Codable`; it takes no reference
   date (dates resolve against the current date).

   - Parameter coded: The coded group string.
   - Throws: An ``Error`` if `coded` is not a valid forecast group.
   */
  public init(coded: String) throws {
    self = try TAFParser.parseGroup(coded)
  }

  /// TAFs encode the minimum altimeter setting in the `QNH####INS`/`QNH####HPA`
  /// form rather than the METAR `A####`/`Q####` form.
  private static func tafAltimeter(_ altimeter: Altimeter) -> String {
    switch altimeter {
      case .inHg(let value): "QNH\(String(format: "%04d", value))INS"
      case .hPa(let value): "QNH\(String(format: "%04d", value))HPA"
    }
  }
}

extension TAF.Temperature {

  /// The canonical coded representation of this forecast temperature, e.g.
  /// `"TX17/2419Z"` (maximum) or `"TNM04/2509Z"` (minimum).
  public var codedString: String {
    let letter = type == .minimum ? "N" : "X"
    let magnitude = String(format: "%02d", abs(value))
    let coded = value < 0 ? "M\(magnitude)" : magnitude
    let dayHour = String(format: "%02d%02d", time.day ?? 0, time.hour ?? 0)
    return "T\(letter)\(coded)/\(dayHour)Z"
  }
}
