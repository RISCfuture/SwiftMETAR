import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct PressureTendencyTests {
  @Test
  func parsesA52032Remark() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 52032"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .pressureTendency(character: .steadyUp, change: 3.2)
      )
    )
  }
}
