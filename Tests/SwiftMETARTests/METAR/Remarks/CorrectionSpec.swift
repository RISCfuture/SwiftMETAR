import Foundation
import NumberKit
import Testing

@testable import SwiftMETAR

@Suite
struct CorrectionTests {
  @Test
  func `parses a COR 0205 remark`() async throws {
    let string =
      "METAR KGXF 260158Z COR 28009KT 10SM CLR 37/M06 A2972 RMK AO2A SLP051 T03741062 $ COR 0205"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .correction(time: Date().this(day: 26, hour: 2, minute: 5)!)
      )
    )
  }
}
