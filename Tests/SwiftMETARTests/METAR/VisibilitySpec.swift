import Foundation
import NumberKit
import Testing

@testable import SwiftMETAR

@Suite
struct VisibilityTests {
  @Test
  func parsesFractionalVisibilitiesLessThan1SM() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let visibility = try await METAR.from(string: string).visibility
    #expect(visibility == .equal(.statuteMiles(3 / 4 as Ratio)))
  }

  @Test
  func parsesFractionalVisibilitiesGreaterThan1SM() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 1 1/2SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let visibility = try await METAR.from(string: string).visibility
    #expect(visibility == .equal(.statuteMiles(3 / 2 as Ratio)))
  }

  @Test
  func parsesWholeVisibilitiesGreaterThan1SM() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let visibility = try await METAR.from(string: string).visibility
    #expect(visibility == .equal(.statuteMiles(3 as Ratio)))
  }

  @Test
  func parsesVisibilitiesLessThan1SlashFourSM() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 M1/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let visibility = try await METAR.from(string: string).visibility
    #expect(visibility == .lessThan(.statuteMiles(1 / 4 as Ratio)))
  }

  @Test
  func parsesVisibilitiesGreaterThanOrEqualTo10SM() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 10SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let visibility = try await METAR.from(string: string).visibility
    #expect(visibility == .greaterThan(.statuteMiles(10 as Ratio)))
  }

  @Test
  func parsesVisibilitiesInMeters() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3000 R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let visibility = try await METAR.from(string: string).visibility
    #expect(visibility == .equal(.meters(3000)))
  }

  @Test
  func parsesVisibilitiesGreaterThanOrEqualTo9999M() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 9999 R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let visibility = try await METAR.from(string: string).visibility
    #expect(visibility == .greaterThan(.meters(9999)))
  }

  @Test
  func parsesMissingVisibilities() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 M R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let metar = try await METAR.from(string: string)
    #expect(metar.visibility == nil)
  }
}
