import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct SeaLevelPressureTests {
  @Test
  func `parses an SLP982 remark`() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 SLP982"
    let observation = try await METAR.from(string: string)

    #expect(observation.remarks.map(\.remark).contains(.seaLevelPressure(998.2)))
  }

  @Test
  func `parses an SLPNO remark`() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 SLPNO"
    let observation = try await METAR.from(string: string)

    #expect(observation.remarks.map(\.remark).contains(.seaLevelPressure(nil)))
  }
}
