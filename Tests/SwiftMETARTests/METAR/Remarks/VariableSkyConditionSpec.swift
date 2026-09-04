import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct VariableSkyConditionTests {
  @Test
  func `parses a BKN014 V OVC remark`() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 BKN014 V OVC"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .variableSkyCondition(low: .broken, high: .overcast, height: 1400)
      )
    )
  }

  @Test
  func `parses a BKN V OVC remark`() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 BKN V OVC"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .variableSkyCondition(low: .broken, high: .overcast, height: nil)
      )
    )
  }
}
