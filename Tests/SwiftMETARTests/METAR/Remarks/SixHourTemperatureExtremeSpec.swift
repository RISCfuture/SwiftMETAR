import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct SixHourTemperatureExtremeTests {
  @Test
  func parsesA10142Remark() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 10142"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .sixHourTemperatureExtreme(type: .high, temperature: 14.2)
      )
    )
  }

  @Test
  func parsesA11021Remark() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 11021"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .sixHourTemperatureExtreme(type: .high, temperature: -2.1)
      )
    )
  }

  @Test
  func parsesA21001Remark() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 21001"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .sixHourTemperatureExtreme(type: .low, temperature: -0.1)
      )
    )
  }

  @Test
  func parsesA20012Remark() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 20012"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .sixHourTemperatureExtreme(type: .low, temperature: 1.2)
      )
    )
  }
}
