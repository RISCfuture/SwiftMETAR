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

  @Test(arguments: [
    RunwayVisibility(runwayID: "17L", visibility: .equal(.feet(2600))),
    RunwayVisibility(runwayID: "17L", visibility: .equal(.meters(800))),
    RunwayVisibility(
      runwayID: "01L",
      visibility: .variable(.equal(.feet(600)), .equal(.feet(1000)))
    ),
    RunwayVisibility(runwayID: "01L", visibility: .lessThan(.feet(600))),
    RunwayVisibility(runwayID: "27", visibility: .greaterThan(.feet(6000))),
    RunwayVisibility(
      runwayID: "06",
      visibility: .variable(.lessThan(.meters(600)), .greaterThan(.meters(1200)))
    )
  ])
  func roundTripsCodedString(_ value: RunwayVisibility) throws {
    #expect(try RunwayVisibility(coded: value.codedString) == value)
  }

  @Test(arguments: [
    (RunwayVisibility(runwayID: "17L", visibility: .equal(.feet(2600))), "R17L/2600FT"),
    (RunwayVisibility(runwayID: "17L", visibility: .equal(.meters(800))), "R17L/800M"),
    (
      RunwayVisibility(
        runwayID: "01L",
        visibility: .variable(.equal(.feet(600)), .equal(.feet(1000)))
      ),
      "R01L/600V1000FT"
    ),
    (RunwayVisibility(runwayID: "01L", visibility: .lessThan(.feet(600))), "R01L/M600FT"),
    (RunwayVisibility(runwayID: "27", visibility: .greaterThan(.feet(6000))), "R27/P6000FT")
  ])
  func emitsCanonicalCodedStrings(_ value: RunwayVisibility, _ expected: String) {
    #expect(value.codedString == expected)
  }

  @Test
  func roundTripsThroughJSON() throws {
    let value = RunwayVisibility(
      runwayID: "01L",
      visibility: .variable(.equal(.feet(600)), .equal(.feet(1000)))
    )
    let data = try JSONEncoder().encode(value)
    let decoded = try JSONDecoder().decode(RunwayVisibility.self, from: data)
    #expect(decoded == value)
    #expect(try JSONDecoder().decode(String.self, from: data) == value.codedString)
  }
}
