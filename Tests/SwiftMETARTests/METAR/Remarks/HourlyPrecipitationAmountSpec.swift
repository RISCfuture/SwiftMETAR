import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct HourlyPrecipitationAmountTests {
  @Test
  func parsesAP0009Remark() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 P0009"
    let observation = try await METAR.from(string: string)

    #expect(observation.remarks.map(\.remark).contains(.hourlyPrecipitationAmount(0.09)))
  }

  @Test
  func parsesAP0000Remark() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 P0000"
    let observation = try await METAR.from(string: string)

    #expect(observation.remarks.map(\.remark).contains(.hourlyPrecipitationAmount(0)))
  }
}
