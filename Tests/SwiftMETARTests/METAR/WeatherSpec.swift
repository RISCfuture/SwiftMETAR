import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct WeatherTests {
  @Test
  func `parses light drizzle`() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT -DZ OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let phenomena = try await METAR.from(string: string).weather!
    #expect(phenomena.count == 1)

    #expect(phenomena[0].intensity == .light)
    #expect(phenomena[0].descriptor == nil)
    #expect(phenomena[0].phenomena == [.drizzle])
  }

  @Test
  func `parses light rain and snow`() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT -RASN OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let phenomena = try await METAR.from(string: string).weather!
    #expect(phenomena.count == 1)

    #expect(phenomena[0].intensity == .light)
    #expect(phenomena[0].descriptor == nil)
    #expect(phenomena[0].phenomena == [.rain, .snow])
  }

  @Test
  func `parses snow and mist`() async throws {
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
  func `parses light freezing rain and fog`() async throws {
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
  func `parses moderate rainshower`() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT SHRA OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let phenomena = try await METAR.from(string: string).weather!
    #expect(phenomena.count == 1)

    #expect(phenomena[0].intensity == .moderate)
    #expect(phenomena[0].descriptor == .showering)
    #expect(phenomena[0].phenomena == [.rain])
  }

  @Test
  func `parses blowing sand in the vicinity`() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT VCBLSA OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let phenomena = try await METAR.from(string: string).weather!
    #expect(phenomena.count == 1)

    #expect(phenomena[0].intensity == .vicinity)
    #expect(phenomena[0].descriptor == .blowing)
    #expect(phenomena[0].phenomena == [.sand])
  }

  @Test
  func `parses light rain and snow fog and haze`() async throws {
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
  func `parses thunderstorms`() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT TS OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let phenomena = try await METAR.from(string: string).weather!
    #expect(phenomena.count == 1)

    #expect(phenomena[0].intensity == .moderate)
    #expect(phenomena[0].descriptor == nil)
    #expect(phenomena[0].phenomena == [.thunderstorm])
  }

  @Test
  func `parses thunderstorm heavy rain`() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let phenomena = try await METAR.from(string: string).weather!
    #expect(phenomena.count == 1)

    #expect(phenomena[0].intensity == .heavy)
    #expect(phenomena[0].descriptor == .thunderstorms)
    #expect(phenomena[0].phenomena == [.rain])
  }

  @Test
  func `parses tornado thunderstorm associated rain and hail and mist`() async throws {
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
  func `parses missing weather`() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT M OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let metar = try await METAR.from(string: string)
    #expect(metar.weather == nil)
  }

  @Test
  func `emits canonical coded strings`() {
    #expect(
      Weather(intensity: .heavy, descriptor: .showering, phenomena: [.rain]).codedString == "+SHRA"
    )
    #expect(Weather(intensity: .light, descriptor: nil, phenomena: [.rain]).codedString == "-RA")
    #expect(
      Weather(intensity: .vicinity, descriptor: nil, phenomena: [.thunderstorm]).codedString
        == "VCTS"
    )
    #expect(Weather(intensity: .moderate, descriptor: nil, phenomena: [.mist]).codedString == "BR")
    #expect(
      Weather(intensity: .heavy, descriptor: .thunderstorms, phenomena: [.rain]).codedString
        == "+TSRA"
    )
    #expect(
      Weather(intensity: .light, descriptor: .freezing, phenomena: [.rain]).codedString == "-FZRA"
    )
    // Phenomena are emitted in Phenomenon declaration order regardless of set order.
    #expect(
      Weather(intensity: .moderate, descriptor: nil, phenomena: [.snow, .rain]).codedString
        == "RASN"
    )
    #expect(
      Weather(intensity: .moderate, descriptor: .thunderstorms, phenomena: [.hail, .rain])
        .codedString == "TSRAGR"
    )
    #expect(
      Weather(intensity: .vicinity, descriptor: .blowing, phenomena: [.sand]).codedString
        == "VCBLSA"
    )
  }

  @Test(arguments: [
    Weather(intensity: .heavy, descriptor: .showering, phenomena: [.rain]),
    Weather(intensity: .light, descriptor: nil, phenomena: [.rain]),
    Weather(intensity: .vicinity, descriptor: nil, phenomena: [.thunderstorm]),
    Weather(intensity: .moderate, descriptor: nil, phenomena: [.mist]),
    Weather(intensity: .heavy, descriptor: .thunderstorms, phenomena: [.rain]),
    Weather(intensity: .light, descriptor: .freezing, phenomena: [.rain]),
    Weather(intensity: .moderate, descriptor: nil, phenomena: [.rain, .snow]),
    Weather(intensity: .vicinity, descriptor: .blowing, phenomena: [.sand]),
    Weather(intensity: .moderate, descriptor: .thunderstorms, phenomena: [.rain, .hail])
  ])
  func `round trips coded string`(_ weather: Weather) throws {
    #expect(try Weather(coded: weather.codedString) == weather)
  }

  @Test
  func `round trips through Codable`() throws {
    let weather = Weather(intensity: .heavy, descriptor: .thunderstorms, phenomena: [.rain])
    let data = try JSONEncoder().encode(weather)

    #expect(String(data: data, encoding: .utf8) == #""+TSRA""#)
    #expect(try JSONDecoder().decode(Weather.self, from: data) == weather)
  }
}
