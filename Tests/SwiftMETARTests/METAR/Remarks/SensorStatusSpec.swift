import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct SensorStatusTests {
  @Test
  func parsesARVRNORemark() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 RVRNO"
    let observation = try await METAR.from(string: string)

    #expect(observation.remarks.map(\.remark).contains(.inoperativeSensor(.RVR)))
  }

  @Test
  func parsesAVISNORWY11Remark() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 VISNO RWY11"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .inoperativeSensor(.secondaryVisibility(location: "RWY11"))
      )
    )
  }
}
