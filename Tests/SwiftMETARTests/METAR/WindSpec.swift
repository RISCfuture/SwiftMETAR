import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct WindTests {
  @Test
  func parsesWindsLessThan10Knots() async throws {
    let string =
      #"METAR KOKC 011955Z AUTO 05008KT 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"#
    let wind = try await METAR.from(string: string).wind
    #expect(wind == .direction(50, speed: .knots(8)))
  }

  @Test
  func parsesWindsLessThan100Knots() async throws {
    let string =
      #"METAR KOKC 011955Z AUTO 15014KT 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"#
    let wind = try await METAR.from(string: string).wind
    #expect(wind == .direction(150, speed: .knots(14)))
  }

  @Test
  func parsesWindsGreaterThanOrEqualTo100Knots() async throws {
    let string =
      #"METAR KOKC 011955Z AUTO 340112KT 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"#
    let wind = try await METAR.from(string: string).wind
    #expect(wind == .direction(340, speed: .knots(112)))
  }

  @Test
  func parsesWindGusts() async throws {
    let string =
      #"METAR KOKC 011955Z AUTO 27020G35KT 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"#
    let wind = try await METAR.from(string: string).wind
    #expect(wind == .direction(270, speed: .knots(20), gust: .knots(35)))
  }

  @Test
  func parsesLightVariableWinds() async throws {
    let string =
      #"METAR KOKC 011955Z AUTO VRB03KT 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"#
    let wind = try await METAR.from(string: string).wind
    #expect(wind == .variable(speed: .knots(3)))
  }

  @Test
  func parsesLightVariableWindsWithHeadingRange() async throws {
    let string =
      #"METAR KOKC 011955Z AUTO VRB03KT 030V150 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"#
    let wind = try await METAR.from(string: string).wind
    #expect(wind == .variable(speed: .knots(3), headingRange: (30, 150)))
  }

  @Test
  func parsesStrongVariableWinds() async throws {
    let string =
      #"METAR KOKC 011955Z AUTO 21010KT 180V240 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"#
    let wind = try await METAR.from(string: string).wind
    #expect(wind == .directionRange(210, headingRange: (180, 240), speed: .knots(10)))
  }

  @Test
  func parsesCalmWinds() async throws {
    let string =
      #"METAR KOKC 011955Z AUTO 00000KT 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"#
    let wind = try await METAR.from(string: string).wind
    #expect(wind == .calm)
  }

  @Test
  func emitsCanonicalCodedStrings() {
    #expect(Wind.calm.codedString == "00000KT")
    #expect(Wind.direction(50, speed: .knots(8)).codedString == "05008KT")
    #expect(Wind.direction(340, speed: .knots(112)).codedString == "340112KT")
    #expect(Wind.direction(270, speed: .knots(20), gust: .knots(35)).codedString == "27020G35KT")
    #expect(Wind.variable(speed: .knots(3)).codedString == "VRB03KT")
    #expect(
      Wind.variable(speed: .knots(3), headingRange: (30, 150)).codedString == "VRB03KT 030V150"
    )
    #expect(
      Wind.directionRange(210, headingRange: (180, 240), speed: .knots(10)).codedString
        == "21010KT 180V240"
    )
    #expect(Wind.direction(90, speed: .mps(5)).codedString == "09005MPS")
  }

  @Test(arguments: [
    Wind.calm,
    .direction(50, speed: .knots(8)),
    .direction(340, speed: .knots(112)),
    .direction(270, speed: .knots(20), gust: .knots(35)),
    .variable(speed: .knots(3)),
    .variable(speed: .knots(3), headingRange: (30, 150)),
    .directionRange(210, headingRange: (180, 240), speed: .knots(10)),
    .direction(90, speed: .mps(5)),
    .direction(90, speed: .kph(15))
  ])
  func roundTripsCodedString(_ wind: Wind) throws {
    #expect(try Wind(coded: wind.codedString) == wind)
  }

  @Test
  func roundTripsThroughCodable() throws {
    let wind = Wind.direction(270, speed: .knots(20), gust: .knots(35))
    let data = try JSONEncoder().encode(wind)

    #expect(String(data: data, encoding: .utf8) == #""27020G35KT""#)
    #expect(try JSONDecoder().decode(Wind.self, from: data) == wind)
  }
}
