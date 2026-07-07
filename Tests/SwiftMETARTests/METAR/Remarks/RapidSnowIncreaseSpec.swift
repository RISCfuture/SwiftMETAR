import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct RapidSnowIncreaseTests {
  @Test
  func parsesASNINCR210Remark() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 SNINCR 2/10"
    let observation = try await METAR.from(string: string)

    #expect(observation.remarks.map(\.remark).contains(.rapidSnowIncrease(2, totalDepth: 10)))
  }
}
