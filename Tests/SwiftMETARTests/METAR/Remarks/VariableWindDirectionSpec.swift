import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct VariableWindDirectionTests {
  @Test
  func parsesAWND060V120Remark() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 WND 060V120"
    let observation = try await METAR.from(string: string)

    #expect(observation.remarks.map(\.remark).contains(.variableWindDirection(60, 120)))
  }
}
