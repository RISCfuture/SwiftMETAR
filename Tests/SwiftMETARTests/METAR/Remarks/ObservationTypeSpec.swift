import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct ObservationTypeTests {
  @Test
  func `parses an AO1 remark`() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO1 ACFT MSHP"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(.observationType(.automated, augmented: false))
    )
  }

  @Test
  func `parses an AO2 remark`() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 ACFT MSHP"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .observationType(.automatedWithPrecipitation, augmented: false)
      )
    )
  }

  @Test
  func `parses an A02 remark`() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK A02 ACFT MSHP"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .observationType(.automatedWithPrecipitation, augmented: false)
      )
    )
  }

  @Test
  func `parses an AO2A remark`() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2A ACFT MSHP"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .observationType(.automatedWithPrecipitation, augmented: true)
      )
    )
  }
}
