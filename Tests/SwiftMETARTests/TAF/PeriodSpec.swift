import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct PeriodTests {
  @Test
  func `parses a TAF with a group that crosses a month boundary`() async throws {
    let string = """
      TAF KDVT 311746Z 3118/0118 12007KT P6SM -RA SCT030 OVC050 TEMPO 3118/3119 4SM RA BR BKN020 \
      OVC040 FM311900 13008KT P6SM VCSH SCT030 OVC050 FM312200 12009KT P6SM SCT030 BKN060 FM010800 \
      23010KT P6SM -SHRA VCTS SCT040 OVC050CB PROB30 0108/0112 4SM -TSRA BR OVC040CB
      """
    let referenceDate = Calendar.current.date(
      from: .init(year: 2024, month: 3, day: 31, hour: 6, minute: 58, second: 2)
    )
    let forecast = try await TAF.from(string: string, on: referenceDate)

    guard case .range(let period) = forecast.groups.first!.period else {
      Issue.record("Expected first period to be of type .range")
      return
    }
    #expect(period.start.month == 3)
    #expect(period.start.day == 31)
    #expect(period.end.month == 4)
    #expect(period.end.day == 1)
  }

  @Test
  func `throws an error for a BECMG whose end date precedes its start date`() async throws {
    let string = """
      TAF COR SPJL 241715Z 2418/2518 32018KT 9999 BKN020 TX17/2419Z TN04/2510Z TEMPO 2418/2422 \
      32022G35KT SCT020TCU SCT100 BECMG 2423/2224 23007KT FM250300 VRB02KT 9999 SCT020
      """
    let referenceDate = Calendar.current.date(
      from: .init(year: 2025, month: 8, day: 24, hour: 18, minute: 0, second: 0)
    )

    await #expect {
      try await TAF.from(string: string, on: referenceDate)
    } throws: { error in
      guard let swiftMETARError = error as? SwiftMETAR.Error,
        case .invalidPeriod = swiftMETARError
      else { return false }
      return true
    }
  }

  @Test(arguments: [
    "2515/2615", "FM261500", "TEMPO 2515/2615", "BECMG 2515/2615", "PROB30 2515/2615"
  ])
  func `round trips coded string`(_ coded: String) throws {
    #expect(try TAF.Group.Period(coded: coded).codedString == coded)
  }

  @Test
  func `round trips through Codable`() throws {
    let coded = "PROB30 2515/2615"
    let period = try TAF.Group.Period(coded: coded)
    let data = try JSONEncoder().encode(period)

    #expect(try JSONDecoder().decode(TAF.Group.Period.self, from: data).codedString == coded)
  }
}
