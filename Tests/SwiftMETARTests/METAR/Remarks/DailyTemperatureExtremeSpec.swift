import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct DailyTemperatureExtremeTests {
  @Test
  func parsesA401001015Remark() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 401001015"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .dailyTemperatureExtremes(low: -1.5, high: 10)
      )
    )
  }

  @Test
  func parsesA401120084Remark() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 401120084"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .dailyTemperatureExtremes(low: 8.4, high: 11.2)
      )
    )
  }
}
