import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct ObservedPrecipitationTests {
  @Test
  func parsesAVIRGASWRemark() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 VIRGA SW"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .observedPrecipitation(type: .virga, proximity: nil, directions: [.southwest])
      )
    )
  }

  @Test
  func parsesASHNThruNERemark() async throws {
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
  func parsesASHRADSNTSWRemark() async throws {
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
  func parsesAVIRGAOHDRemark() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 VIRGA OHD"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .observedPrecipitation(type: .virga, proximity: .overhead, directions: [])
      )
    )
  }
}
