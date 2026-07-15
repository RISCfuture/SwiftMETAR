import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct WindsAloftEntryTests {
  let parser = WindsAloftDataGroupParser()

  @Test
  func returnsNilForBlankEmptyGroups() throws {
    #expect(try parser.parse("") == nil)
    #expect(try parser.parse("   ") == nil)
  }

  @Test
  func parses9900AsLightAndVariable() throws {
    let entry = try parser.parse("9900")
    #expect(entry == .lightAndVariable)
  }

  @Test
  func parses990000AsLightAndVariable() throws {
    let entry = try parser.parse("990000")
    #expect(entry == .lightAndVariable)
  }

  @Test
  func parsesA4DigitGroupDirectionAndSpeedNoTemp() throws {
    // 2017 → 200° at 17 knots
    let entry = try parser.parse("2017")
    #expect(entry == .wind(direction: 200, speed: .knots(17), temperature: nil))
  }

  @Test
  func parsesA4DigitGroupWithLowSpeed() throws {
    // 0517 → 050° at 17 knots
    let entry = try parser.parse("0517")
    #expect(entry == .wind(direction: 50, speed: .knots(17), temperature: nil))
  }

  @Test
  func parsesAGroupWithPositiveTemperature() throws {
    // 3209+02 → 320° at 09 knots, +2°C
    let entry = try parser.parse("3209+02")
    #expect(entry == .wind(direction: 320, speed: .knots(9), temperature: 2))
  }

  @Test
  func parsesAGroupWithNegativeTemperature() throws {
    // 3221-05 → 320° at 21 knots, −5°C
    let entry = try parser.parse("3221-05")
    #expect(entry == .wind(direction: 320, speed: .knots(21), temperature: -5))
  }

  @Test
  func parsesA6DigitUnsignedGroupAbove24000FtTempNegative() throws {
    // 295947 → 290° at 59 knots, −47°C
    let entry = try parser.parse("295947")
    #expect(entry == .wind(direction: 290, speed: .knots(59), temperature: -47))
  }

  @Test
  func parsesHighWindEncodingDDGreaterThanOrEqualTo51() throws {
    // 7308 → direction = (73−50)×10 = 230°, speed = 08+100 = 108 knots, no temp
    let entry = try parser.parse("7308")
    #expect(entry == .wind(direction: 230, speed: .knots(108), temperature: nil))
  }

  @Test
  func parsesHighWindEncodingWithPositiveTemperature() throws {
    // 7308+02 → 230° at 108 knots, +2°C
    let entry = try parser.parse("7308+02")
    #expect(entry == .wind(direction: 230, speed: .knots(108), temperature: 2))
  }

  @Test
  func parsesHighWindEncodingWithNegativeTemperature() throws {
    // 7308-10 → 230° at 108 knots, −10°C
    let entry = try parser.parse("7308-10")
    #expect(entry == .wind(direction: 230, speed: .knots(108), temperature: -10))
  }

  @Test
  func parsesHighWind6DigitUnsignedGroup() throws {
    // 770853 → direction = (77−50)×10 = 270°, speed = 08+100 = 108 knots, −53°C
    let entry = try parser.parse("770853")
    #expect(entry == .wind(direction: 270, speed: .knots(108), temperature: -53))
  }

  @Test
  func parsesAGroupWithZeroDirectionNorthWind() throws {
    // 3610+03 → 360° at 10 knots, +3°C
    let entry = try parser.parse("3610+03")
    #expect(entry == .wind(direction: 360, speed: .knots(10), temperature: 3))
  }

  @Test
  func providesSpeedMeasurement() throws {
    let entry = WindsAloftEntry.wind(direction: 270, speed: .knots(50), temperature: -10)
    #expect(entry.speedMeasurement == Measurement<UnitSpeed>(value: 50, unit: .knots))
  }

  @Test
  func providesTemperatureMeasurement() throws {
    let entry = WindsAloftEntry.wind(direction: 270, speed: .knots(50), temperature: -10)
    #expect(
      entry.temperatureMeasurement == Measurement<UnitTemperature>(value: -10, unit: .celsius)
    )
  }

  @Test
  func providesDirectionMeasurement() throws {
    let entry = WindsAloftEntry.wind(direction: 270, speed: .knots(50), temperature: nil)
    #expect(entry.directionMeasurement == Measurement<UnitAngle>(value: 270, unit: .degrees))
  }

  @Test
  func returnsNilMeasurementsForLightAndVariable() throws {
    let entry = WindsAloftEntry.lightAndVariable
    #expect(entry.speedMeasurement == nil)
    #expect(entry.temperatureMeasurement == nil)
    #expect(entry.directionMeasurement == nil)
  }

  @Test
  func emitsCanonicalCodedStrings() {
    #expect(WindsAloftEntry.lightAndVariable.codedString == "9900")
    #expect(
      WindsAloftEntry.wind(direction: 200, speed: .knots(17), temperature: nil).codedString
        == "2017"
    )
    #expect(
      WindsAloftEntry.wind(direction: 320, speed: .knots(9), temperature: 2).codedString
        == "3209+02"
    )
    #expect(
      WindsAloftEntry.wind(direction: 320, speed: .knots(21), temperature: -5).codedString
        == "3221-05"
    )
    // Six-digit unsigned input re-emits in the canonical signed form.
    #expect(
      WindsAloftEntry.wind(direction: 290, speed: .knots(59), temperature: -47).codedString
        == "2959-47"
    )
    #expect(
      WindsAloftEntry.wind(direction: 230, speed: .knots(108), temperature: nil).codedString
        == "7308"
    )
    #expect(
      WindsAloftEntry.wind(direction: 230, speed: .knots(108), temperature: 2).codedString
        == "7308+02"
    )
    #expect(
      WindsAloftEntry.wind(direction: 360, speed: .knots(10), temperature: 3).codedString
        == "3610+03"
    )
  }

  @Test(arguments: [
    WindsAloftEntry.lightAndVariable,
    .wind(direction: 200, speed: .knots(17), temperature: nil),
    .wind(direction: 320, speed: .knots(9), temperature: 2),
    .wind(direction: 320, speed: .knots(21), temperature: -5),
    .wind(direction: 290, speed: .knots(59), temperature: -47),
    .wind(direction: 230, speed: .knots(108), temperature: nil),
    .wind(direction: 230, speed: .knots(108), temperature: 2),
    .wind(direction: 360, speed: .knots(10), temperature: 3)
  ])
  func roundTripsCodedString(_ entry: WindsAloftEntry) throws {
    #expect(try WindsAloftEntry(coded: entry.codedString) == entry)
  }

  @Test
  func roundTripsThroughCodable() throws {
    let entry = WindsAloftEntry.wind(direction: 270, speed: .knots(50), temperature: -10)
    let data = try JSONEncoder().encode(entry)

    #expect(String(data: data, encoding: .utf8) == #""2750-10""#)
    #expect(try JSONDecoder().decode(WindsAloftEntry.self, from: data) == entry)
  }
}
