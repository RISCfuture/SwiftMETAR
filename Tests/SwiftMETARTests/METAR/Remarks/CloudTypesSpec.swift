import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct CloudTypesTests {
  @Test
  func `parses an 8/6// remark`() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 8/6//"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .cloudTypes(low: .stNebFra, middle: .obscured, high: .obscured)
      )
    )
  }

  @Test
  func `parses an 8/903 remark`() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 8/903"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .cloudTypes(low: .cbCap, middle: .none, high: .ciSpiCb)
      )
    )
  }
}
