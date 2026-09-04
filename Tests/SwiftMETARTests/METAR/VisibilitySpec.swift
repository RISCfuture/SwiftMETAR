import Foundation
import NumberKit
import Testing

@testable import SwiftMETAR

@Suite
struct VisibilityTests {
  @Test
  func `parses fractional visibilities less than 1 SM`() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let visibility = try await METAR.from(string: string).visibility
    #expect(visibility == .equal(.statuteMiles(3 / 4 as Ratio)))
  }

  @Test
  func `parses fractional visibilities greater than 1 SM`() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 1 1/2SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let visibility = try await METAR.from(string: string).visibility
    #expect(visibility == .equal(.statuteMiles(3 / 2 as Ratio)))
  }

  @Test
  func `parses whole visibilities greater than 1 SM`() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let visibility = try await METAR.from(string: string).visibility
    #expect(visibility == .equal(.statuteMiles(3 as Ratio)))
  }

  @Test
  func `parses visibilities less than 1/4 SM`() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 M1/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let visibility = try await METAR.from(string: string).visibility
    #expect(visibility == .lessThan(.statuteMiles(1 / 4 as Ratio)))
  }

  @Test
  func `parses visibilities greater than or equal to 10 SM`() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 10SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let visibility = try await METAR.from(string: string).visibility
    #expect(visibility == .greaterThan(.statuteMiles(10 as Ratio)))
  }

  @Test
  func `parses visibilities in meters`() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3000 R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let visibility = try await METAR.from(string: string).visibility
    #expect(visibility == .equal(.meters(3000)))
  }

  @Test
  func `parses visibilities greater than or equal to 9999 m`() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 9999 R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let visibility = try await METAR.from(string: string).visibility
    #expect(visibility == .greaterThan(.meters(9999)))
  }

  @Test
  func `parses missing visibilities`() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 M R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let metar = try await METAR.from(string: string)
    #expect(metar.visibility == nil)
  }

  @Test
  func `emits canonical coded strings`() {
    #expect(Visibility.equal(.statuteMiles(3 / 4 as Ratio)).codedString == "3/4SM")
    #expect(Visibility.equal(.statuteMiles(3 / 2 as Ratio)).codedString == "1 1/2SM")
    #expect(Visibility.equal(.statuteMiles(3 as Ratio)).codedString == "3SM")
    #expect(Visibility.lessThan(.statuteMiles(1 / 4 as Ratio)).codedString == "M1/4SM")
    #expect(Visibility.greaterThan(.statuteMiles(6 as Ratio)).codedString == "P6SM")
    #expect(Visibility.greaterThan(.statuteMiles(10 as Ratio)).codedString == "P10SM")
    #expect(Visibility.equal(.meters(3000)).codedString == "3000")
    #expect(Visibility.greaterThan(.meters(9999)).codedString == "P9999")
    #expect(Visibility.equal(.feet(1200)).codedString == "1200FT")
    #expect(Visibility.lessThan(.feet(1000)).codedString == "M1000FT")
    #expect(
      Visibility.variable(.equal(.feet(1000)), .equal(.feet(1400))).codedString
        == "1000FTV1400FT"
    )
    #expect(Visibility.notRecorded.codedString == "////SM")

    // `statuteMilesDecimal` has no native coded form; it is a lossy decimal rendering.
    #expect(Visibility.Value.statuteMilesDecimal(0.75).codedString == "0.75SM")
  }

  @Test(arguments: [
    Visibility.equal(.statuteMiles(3 / 4 as Ratio)),
    .equal(.statuteMiles(3 / 2 as Ratio)),
    .equal(.statuteMiles(3 as Ratio)),
    .lessThan(.statuteMiles(1 / 4 as Ratio)),
    .greaterThan(.statuteMiles(6 as Ratio)),
    .greaterThan(.statuteMiles(10 as Ratio)),
    .equal(.meters(3000)),
    .greaterThan(.meters(9999)),
    .equal(.feet(1200)),
    .lessThan(.feet(1000)),
    .variable(.equal(.feet(1000)), .equal(.feet(1400))),
    .notRecorded
  ])
  func `round trips coded string`(_ visibility: Visibility) throws {
    #expect(try Visibility(coded: visibility.codedString) == visibility)
  }

  @Test(arguments: [
    Visibility.Value.statuteMiles(3 / 4 as Ratio),
    .statuteMiles(3 / 2 as Ratio),
    .statuteMiles(3 as Ratio),
    .feet(1200),
    .meters(3000)
  ])
  func `round trips a visibility value coded string`(_ value: Visibility.Value) throws {
    #expect(try Visibility.Value(coded: value.codedString) == value)
  }

  @Test
  func `round trips through Codable`() throws {
    let visibility = Visibility.equal(.feet(1200))
    let data = try JSONEncoder().encode(visibility)

    #expect(String(data: data, encoding: .utf8) == #""1200FT""#)
    #expect(try JSONDecoder().decode(Visibility.self, from: data) == visibility)
  }
}
