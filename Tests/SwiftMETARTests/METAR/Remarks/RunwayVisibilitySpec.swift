import Foundation
import NumberKit
import Testing

@testable import SwiftMETAR

@Suite
struct RunwayVisibilityTests {
  @Test
  func parsesAVIS212RWY11Remark() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 VIS 2 1/2 RWY11"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .runwayVisibility(runway: "11", distance: 5 / 2 as Ratio)
      )
    )
  }

  @Test
  func parsesAVIS12RWY11Remark() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 VIS 1/2 RWY11"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .runwayVisibility(runway: "11", distance: 1 / 2 as Ratio)
      )
    )
  }

  @Test
  func parsesAVIS1RWY11Remark() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 VIS 1 RWY11"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .runwayVisibility(runway: "11", distance: 1 as Ratio)
      )
    )
  }
}
