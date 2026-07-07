import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct AltimeterTests {
  @Test
  func parsesAnInHgAltimeterSetting() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let observation = try await METAR.from(string: string)

    #expect(observation.altimeter == .inHg(2992))
    #expect(observation.altimeter!.measurement.value == 29.92)
  }

  @Test
  func parsesAnHPaAltimeterSetting() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 Q1021 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let observation = try await METAR.from(string: string)

    #expect(observation.altimeter == .hPa(1021))
    #expect(
      abs(observation.altimeter!.measurement.converted(to: .inchesOfMercury).value - 30.15) < 0.01
    )
  }
}
