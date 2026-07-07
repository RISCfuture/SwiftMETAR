import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct SignificantCloudsTests {
  @Test
  func parsesACBWMovERemark() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 CB W MOV E"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .significantClouds(
          type: .cb,
          directions: [.west],
          movingDirection: .east,
          distant: false,
          apparent: false
        )
      )
    )
  }

  @Test
  func parsesACBDSNTWRemark() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 CB DSNT W"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .significantClouds(
          type: .cb,
          directions: [.west],
          movingDirection: nil,
          distant: true,
          apparent: false
        )
      )
    )
  }

  @Test
  func parsesATCUWRemark() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 TCU W"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .significantClouds(
          type: .cuCon,
          directions: [.west],
          movingDirection: nil,
          distant: false,
          apparent: false
        )
      )
    )
  }

  @Test
  func parsesAACCNWRemark() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 ACC NW"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .significantClouds(
          type: .acCas,
          directions: [.northwest],
          movingDirection: nil,
          distant: false,
          apparent: false
        )
      )
    )
  }

  @Test
  func parsesAACSLSWWRemark() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 ACSL SW-W"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .significantClouds(
          type: .acLen,
          directions: [.southwest, .west],
          movingDirection: nil,
          distant: false,
          apparent: false
        )
      )
    )
  }

  @Test
  func parsesAAPRNTROTORCLDNERemark() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 APRNT ROTOR CLD NE"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .significantClouds(
          type: .rotor,
          directions: [.northeast],
          movingDirection: nil,
          distant: false,
          apparent: true
        )
      )
    )
  }

  @Test
  func parsesACCSLSRemark() async throws {
    let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 CCSL S"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .significantClouds(
          type: .ccLen,
          directions: [.south],
          movingDirection: nil,
          distant: false,
          apparent: false
        )
      )
    )
  }

  @Test
  func parsesACBDSNTNANDNERemark() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 CB DSNT N AND NE"
    let observation = try await METAR.from(string: string)

    #expect(
      observation.remarks.map(\.remark).contains(
        .significantClouds(
          type: .cb,
          directions: [.north, .northeast],
          movingDirection: nil,
          distant: true,
          apparent: false
        )
      )
    )
  }
}
