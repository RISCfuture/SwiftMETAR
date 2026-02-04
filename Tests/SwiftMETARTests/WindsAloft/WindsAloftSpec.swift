import Foundation
import Nimble
import Quick

@testable import SwiftMETAR

class WindsAloftSpec: AsyncSpec {
  override class func spec() {
    describe("low-level product") {
      it("parses a low-level winds aloft product") {
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
        expect(result.header.productID).to(equal("FBUS31"))
        expect(result.header.issuingOffice).to(equal("KWNO"))
        expect(result.header.bulletinID).to(equal("FD1US1"))
        expect(result.level).to(equal(.low))

        // Metadata
        expect(result.altitudes).to(
          equal([3000, 6000, 9000, 12000, 18000, 24000, 30000, 34000, 39000])
        )

        // Stations
        expect(result.stations.count).to(equal(3))

        // ABI station
        let abi = result.stations[0]
        expect(abi.id).to(equal("ABI"))
        // ABI has no 3000 ft data
        expect(abi[3000]).to(beNil())
        // ABI at 6000 ft: 0517+06
        expect(abi[6000]).to(
          equal(.wind(direction: 50, speed: .knots(17), temperature: 6))
        )
        // ABI at 9000 ft: 3209+02
        expect(abi[9000]).to(
          equal(.wind(direction: 320, speed: .knots(9), temperature: 2))
        )
        // ABI at 12000 ft: 3221-05
        expect(abi[12000]).to(
          equal(.wind(direction: 320, speed: .knots(21), temperature: -5))
        )
        // ABI at 39000 ft: 770853
        expect(abi[39000]).to(
          equal(.wind(direction: 270, speed: .knots(108), temperature: -53))
        )

        // ABQ station
        let abq = result.stations[1]
        expect(abq.id).to(equal("ABQ"))
        expect(abq[3000]).to(beNil())
        expect(abq[6000]).to(beNil())
        // ABQ at 9000 ft: 3325+03
        expect(abq[9000]).to(
          equal(.wind(direction: 330, speed: .knots(25), temperature: 3))
        )

        // ABR station — has all altitudes
        let abr = result.stations[2]
        expect(abr.id).to(equal("ABR"))
        // ABR at 3000 ft: 3214
        expect(abr[3000]).to(
          equal(.wind(direction: 320, speed: .knots(14), temperature: nil))
        )
        // ABR at 6000 ft: 3431-04
        expect(abr[6000]).to(
          equal(.wind(direction: 340, speed: .knots(31), temperature: -4))
        )
        // ABR at 39000 ft: 344353
        expect(abr[39000]).to(
          equal(.wind(direction: 340, speed: .knots(43), temperature: -53))
        )
      }

      it("provides altitude measurements") {
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

        expect(result.altitudeMeasurements.count).to(equal(9))
        expect(result.altitudeMeasurements[0]).to(
          equal(Measurement<UnitLength>(value: 3000, unit: .feet))
        )
      }
    }

    describe("high-level product") {
      it("parses a high-level winds aloft product") {
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

        expect(result.header.productID).to(equal("FBUS37"))
        expect(result.level).to(equal(.high))
        expect(result.altitudes).to(equal([45000, 53000]))
        expect(result.stations.count).to(equal(2))

        let abi = result.stations[0]
        expect(abi.id).to(equal("ABI"))
        expect(abi.entries.count).to(equal(2))
        // ABI at 45000: 288454 → 280° at 84 knots, −54°C
        expect(abi[45000]).to(
          equal(.wind(direction: 280, speed: .knots(84), temperature: -54))
        )
        // ABI at 53000: 275466 → 270° at 54 knots, −66°C
        expect(abi[53000]).to(
          equal(.wind(direction: 270, speed: .knots(54), temperature: -66))
        )
      }
    }

    describe("station subscript") {
      it("looks up entries by altitude") {
        let station = WindsAloft.Station(
          id: "TST",
          entries: [
            .init(altitude: 3000, data: .wind(direction: 270, speed: .knots(10), temperature: nil)),
            .init(altitude: 6000, data: .wind(direction: 280, speed: .knots(20), temperature: 5))
          ]
        )

        expect(station[3000]).to(
          equal(.wind(direction: 270, speed: .knots(10), temperature: nil))
        )
        expect(station[6000]).to(
          equal(.wind(direction: 280, speed: .knots(20), temperature: 5))
        )
        expect(station[9000]).to(beNil())
      }
    }

    describe("light and variable in product") {
      it("parses 9900 entries correctly") {
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
        expect(tst[3000]).to(equal(.lightAndVariable))
      }
    }
  }
}
