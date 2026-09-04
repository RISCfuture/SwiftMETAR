import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct ObscurationTests {
  @Test
  func `parses an FG SCT000 remark`() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 FG SCT000"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .obscuration(type: .fog, amount: .scattered, height: 0)
      )
    )
  }

  @Test
  func `parses an FU BKN020 remark`() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 FU BKN020"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .obscuration(type: .smoke, amount: .broken, height: 2000)
      )
    )
  }
}
