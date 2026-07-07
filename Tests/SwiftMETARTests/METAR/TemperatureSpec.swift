import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct TemperatureTests {
  @Test
  func parsesAPositiveNumber() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let observation = try await METAR.from(string: string)
    #expect(observation.temperature == 18)
    #expect(observation.dewpoint == 16)
  }

  @Test
  func parsesANegativeNumber() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR OVC010CB 04/M02 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let observation = try await METAR.from(string: string)
    #expect(observation.temperature == 4)
    #expect(observation.dewpoint == -2)
  }

  @Test
  func parsesAMissingDewpoint() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR OVC010CB 02/ A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let observation = try await METAR.from(string: string)
    #expect(observation.temperature == 2)
    #expect(observation.dewpoint == nil)
  }

  @Test
  func parsesAMissingTemperature() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR OVC010CB A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let observation = try await METAR.from(string: string)
    #expect(observation.temperature == nil)
    #expect(observation.dewpoint == nil)
  }

  @Test
  func parsesAMissingTemperatureDewpoint() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR OVC010CB M A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let observation = try await METAR.from(string: string)
    #expect(observation.temperature == nil)
    #expect(observation.dewpoint == nil)
  }
}
