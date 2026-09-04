import Foundation
import NumberKit
import Testing

@testable import SwiftMETAR

@Suite
struct NextTests {
  @Test
  func `parses a NEXT 2611 remark`() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 NEXT 2611"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(.next(Date().this(day: 26, hour: 11)!))
    )
  }
}
