import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct SixHourTemperatureExtremeTests {
  @Test
  func `parses a 10142 remark`() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 10142"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .sixHourTemperatureExtreme(type: .high, temperature: 14.2)
      )
    )
  }

  @Test
  func `parses an 11021 remark`() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 11021"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .sixHourTemperatureExtreme(type: .high, temperature: -2.1)
      )
    )
  }

  @Test
  func `parses a 21001 remark`() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 21001"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .sixHourTemperatureExtreme(type: .low, temperature: -0.1)
      )
    )
  }

  @Test
  func `parses a 20012 remark`() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 20012"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .sixHourTemperatureExtreme(type: .low, temperature: 1.2)
      )
    )
  }
}
