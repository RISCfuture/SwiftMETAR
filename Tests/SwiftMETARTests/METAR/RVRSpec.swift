import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct RVRTests {
  @Test
  func parsesVisibilitiesInFeet() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let visibilities = try await METAR.from(string: string).runwayVisibility

    #expect(visibilities.count == 1)
    #expect(visibilities[0].runwayID == "17L")
    #expect(visibilities[0].visibility == .equal(.feet(2600)))
  }

  @Test
  func parsesVisibilitiesInMeters() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/0800M +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let visibilities = try await METAR.from(string: string).runwayVisibility

    #expect(visibilities.count == 1)
    #expect(visibilities[0].runwayID == "17L")
    #expect(visibilities[0].visibility == .equal(.meters(800)))
  }

  @Test
  func parsesVisibilityRanges() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R01L/0600V1000FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let visibilities = try await METAR.from(string: string).runwayVisibility

    #expect(visibilities.count == 1)
    #expect(visibilities[0].runwayID == "01L")
    #expect(visibilities[0].visibility == .variable(.equal(.feet(600)), .equal(.feet(1000))))
  }

  @Test
  func parsesLessThanVisibilities() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R01L/M0600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let visibilities = try await METAR.from(string: string).runwayVisibility

    #expect(visibilities.count == 1)
    #expect(visibilities[0].runwayID == "01L")
    #expect(visibilities[0].visibility == .lessThan(.feet(600)))
  }

  @Test
  func parsesGreaterThanVisibilities() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R27/P6000FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let visibilities = try await METAR.from(string: string).runwayVisibility

    #expect(visibilities.count == 1)
    #expect(visibilities[0].runwayID == "27")
    #expect(visibilities[0].visibility == .greaterThan(.feet(6000)))
  }
}
