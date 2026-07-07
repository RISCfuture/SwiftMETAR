import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct NavalForecasterTests {
  @Test
  func parsesAFN20066Remark() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 FN20066"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(.navalForecaster(center: .norfolk, ID: 20066))
    )
  }

  @Test
  func parsesAFS30067Remark() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 FS30067"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(.navalForecaster(center: .sanDiego, ID: 30067))
    )
  }
}
