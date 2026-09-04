import Foundation
import NumberKit
import Testing

@testable import SwiftMETAR

@Suite
struct CAVOKTests {
  @Test
  func `parses a CAVOK note`() async throws {
    let string = "LOWK 031520Z AUTO VRB01KT CAVOK 05/02 Q1005 NOSIG"
    let observation = try await METAR.from(string: string, lenientRemarks: true)

    #expect(observation.conditions.contains(.cavok))
    #expect(observation.visibility == .greaterThan(.meters(9999)))
    #expect(observation.temperature == 5)
    #expect(observation.dewpoint == 2)
  }

  @Test
  func `parses a CAVOK note with a remark`() async throws {
    let string =
      "METAR LFSB 031600Z AUTO 22008KT 150V260 CAVOK 12/05 Q1002 TEMPO 26025G50KT 1200 +SHRA SCT035CB"

    let observation = try await METAR.from(string: string, lenientRemarks: true)

    #expect(observation.conditions.contains(.cavok))
    #expect(observation.visibility == .greaterThan(.meters(9999)))
    #expect(observation.temperature == 12)
    #expect(observation.dewpoint == 5)
  }
}
