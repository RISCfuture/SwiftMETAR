import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct METARCodedTests {

  /// A parsed observation, re-encoded to a coded string and parsed again, should
  /// preserve its meteorological fields (the coded form is canonical, so the raw
  /// text may differ but the decoded values must not).
  @Test(
    arguments: [
      "METAR KSFO 121953Z 03015KT 10SM FEW020 SCT200 18/12 A2992 RMK AO2 SLP132",
      "METAR KOKC 011955Z AUTO 27020G35KT 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 "
        + "RMK AO2 TSB25",
      "SPECI KLAX 121947Z 25008KT 10SM BKN015 OVC025 M02/M05 Q1013",
      "METAR KJFK 121951Z VRB03KT CAVOK 22/13 A3001"
    ]
  )
  func `coded string reparses to same values`(_ string: String) async throws {
    let original = try await METAR.from(string: string)
    let reparsed = try await METAR.from(string: original.codedString)

    #expect(reparsed.stationID == original.stationID)
    #expect(reparsed.calendarDate.day == original.calendarDate.day)
    #expect(reparsed.calendarDate.hour == original.calendarDate.hour)
    #expect(reparsed.wind == original.wind)
    #expect(reparsed.visibility == original.visibility)
    #expect(reparsed.weather == original.weather)
    #expect(reparsed.conditions == original.conditions)
    #expect(reparsed.runwayVisibility == original.runwayVisibility)
    #expect(reparsed.temperature == original.temperature)
    #expect(reparsed.dewpoint == original.dewpoint)
    #expect(reparsed.altimeter == original.altimeter)
  }

  @Test
  func `encodes and decodes as a single coded string via Codable`() throws {
    let metar = try METAR(coded: "METAR KSFO 121953Z 03015KT 10SM FEW020 18/12 A2992 RMK AO2")
    let data = try JSONEncoder().encode(metar)

    let json = try #require(String(data: data, encoding: .utf8))
    #expect(json.hasPrefix(#""METAR KSFO 121953Z 03015KT"#))

    let decoded = try JSONDecoder().decode(METAR.self, from: data)
    #expect(decoded.stationID == "KSFO")
    #expect(decoded.wind == metar.wind)
    #expect(decoded.visibility == metar.visibility)
    #expect(decoded.temperature == metar.temperature)
    #expect(decoded.altimeter == metar.altimeter)
  }

  /// The synchronous `Codable` decode path parses each coded string with the
  /// shared parsers. Decoding concurrently from many tasks must neither crash
  /// nor corrupt results, guarding against the regex-construction data race the
  /// coded-string representation originally introduced.
  @Test
  func `decodes concurrently without crashing`() async throws {
    let metar = try METAR(coded: "METAR KSFO 121953Z 03015KT 10SM FEW020 18/12 A2992 RMK AO2")
    let data = try JSONEncoder().encode(metar)

    await withTaskGroup(of: Bool.self) { group in
      for _ in 0..<16 {
        group.addTask {
          let decoder = JSONDecoder()
          for _ in 0..<500 {
            guard let decoded = try? decoder.decode(METAR.self, from: data),
              decoded.stationID == "KSFO",
              decoded.wind == metar.wind,
              decoded.altimeter == metar.altimeter
            else { return false }
          }
          return true
        }
      }

      for await succeeded in group {
        #expect(succeeded)
      }
    }
  }
}
