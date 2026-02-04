import Foundation
import Nimble
import Quick

@testable import SwiftMETAR

class WindsAloftEntrySpec: AsyncSpec {
  override class func spec() {
    let parser = WindsAloftDataGroupParser()

    describe("data group parsing") {
      it("returns nil for blank/empty groups") {
        expect(try parser.parse("")).to(beNil())
        expect(try parser.parse("   ")).to(beNil())
      }

      it("parses 9900 as light and variable") {
        let entry = try parser.parse("9900")
        expect(entry).to(equal(.lightAndVariable))
      }

      it("parses 990000 as light and variable") {
        let entry = try parser.parse("990000")
        expect(entry).to(equal(.lightAndVariable))
      }

      it("parses a 4-digit group (direction and speed, no temp)") {
        // 2017 → 200° at 17 knots
        let entry = try parser.parse("2017")
        expect(entry).to(equal(.wind(direction: 200, speed: .knots(17), temperature: nil)))
      }

      it("parses a 4-digit group with low speed") {
        // 0517 → 050° at 17 knots
        let entry = try parser.parse("0517")
        expect(entry).to(equal(.wind(direction: 50, speed: .knots(17), temperature: nil)))
      }

      it("parses a group with positive temperature") {
        // 3209+02 → 320° at 09 knots, +2°C
        let entry = try parser.parse("3209+02")
        expect(entry).to(equal(.wind(direction: 320, speed: .knots(9), temperature: 2)))
      }

      it("parses a group with negative temperature") {
        // 3221-05 → 320° at 21 knots, −5°C
        let entry = try parser.parse("3221-05")
        expect(entry).to(equal(.wind(direction: 320, speed: .knots(21), temperature: -5)))
      }

      it("parses a 6-digit unsigned group (above 24000 ft, temp negative)") {
        // 295947 → 290° at 59 knots, −47°C
        let entry = try parser.parse("295947")
        expect(entry).to(equal(.wind(direction: 290, speed: .knots(59), temperature: -47)))
      }

      it("parses high-wind encoding (DD ≥ 51)") {
        // 7308 → direction = (73−50)×10 = 230°, speed = 08+100 = 108 knots, no temp
        let entry = try parser.parse("7308")
        expect(entry).to(equal(.wind(direction: 230, speed: .knots(108), temperature: nil)))
      }

      it("parses high-wind encoding with positive temperature") {
        // 7308+02 → 230° at 108 knots, +2°C
        let entry = try parser.parse("7308+02")
        expect(entry).to(equal(.wind(direction: 230, speed: .knots(108), temperature: 2)))
      }

      it("parses high-wind encoding with negative temperature") {
        // 7308-10 → 230° at 108 knots, −10°C
        let entry = try parser.parse("7308-10")
        expect(entry).to(equal(.wind(direction: 230, speed: .knots(108), temperature: -10)))
      }

      it("parses high-wind 6-digit unsigned group") {
        // 770853 → direction = (77−50)×10 = 270°, speed = 08+100 = 108 knots, −53°C
        let entry = try parser.parse("770853")
        expect(entry).to(equal(.wind(direction: 270, speed: .knots(108), temperature: -53)))
      }

      it("parses a group with zero direction (north wind)") {
        // 3610+03 → 360° at 10 knots, +3°C
        let entry = try parser.parse("3610+03")
        expect(entry).to(equal(.wind(direction: 360, speed: .knots(10), temperature: 3)))
      }

      it("provides speed measurement") {
        let entry = WindsAloftEntry.wind(direction: 270, speed: .knots(50), temperature: -10)
        expect(entry.speedMeasurement).to(
          equal(Measurement<UnitSpeed>(value: 50, unit: .knots))
        )
      }

      it("provides temperature measurement") {
        let entry = WindsAloftEntry.wind(direction: 270, speed: .knots(50), temperature: -10)
        expect(entry.temperatureMeasurement).to(
          equal(Measurement<UnitTemperature>(value: -10, unit: .celsius))
        )
      }

      it("provides direction measurement") {
        let entry = WindsAloftEntry.wind(direction: 270, speed: .knots(50), temperature: nil)
        expect(entry.directionMeasurement).to(
          equal(Measurement<UnitAngle>(value: 270, unit: .degrees))
        )
      }

      it("returns nil measurements for light and variable") {
        let entry = WindsAloftEntry.lightAndVariable
        expect(entry.speedMeasurement).to(beNil())
        expect(entry.temperatureMeasurement).to(beNil())
        expect(entry.directionMeasurement).to(beNil())
      }
    }
  }
}
