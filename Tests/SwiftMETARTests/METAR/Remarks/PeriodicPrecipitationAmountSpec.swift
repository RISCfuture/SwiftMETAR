import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct PeriodicPrecipitationAmountTests {
  @Test
  func `parses a 60217 remark`() async throws {
    let string = "METAR KOKC 011255Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 60217"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .periodicPrecipitationAmount(period: 6, amount: 2.17)
      )
    )
  }

  @Test
  func `parses a 60000 remark`() async throws {
    let string = "METAR KOKC 011155Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 60000"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .periodicPrecipitationAmount(period: 6, amount: 0)
      )
    )
  }

  @Test
  func `parses a 6//// remark`() async throws {
    let string = "METAR KOKC 011255Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 6////"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .periodicPrecipitationAmount(period: 6, amount: nil)
      )
    )
  }
}
