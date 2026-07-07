import Foundation
import NumberKit
import Testing

@testable import SwiftMETAR

@Suite
struct HailstoneSizeTests {
  @Test
  func parsesAGR134Remark() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 GR 1 3/4"
    let observation = try await METAR.from(string: string)

    #expect(observation.remarks.map(\.remark).contains(.hailstoneSize(7 / 4 as Ratio)))
  }
}
