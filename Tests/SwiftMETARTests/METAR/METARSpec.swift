import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct METARTests {
  // MARK: - report type

  @Test
  func `parses the report type`() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let metar = try await METAR.from(string: string)
    #expect(metar.issuance == .routine)
  }

  // MARK: - station identifier

  @Test
  func `parses the station identifier`() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let metar = try await METAR.from(string: string)
    #expect(metar.stationID == "KOKC")
  }

  // MARK: - date and time

  @Test
  func `parses the date`() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let date = try await METAR.from(string: string).calendarDate

    #expect(date == .this(day: 1, hour: 19, minute: 55))
  }

  @Test
  func `parses the date from a reference date`() async throws {
    let referenceComponents = DateComponents(year: 2005, month: 11)
    let referenceDate = zuluCal.nextDate(
      after: Date(),
      matching: referenceComponents,
      matchingPolicy: .nextTime,
      repeatedTimePolicy: .first,
      direction: .backward
    )!

    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let date = try await METAR.from(string: string, on: referenceDate).calendarDate

    #expect(date == referenceDate.this(day: 1, hour: 19, minute: 55))
  }

  // MARK: - observer

  @Test
  func `parses automated reports`() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let metar = try await METAR.from(string: string)
    #expect(metar.observer == .automated)
  }

  @Test
  func `parses corrected reports`() async throws {
    let string =
      "METAR KOKC 011955Z COR 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let metar = try await METAR.from(string: string)
    #expect(metar.observer == .corrected)
  }

  @Test
  func `parses human observed reports`() async throws {
    let string =
      "METAR KOKC 011955Z 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let metar = try await METAR.from(string: string)
    #expect(metar.observer == .human)
  }

  // MARK: - remarks

  @Test
  func `parses empty remarks`() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992"
    let observation = try await METAR.from(string: string)
    #expect(observation.remarks.isEmpty)
  }
}
