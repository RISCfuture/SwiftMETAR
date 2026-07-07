import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct PeriodicIceAccreationAmountTests {
  @Test
  func parsesAI3051Remark() async throws {
    let string = "METAR KOKC 011255Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 I3051"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .periodicIceAccretionAmount(period: 3, amount: 0.51)
      )
    )
  }

  @Test
  func parsesAI3000Remark() async throws {
    let string = "METAR KOKC 011255Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 I3000"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .periodicIceAccretionAmount(period: 3, amount: 0)
      )
    )
  }
}
