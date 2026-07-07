import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct WeatherTests {
  @Test
  func parsesLightDrizzle() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT -DZ OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let phenomena = try await METAR.from(string: string).weather!
    #expect(phenomena.count == 1)

    #expect(phenomena[0].intensity == .light)
    #expect(phenomena[0].descriptor == nil)
    #expect(phenomena[0].phenomena == [.drizzle])
  }

  @Test
  func parsesLightRainAndSnow() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT -RASN OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let phenomena = try await METAR.from(string: string).weather!
    #expect(phenomena.count == 1)

    #expect(phenomena[0].intensity == .light)
    #expect(phenomena[0].descriptor == nil)
    #expect(phenomena[0].phenomena == [.rain, .snow])
  }

  @Test
  func parsesSnowAndMist() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT SN BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let phenomena = try await METAR.from(string: string).weather!
    #expect(phenomena.count == 2)

    #expect(phenomena[0].intensity == .moderate)
    #expect(phenomena[0].descriptor == nil)
    #expect(phenomena[0].phenomena == [.snow])

    #expect(phenomena[1].descriptor == nil)
    #expect(phenomena[1].phenomena == [.mist])
  }

  @Test
  func parsesLightFreezingRainAndFog() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT -FZRA FG OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let phenomena = try await METAR.from(string: string).weather!
    #expect(phenomena.count == 2)

    #expect(phenomena[0].intensity == .light)
    #expect(phenomena[0].descriptor == .freezing)
    #expect(phenomena[0].phenomena == [.rain])

    #expect(phenomena[1].descriptor == nil)
    #expect(phenomena[1].phenomena == [.fog])
  }

  @Test
  func parsesModerateRainshower() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT SHRA OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let phenomena = try await METAR.from(string: string).weather!
    #expect(phenomena.count == 1)

    #expect(phenomena[0].intensity == .moderate)
    #expect(phenomena[0].descriptor == .showering)
    #expect(phenomena[0].phenomena == [.rain])
  }

  @Test
  func parsesBlowingSandInTheVicinity() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT VCBLSA OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let phenomena = try await METAR.from(string: string).weather!
    #expect(phenomena.count == 1)

    #expect(phenomena[0].intensity == .vicinity)
    #expect(phenomena[0].descriptor == .blowing)
    #expect(phenomena[0].phenomena == [.sand])
  }

  @Test
  func parsesLightRainAndSnowFogAndHaze() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT -RASN FG HZ OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let phenomena = try await METAR.from(string: string).weather!
    #expect(phenomena.count == 3)

    #expect(phenomena[0].intensity == .light)
    #expect(phenomena[0].descriptor == nil)
    #expect(phenomena[0].phenomena == [.rain, .snow])

    #expect(phenomena[1].descriptor == nil)
    #expect(phenomena[1].phenomena == [.fog])

    #expect(phenomena[2].descriptor == nil)
    #expect(phenomena[2].phenomena == [.haze])
  }

  @Test
  func parsesThunderstorms() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT TS OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let phenomena = try await METAR.from(string: string).weather!
    #expect(phenomena.count == 1)

    #expect(phenomena[0].intensity == .moderate)
    #expect(phenomena[0].descriptor == nil)
    #expect(phenomena[0].phenomena == [.thunderstorm])
  }

  @Test
  func parsesThunderstormHeavyRain() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let phenomena = try await METAR.from(string: string).weather!
    #expect(phenomena.count == 1)

    #expect(phenomena[0].intensity == .heavy)
    #expect(phenomena[0].descriptor == .thunderstorms)
    #expect(phenomena[0].phenomena == [.rain])
  }

  @Test
  func parsesTornadoThunderstormAssociatedRainAndHailAndMist() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +FC TSRAGR BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let phenomena = try await METAR.from(string: string).weather!
    #expect(phenomena.count == 3)

    #expect(phenomena[0].intensity == .heavy)
    #expect(phenomena[0].descriptor == nil)
    #expect(phenomena[0].phenomena == [.funnelCloud])
    #expect(phenomena[0].isTornado)

    #expect(phenomena[1].intensity == .moderate)
    #expect(phenomena[1].descriptor == .thunderstorms)
    #expect(phenomena[1].phenomena == [.rain, .hail])

    #expect(phenomena[2].intensity == .moderate)
    #expect(phenomena[2].descriptor == nil)
    #expect(phenomena[2].phenomena == [.mist])
  }

  @Test
  func parsesMissingWeather() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT M OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let metar = try await METAR.from(string: string)
    #expect(metar.weather == nil)
  }
}
