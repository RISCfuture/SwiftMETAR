import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct WindsAloftTests {
  // MARK: - low-level product

  @Test
  func parsesALowLevelWindsAloftProduct() async throws {
    let string = [
      "000",
      "FBUS31 KWNO 032000",
      "FD1US1",
      "DATA BASED ON 031800Z",
      "VALID 040000Z   FOR USE 2000-0300Z. TEMPS NEG ABV 24000",
      "",
      "FT  3000    6000    9000   12000   18000   24000  30000  34000  39000",
      "ABI      0517+06 3209+02 3221-05 2941-18 2953-31 295947 288253 770853",
      "ABQ              3325+03 3427-02 3343-16 3347-30 355547 354956 285561",
      "ABR 3214 3431-04 3540-09 3536-15 3431-28 3335-41 312756 323555 344353"
    ].joined(separator: "\n")
    let result = try await WindsAloft.from(string: string)

    // Header
    #expect(result.header.productID == "FBUS31")
    #expect(result.header.issuingOffice == "KWNO")
    #expect(result.header.bulletinID == "FD1US1")
    #expect(result.level == .low)

    // Metadata
    #expect(result.altitudes == [3000, 6000, 9000, 12000, 18000, 24000, 30000, 34000, 39000])

    // Stations
    #expect(result.stations.count == 3)

    // ABI station
    let abi = result.stations[0]
    #expect(abi.id == "ABI")
    // ABI has no 3000 ft data
    #expect(abi[3000] == nil)
    // ABI at 6000 ft: 0517+06
    #expect(abi[6000] == .wind(direction: 50, speed: .knots(17), temperature: 6))
    // ABI at 9000 ft: 3209+02
    #expect(abi[9000] == .wind(direction: 320, speed: .knots(9), temperature: 2))
    // ABI at 12000 ft: 3221-05
    #expect(abi[12000] == .wind(direction: 320, speed: .knots(21), temperature: -5))
    // ABI at 39000 ft: 770853
    #expect(abi[39000] == .wind(direction: 270, speed: .knots(108), temperature: -53))

    // ABQ station
    let abq = result.stations[1]
    #expect(abq.id == "ABQ")
    #expect(abq[3000] == nil)
    #expect(abq[6000] == nil)
    // ABQ at 9000 ft: 3325+03
    #expect(abq[9000] == .wind(direction: 330, speed: .knots(25), temperature: 3))

    // ABR station — has all altitudes
    let abr = result.stations[2]
    #expect(abr.id == "ABR")
    // ABR at 3000 ft: 3214
    #expect(abr[3000] == .wind(direction: 320, speed: .knots(14), temperature: nil))
    // ABR at 6000 ft: 3431-04
    #expect(abr[6000] == .wind(direction: 340, speed: .knots(31), temperature: -4))
    // ABR at 39000 ft: 344353
    #expect(abr[39000] == .wind(direction: 340, speed: .knots(43), temperature: -53))
  }

  @Test
  func providesAltitudeMeasurements() async throws {
    let string = [
      "000",
      "FBUS31 KWNO 032000",
      "FD1US1",
      "DATA BASED ON 031800Z",
      "VALID 040000Z   FOR USE 2000-0300Z. TEMPS NEG ABV 24000",
      "",
      "FT  3000    6000    9000   12000   18000   24000  30000  34000  39000",
      "ABI      0517+06 3209+02 3221-05 2941-18 2953-31 295947 288253 770853"
    ].joined(separator: "\n")
    let result = try await WindsAloft.from(string: string)

    #expect(result.altitudeMeasurements.count == 9)
    #expect(result.altitudeMeasurements[0] == Measurement<UnitLength>(value: 3000, unit: .feet))
  }

  // MARK: - high-level product

  @Test
  func parsesAHighLevelWindsAloftProduct() async throws {
    let string = [
      "000",
      "FBUS37 KWNO 032000",
      "FD8US7",
      "DATA BASED ON 031800Z",
      "VALID 040000Z   FOR USE 2000-0300Z. TEMPS NEG ABV 24000",
      "",
      "FT   45000  53000",
      "ABI 288454 275466",
      "ABQ 295159 284862"
    ].joined(separator: "\n")
    let result = try await WindsAloft.from(string: string)

    #expect(result.header.productID == "FBUS37")
    #expect(result.level == .high)
    #expect(result.altitudes == [45000, 53000])
    #expect(result.stations.count == 2)

    let abi = result.stations[0]
    #expect(abi.id == "ABI")
    #expect(abi.entries.count == 2)
    // ABI at 45000: 288454 → 280° at 84 knots, −54°C
    #expect(abi[45000] == .wind(direction: 280, speed: .knots(84), temperature: -54))
    // ABI at 53000: 275466 → 270° at 54 knots, −66°C
    #expect(abi[53000] == .wind(direction: 270, speed: .knots(54), temperature: -66))
  }

  // MARK: - station subscript

  @Test
  func looksUpEntriesByAltitude() throws {
    let station = WindsAloft.Station(
      id: "TST",
      entries: [
        .init(altitude: 3000, data: .wind(direction: 270, speed: .knots(10), temperature: nil)),
        .init(altitude: 6000, data: .wind(direction: 280, speed: .knots(20), temperature: 5))
      ]
    )

    #expect(station[3000] == .wind(direction: 270, speed: .knots(10), temperature: nil))
    #expect(station[6000] == .wind(direction: 280, speed: .knots(20), temperature: 5))
    #expect(station[9000] == nil)
  }

  // MARK: - light and variable in product

  @Test
  func parses9900EntriesCorrectly() async throws {
    let string = [
      "000",
      "FBUS31 KWNO 032000",
      "FD1US1",
      "DATA BASED ON 031800Z",
      "VALID 040000Z   FOR USE 2000-0300Z. TEMPS NEG ABV 24000",
      "",
      "FT  3000    6000    9000   12000   18000   24000  30000  34000  39000",
      "TST 9900 9900+10 3209+02 3221-05 2941-18 2953-31 295947 288253 770853"
    ].joined(separator: "\n")
    let result = try await WindsAloft.from(string: string)

    let tst = result.stations[0]
    #expect(tst[3000] == .lightAndVariable)
  }
}
