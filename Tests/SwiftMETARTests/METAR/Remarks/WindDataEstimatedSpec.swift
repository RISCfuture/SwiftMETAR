import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct WindDataEstimatedTests {
  @Test
  func `parses a WND DATA ESTMD remark`() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 WND DATA ESTMD"
    let observation = try await METAR.from(string: string)

    #expect(observation.remarks.map(\.remark).contains(.windDataEstimated))
  }
}
