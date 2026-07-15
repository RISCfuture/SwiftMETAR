import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct ConditionsTests {
  @Test
  func parsesSkyClear() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR SKC 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let conditions = try await METAR.from(string: string).conditions

    #expect(conditions.count == 1)
    #expect(conditions[0] == .skyClear)
  }

  @Test
  func parsesSkyClearBelow12000() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR CLR 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let conditions = try await METAR.from(string: string).conditions

    #expect(conditions.count == 1)
    #expect(conditions[0] == .clear)
  }

  @Test
  func parsesFewAt400() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR FEW004 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let conditions = try await METAR.from(string: string).conditions

    #expect(conditions.count == 1)
    #expect(conditions[0] == .few(400))
  }

  @Test
  func parsesScatteredToweringCumulusAt2300() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR SCT023TCU 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let conditions = try await METAR.from(string: string).conditions

    #expect(conditions.count == 1)
    #expect(conditions[0] == .scattered(2300, type: .toweringCumulus))
  }

  @Test
  func parsesBrokenAt10500() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR BKN105 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let conditions = try await METAR.from(string: string).conditions

    #expect(conditions.count == 1)
    #expect(conditions[0] == .broken(10_500))
  }

  @Test
  func parsesOvercastAt25000() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR OVC250 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let conditions = try await METAR.from(string: string).conditions

    #expect(conditions.count == 1)
    #expect(conditions[0] == .overcast(25_000))
  }

  @Test
  func parsesVerticalVisibility100() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR VV001 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let conditions = try await METAR.from(string: string).conditions

    #expect(conditions.count == 1)
    #expect(conditions[0] == .indefinite(100))
  }

  @Test
  func parsesFewAt1200ScatteredAt4600() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR FEW012 SCT046 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let conditions = try await METAR.from(string: string).conditions

    #expect(conditions.count == 2)
    #expect(conditions[0] == .few(1200))
    #expect(conditions[1] == .scattered(4600))
  }

  @Test
  func parsesScatteredAt3300BrokenAt8500() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR SCT033 BKN085 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let conditions = try await METAR.from(string: string).conditions

    #expect(conditions.count == 2)
    #expect(conditions[0] == .scattered(3300))
    #expect(conditions[1] == .broken(8500))
  }

  @Test
  func parsesScatteredAt1800OvercastCumulonimbusAt3200() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR SCT018 OVC032CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let conditions = try await METAR.from(string: string).conditions

    #expect(conditions.count == 2)
    #expect(conditions[0] == .scattered(1800))
    #expect(conditions[1] == .overcast(3200, type: .cumulonimbus))
  }

  @Test
  func parsesScatteredAt900ScatteredAt2400BrokenAt4800() async throws {
    let string =
      "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR SCT009 SCT024 BKN048 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
    let conditions = try await METAR.from(string: string).conditions

    #expect(conditions.count == 3)
    #expect(conditions[0] == .scattered(900))
    #expect(conditions[1] == .scattered(2400))
    #expect(conditions[2] == .broken(4800))
  }

  @Test
  func emitsCanonicalCodedStrings() {
    #expect(Condition.clear.codedString == "CLR")
    #expect(Condition.skyClear.codedString == "SKC")
    #expect(Condition.noSignificantClouds.codedString == "NSC")
    #expect(Condition.cavok.codedString == "CAVOK")
    #expect(Condition.few(2000).codedString == "FEW020")
    #expect(Condition.scattered(2300, type: .toweringCumulus).codedString == "SCT023TCU")
    #expect(Condition.broken(5000, type: .cumulonimbus).codedString == "BKN050CB")
    #expect(Condition.overcast(25_000).codedString == "OVC250")
    #expect(Condition.indefinite(200).codedString == "VV002")
  }

  @Test(arguments: [
    Condition.clear,
    .skyClear,
    .noSignificantClouds,
    .cavok,
    .few(2000),
    .scattered(2300, type: .toweringCumulus),
    .broken(5000, type: .cumulonimbus),
    .overcast(25_000),
    .indefinite(200)
  ])
  func roundTripsCodedString(_ condition: Condition) throws {
    #expect(try Condition(coded: condition.codedString) == condition)
  }

  @Test
  func rejectsInvalidCodedStrings() {
    #expect(throws: Error.self) { try Condition(coded: "XYZ") }
    #expect(throws: Error.self) { try Condition(coded: "") }
    #expect(throws: Error.self) { try Condition(coded: "VV002CB") }
  }

  @Test
  func roundTripsThroughCodable() throws {
    let condition = Condition.broken(5000, type: .cumulonimbus)
    let data = try JSONEncoder().encode(condition)

    #expect(String(data: data, encoding: .utf8) == #""BKN050CB""#)
    #expect(try JSONDecoder().decode(Condition.self, from: data) == condition)
  }
}
