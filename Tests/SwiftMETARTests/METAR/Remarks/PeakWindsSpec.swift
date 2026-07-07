import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct PeakWindsTests {
  @Test
  func parsesAPKWND2804515Remark() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 PK WND 28045/15"
    let observation = try await METAR.from(string: string)

    let date = Date().this(day: 1, hour: 19, minute: 15)!

    #expect(
      observation.remarks.map(\.remark).contains(
        .peakWinds(.direction(280, speed: .knots(45), gust: nil), time: date)
      )
    )
  }

  @Test
  func parsesAPKWND280451215Remark() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 PK WND 28045/1215"
    let observation = try await METAR.from(string: string)

    let date = Date().this(day: 1, hour: 12, minute: 15)!

    #expect(
      observation.remarks.map(\.remark).contains(
        .peakWinds(.direction(280, speed: .knots(45), gust: nil), time: date)
      )
    )
  }
}
