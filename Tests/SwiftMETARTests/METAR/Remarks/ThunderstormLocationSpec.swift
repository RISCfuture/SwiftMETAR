import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct ThunderstormLocationTests {
  @Test
  func parsesATSSEMovNERemark() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 TS SE MOV NE"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .thunderstormLocation(
          proximity: nil,
          directions: [.southeast],
          movingDirection: .northeast
        )
      )
    )
  }

  @Test
  func parsesATSSEThruNWRemark() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 TS SE THRU NW"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .thunderstormLocation(
          proximity: nil,
          directions: Set([.southeast, .south, .southwest, .west, .northwest]),
          movingDirection: nil
        )
      )
    )
  }

  @Test
  func parsesATSSENERemark() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 TS SE-NE"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .thunderstormLocation(
          proximity: nil,
          directions: [.southeast, .south, .southwest, .west, .northwest, .north, .northeast],
          movingDirection: nil
        )
      )
    )
  }

  @Test
  func parsesATSSEAndNERemark() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 TS SE AND NE"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .thunderstormLocation(
          proximity: nil,
          directions: [.southeast, .northeast],
          movingDirection: nil
        )
      )
    )
  }

  @Test
  func parsesATSNAndESRemark() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 TS N AND E-S"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .thunderstormLocation(
          proximity: nil,
          directions: [.north, .east, .southeast, .south],
          movingDirection: nil
        )
      )
    )
  }

  @Test
  func parsesATSNAndEAndSRemark() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 TS N AND E AND S"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .thunderstormLocation(
          proximity: nil,
          directions: [.north, .east, .south],
          movingDirection: nil
        )
      )
    )
  }

  @Test
  func parsesATSSENEAndNRemark() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 TS SE NE AND N"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .thunderstormLocation(
          proximity: nil,
          directions: [.southeast, .northeast, .north],
          movingDirection: nil
        )
      )
    )
  }

  @Test
  func parsesATSOHDMovNRemark() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 TS OHD MOV N"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .thunderstormLocation(proximity: .overhead, directions: [], movingDirection: .north)
      )
    )
  }

  @Test
  func parsesATSMovNRemark() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 TS MOV N"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .thunderstormLocation(proximity: nil, directions: [], movingDirection: .north)
      )
    )
  }
}
