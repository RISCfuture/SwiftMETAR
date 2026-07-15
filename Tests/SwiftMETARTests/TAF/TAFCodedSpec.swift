import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct TAFCodedTests {

  /// A parsed forecast, re-encoded to a coded string and parsed again, should
  /// preserve its groups and their forecast values.
  @Test(
    arguments: [
      "TAF KDVT 311746Z 3118/0118 12007KT P6SM -RA SCT030 OVC050 TEMPO 3118/3119 4SM RA BR "
        + "BKN020 OVC040 FM311900 13008KT P6SM VCSH SCT030 OVC050 FM312200 12009KT P6SM SCT030 "
        + "BKN060 FM010800 23010KT P6SM -SHRA VCTS SCT040 OVC050CB PROB30 0108/0112 4SM -TSRA "
        + "BR OVC040CB",
      "TAF KBLV 251800Z 2515/2615 14005KT 8000 BR FEW030 QNH2960INS BECMG 2614/2615 29008KT "
        + "3200 -RA OVC030 620304 610909 QNH2958INS BECMG 2614/2615 30008KT 9999 SKC QNH2950INS"
    ]
  )
  func codedStringReparsesToSameValues(_ string: String) async throws {
    let original = try await TAF.from(string: string)
    let reparsed = try await TAF.from(string: original.codedString)

    #expect(reparsed.airportID == original.airportID)
    #expect(reparsed.groups.count == original.groups.count)

    for (originalGroup, reparsedGroup) in zip(original.groups, reparsed.groups) {
      #expect(reparsedGroup.period.codedString == originalGroup.period.codedString)
      #expect(reparsedGroup.wind == originalGroup.wind)
      #expect(reparsedGroup.visibility == originalGroup.visibility)
      #expect(reparsedGroup.weather == originalGroup.weather)
      #expect(reparsedGroup.conditions == originalGroup.conditions)
      #expect(reparsedGroup.icing == originalGroup.icing)
      #expect(reparsedGroup.altimeter == originalGroup.altimeter)
    }
  }

  @Test
  func encodesAndDecodesAsASingleCodedStringViaCodable() throws {
    let taf = try TAF(
      coded: "TAF KSFO 121720Z 1218/1318 09010KT P6SM FEW020 FM130200 05005KT P6SM SCT040"
    )
    let data = try JSONEncoder().encode(taf)

    let json = try #require(String(data: data, encoding: .utf8))
    #expect(json.hasPrefix(#""TAF KSFO 121720Z 1218"#))

    let decoded = try JSONDecoder().decode(TAF.self, from: data)
    #expect(decoded.airportID == "KSFO")
    #expect(decoded.groups.count == taf.groups.count)
    #expect(decoded.groups.first?.wind == taf.groups.first?.wind)
  }

  @Test(
    arguments: [
      "FM130200 05005KT P6SM SCT040",
      "TEMPO 1318/1320 4SM RA BR BKN020 OVC040",
      "PROB30 0108/0112 3SM -TSRA BR OVC040CB"
    ]
  )
  func decodesAndReEncodesAGroup(_ coded: String) throws {
    let group = try TAF.Group(coded: coded)

    #expect(group.codedString == coded)

    let data = try JSONEncoder().encode(group)
    let decoded = try JSONDecoder().decode(TAF.Group.self, from: data)
    #expect(decoded.codedString == coded)
  }
}
