import Foundation
import NumberKit
import Testing

@testable import SwiftMETAR

@Suite
struct VariablePrevailingVisibilityTests {
  @Test
  func `parses a VIS 1/2V1 1/2 remark`() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 VIS 1/2V1 1/2"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .variablePrevailingVisibility(low: 1 / 2 as Ratio, high: 3 / 2 as Ratio)
      )
    )
  }

  @Test
  func `parses a VIS 1/2V5 remark`() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 VIS 1/2V5"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .variablePrevailingVisibility(low: 1 / 2 as Ratio, high: 5 as Ratio)
      )
    )
  }

  @Test
  func `parses a VIS 2V4 remark`() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 VIS 2V4"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .variablePrevailingVisibility(low: 2 as Ratio, high: 4 as Ratio)
      )
    )
  }
}
