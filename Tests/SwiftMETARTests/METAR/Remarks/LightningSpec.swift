import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct LightningTests {
  @Test
  func parsesAOCNLLTGICCGOHDRemark() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 OCNL LTGICCG OHD"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .lightning(
          frequency: .occasional,
          types: [.cloudToGround, .withinCloud],
          proximity: .overhead,
          directions: []
        )
      )
    )
  }
}
