import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct VariableCeilingHeightTests {
  @Test
  func parsesACIG005V010Remark() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 CIG 005V010"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .variableCeilingHeight(low: 500, high: 1000)
      )
    )
  }
}
