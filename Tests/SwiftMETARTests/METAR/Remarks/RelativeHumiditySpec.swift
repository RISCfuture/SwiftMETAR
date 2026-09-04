import Foundation
import NumberKit
import Testing

@testable import SwiftMETAR

@Suite
struct RelativeHumidityTests {
  @Test
  func `parses an RH/31 remark`() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 RH/31"
    let observation = try await METAR.from(string: string)

    #expect(observation.remarks.map(\.remark).contains(.relativeHumidity(31)))
  }
}
