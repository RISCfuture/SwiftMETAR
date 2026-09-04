import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct ThunderstormBeginEndTests {
  @Test
  func `parses a TSB0159E30 remark`() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 TSB0159E30"
    let observation = try await METAR.from(string: string)

    let begin = Date().this(day: 1, hour: 1, minute: 59)!
    let end = Date().this(day: 1, hour: 19, minute: 30)!
    #expect(
      observation.remarks.map(\.remark).contains(
        .thunderstormBeginEnd(events: [
          .init(type: .began, time: begin),
          .init(type: .ended, time: end)
        ])
      )
    )
  }
}
