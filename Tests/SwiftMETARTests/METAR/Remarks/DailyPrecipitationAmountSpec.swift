import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct DailyPrecipitationAmountTests {
  @Test
  func `parses a 70125 remark`() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 70125"
    let observation = try await METAR.from(string: string)

    #expect(observation.remarks.map(\.remark).contains(.dailyPrecipitationAmount(1.25)))
  }

  @Test
  func `parses a 7//// remark`() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 7////"
    let observation = try await METAR.from(string: string)

    #expect(observation.remarks.map(\.remark).contains(.dailyPrecipitationAmount(nil)))
  }
}
