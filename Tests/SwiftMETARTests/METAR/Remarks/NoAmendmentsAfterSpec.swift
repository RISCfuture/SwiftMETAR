import Foundation
import NumberKit
import Testing

@testable import SwiftMETAR

@Suite
struct NoAmendmentsAfterTests {
  @Test
  func parsesANOAMDSAFT2601Remark() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 NO AMDS AFT 2601"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(.noAmendmentsAfter(Date().this(day: 26, hour: 1)!))
    )
  }

  @Test
  func parsesANOAMDAFT2601Remark() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 NO AMD AFT 2601"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(.noAmendmentsAfter(Date().this(day: 26, hour: 1)!))
    )
  }
}
