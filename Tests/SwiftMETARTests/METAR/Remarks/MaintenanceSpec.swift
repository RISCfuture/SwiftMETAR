import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct MaintenanceTests {
  @Test
  func `parses a $ remark`() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 ACFT MSHP $"
    let observation = try await METAR.from(string: string)

    #expect(observation.remarks.map(\.remark).contains(.maintenance))
  }

  @Test
  func `parses a $ remark with a trailing space`() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 ACFT MSHP $ "
    let observation = try await METAR.from(string: string)

    #expect(observation.remarks.map(\.remark).contains(.maintenance))
  }
}
