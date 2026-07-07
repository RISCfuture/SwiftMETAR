import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct TornadicActivityTests {
  @Test
  func parsesATornadoB136NEMovWRemark() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 TORNADO B13 6 NE MOV W"
    let observation = try await METAR.from(string: string)

    let begin = Date().this(day: 1, hour: 19, minute: 13)
    #expect(
      observation.remarks.map(\.remark).contains(
        .tornadicActivity(
          type: .tornado,
          begin: begin,
          end: nil,
          location: .init(direction: .northeast, distance: 6),
          movingDirection: .west
        )
      )
    )
  }

  @Test
  func parsesAWaterspoutE136WRemark() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 TORNADO B13 WATERSPOUT E13 6 W"
    let observation = try await METAR.from(string: string)

    let end = Date().this(day: 1, hour: 19, minute: 13)
    #expect(
      observation.remarks.map(\.remark).contains(
        .tornadicActivity(
          type: .waterspout,
          begin: nil,
          end: end,
          location: .init(direction: .west, distance: 6),
          movingDirection: nil
        )
      )
    )
  }

  @Test
  func parsesAFunnelCloudB121312NWRemark() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 FUNNEL CLOUD B1213 12 NW"
    let observation = try await METAR.from(string: string)

    let begin = Date().this(day: 1, hour: 12, minute: 13)
    #expect(
      observation.remarks.map(\.remark).contains(
        .tornadicActivity(
          type: .funnelCloud,
          begin: begin,
          end: nil,
          location: .init(direction: .northwest, distance: 12),
          movingDirection: nil
        )
      )
    )
  }
}
