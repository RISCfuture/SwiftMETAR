import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct TemperatureDewpointTests {
  @Test
  func `parses a T00261015 remark`() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 T00261015"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .temperatureDewpoint(temperature: 2.6, dewpoint: -1.5)
      )
    )
  }

  @Test
  func `parses a T0026 remark`() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 T0026"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .temperatureDewpoint(temperature: 2.6, dewpoint: nil)
      )
    )
  }

  @Test
  func `parses a T0026//// remark`() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 T0026////"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .temperatureDewpoint(temperature: 2.6, dewpoint: nil)
      )
    )
    #expect(!observation.remarks.map(\.remark).contains(.unknown("////")))
  }
}
