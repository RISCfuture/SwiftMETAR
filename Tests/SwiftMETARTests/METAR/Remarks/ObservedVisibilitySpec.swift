import Foundation
import NumberKit
import Testing

@testable import SwiftMETAR

@Suite
struct ObservedVisibilityTests {
  @Test
  func `parses a TWR VIS 1 1/2 remark`() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 TWR VIS 1 1/2"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .observedVisibility(source: .tower, distance: 3 / 2 as Ratio)
      )
    )
  }

  @Test
  func `parses an SFC VIS 1/4 remark`() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 SFC VIS 1/4"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .observedVisibility(source: .surface, distance: 1 / 4 as Ratio)
      )
    )
  }

  @Test
  func `parses a TWR VIS 2 remark`() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 TWR VIS 2"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .observedVisibility(source: .tower, distance: 2 as Ratio)
      )
    )
  }
}
