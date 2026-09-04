import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct RapidPressureChangeTests {
  @Test
  func `parses a PRESRR remark`() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 PRESRR"
    let observation = try await METAR.from(string: string)

    #expect(observation.remarks.map(\.remark).contains(.rapidPressureChange(.rising)))
  }

  @Test
  func `parses a PRESFR remark`() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 PRESFR"
    let observation = try await METAR.from(string: string)

    #expect(observation.remarks.map(\.remark).contains(.rapidPressureChange(.falling)))
  }
}
