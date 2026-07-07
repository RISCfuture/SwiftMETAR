import Foundation
import NumberKit
import Testing

@testable import SwiftMETAR

@Suite
struct SectorVisibilityTests {
  @Test
  func parsesAVISNE212Remark() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 VIS NE 2 1/2"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .sectorVisibility(direction: .northeast, distance: 5 / 2 as Ratio)
      )
    )
  }
}
