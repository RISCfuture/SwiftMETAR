import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct TurbulenceTests {
  @Test
  func parsesTurbulence() async throws {
    let string = """
      TAF KBLV 251800Z
          2515/2615 14005KT 8000 BR FEW030 QNH2960INS
          BECMG 2614/2615 31012G22KT 9999 NSW SCT040 520004 510909 QNH2952INS
          BECMG 2614/2615 30008KT 9999 SKC QNH2950INS
      """
    let forecast = try await TAF.from(string: string)
    #expect(forecast.groups[0].turbulence.isEmpty)
    #expect(
      forecast.groups[1].turbulence == [
        .init(
          location: .clearAir,
          intensity: .moderate,
          frequency: .occasional,
          base: 0,
          depth: 4000
        ),
        .init(location: nil, intensity: .light, frequency: nil, base: 9000, depth: 9000)
      ]
    )
    #expect(forecast.groups[2].turbulence.isEmpty)
  }

  @Test
  func emitsCanonicalCodedStrings() {
    #expect(
      Turbulence(
        location: .clearAir,
        intensity: .moderate,
        frequency: .occasional,
        base: 0,
        depth: 4000
      ).codedString == "520004"
    )
    #expect(
      Turbulence(location: nil, intensity: .light, frequency: nil, base: 9000, depth: 9000)
        .codedString == "510909"
    )
    #expect(
      Turbulence(location: nil, intensity: .none, frequency: nil, base: 0, depth: 0)
        .codedString == "500000"
    )
    #expect(
      Turbulence(location: nil, intensity: .extreme, frequency: nil, base: 20000, depth: 5000)
        .codedString == "5X2005"
    )
    #expect(
      Turbulence(
        location: .inCloud,
        intensity: .severe,
        frequency: .frequent,
        base: 15000,
        depth: 3000
      ).codedString == "591503"
    )
  }

  @Test(arguments: [
    Turbulence(location: nil, intensity: .none, frequency: nil, base: 0, depth: 0),
    Turbulence(location: nil, intensity: .light, frequency: nil, base: 9000, depth: 9000),
    Turbulence(
      location: .clearAir,
      intensity: .moderate,
      frequency: .occasional,
      base: 0,
      depth: 4000
    ),
    Turbulence(
      location: .clearAir,
      intensity: .moderate,
      frequency: .frequent,
      base: 5000,
      depth: 2000
    ),
    Turbulence(
      location: .inCloud,
      intensity: .moderate,
      frequency: .occasional,
      base: 12000,
      depth: 1000
    ),
    Turbulence(
      location: .inCloud,
      intensity: .moderate,
      frequency: .frequent,
      base: 8000,
      depth: 6000
    ),
    Turbulence(
      location: .clearAir,
      intensity: .severe,
      frequency: .occasional,
      base: 20000,
      depth: 3000
    ),
    Turbulence(
      location: .inCloud,
      intensity: .severe,
      frequency: .frequent,
      base: 15000,
      depth: 3000
    ),
    Turbulence(location: nil, intensity: .extreme, frequency: nil, base: 20000, depth: 5000)
  ])
  func roundTripsCodedString(_ turbulence: Turbulence) throws {
    #expect(try Turbulence(coded: turbulence.codedString) == turbulence)
  }

  @Test
  func roundTripsThroughCodable() throws {
    let turbulence = Turbulence(
      location: .clearAir,
      intensity: .moderate,
      frequency: .occasional,
      base: 0,
      depth: 4000
    )
    let data = try JSONEncoder().encode(turbulence)

    #expect(String(data: data, encoding: .utf8) == #""520004""#)
    #expect(try JSONDecoder().decode(Turbulence.self, from: data) == turbulence)
  }
}
