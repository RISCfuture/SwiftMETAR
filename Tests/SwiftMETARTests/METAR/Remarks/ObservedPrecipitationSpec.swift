import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct ObservedPrecipitationTests {
  @Test
  func `parses a VIRGA SW remark`() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 VIRGA SW"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .observedPrecipitation(type: .virga, proximity: nil, directions: [.southwest])
      )
    )
  }

  @Test
  func `parses an SH N THRU NE remark`() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 SH N THRU NE"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .observedPrecipitation(
          type: .showers,
          proximity: nil,
          directions: [.north, .northeast]
        )
      )
    )
  }

  @Test
  func `parses an SHRA DSNT SW remark`() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 SHRA DSNT SW"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .observedPrecipitation(
          type: .showeringRain,
          proximity: .distant,
          directions: [.southwest]
        )
      )
    )
  }

  @Test
  func `parses a VIRGA OHD remark`() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 VIRGA OHD"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .observedPrecipitation(type: .virga, proximity: .overhead, directions: [])
      )
    )
  }
}
