import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct WindsAloftEntryTests {
  let parser = WindsAloftDataGroupParser()

  @Test
  func `returns nil for blank or empty groups`() throws {
    #expect(try parser.parse("") == nil)
    #expect(try parser.parse("   ") == nil)
  }

  @Test
  func `parses 9900 as light and variable`() throws {
    let entry = try parser.parse("9900")
    #expect(entry == .lightAndVariable(temperature: nil))
  }

  @Test
  func `parses 9900 with signed temperature as light and variable`() throws {
    // 9900-10 → light and variable, −10°C
    #expect(try parser.parse("9900-10") == .lightAndVariable(temperature: -10))
    #expect(try parser.parse("9900+10") == .lightAndVariable(temperature: 10))
  }

  @Test
  func `parses 990000 as light and variable with unsigned temperature`() throws {
    // 990000 → above 24,000 ft, where temperatures are implicitly negative
    let entry = try parser.parse("990000")
    #expect(entry == .lightAndVariable(temperature: 0))
  }

  @Test(arguments: ["9912", "4500", "8700", "3712-05", "500017"])
  func `rejects impossible direction figures`(_ group: String) throws {
    #expect(throws: Error.invalidWindsAloftGroup(group)) {
      try parser.parse(group)
    }
  }

  @Test
  func `parses a 4-digit group of direction and speed with no temperature`() throws {
    // 2017 → 200° at 17 knots
    let entry = try parser.parse("2017")
    #expect(entry == .wind(direction: 200, speed: .knots(17), temperature: nil))
  }

  @Test
  func `parses a 4-digit group with a low speed`() throws {
    // 0517 → 050° at 17 knots
    let entry = try parser.parse("0517")
    #expect(entry == .wind(direction: 50, speed: .knots(17), temperature: nil))
  }

  @Test
  func `parses a group with a positive temperature`() throws {
    // 3209+02 → 320° at 09 knots, +2°C
    let entry = try parser.parse("3209+02")
    #expect(entry == .wind(direction: 320, speed: .knots(9), temperature: 2))
  }

  @Test
  func `parses a group with a negative temperature`() throws {
    // 3221-05 → 320° at 21 knots, −5°C
    let entry = try parser.parse("3221-05")
    #expect(entry == .wind(direction: 320, speed: .knots(21), temperature: -5))
  }

  @Test
  func `parses a 6-digit unsigned group above 24000 ft with a negative temperature`() throws {
    // 295947 → 290° at 59 knots, −47°C
    let entry = try parser.parse("295947")
    #expect(entry == .wind(direction: 290, speed: .knots(59), temperature: -47))
  }

  @Test
  func `parses the high wind encoding for DD greater than or equal to 51`() throws {
    // 7308 → direction = (73−50)×10 = 230°, speed = 08+100 = 108 knots, no temp
    let entry = try parser.parse("7308")
    #expect(entry == .wind(direction: 230, speed: .knots(108), temperature: nil))
  }

  @Test
  func `parses the high wind encoding with a positive temperature`() throws {
    // 7308+02 → 230° at 108 knots, +2°C
    let entry = try parser.parse("7308+02")
    #expect(entry == .wind(direction: 230, speed: .knots(108), temperature: 2))
  }

  @Test
  func `parses the high wind encoding with a negative temperature`() throws {
    // 7308-10 → 230° at 108 knots, −10°C
    let entry = try parser.parse("7308-10")
    #expect(entry == .wind(direction: 230, speed: .knots(108), temperature: -10))
  }

  @Test
  func `parses a 6-digit unsigned high wind group`() throws {
    // 770853 → direction = (77−50)×10 = 270°, speed = 08+100 = 108 knots, −53°C
    let entry = try parser.parse("770853")
    #expect(entry == .wind(direction: 270, speed: .knots(108), temperature: -53))
  }

  @Test
  func `parses a group with a zero direction north wind`() throws {
    // 3610+03 → 360° at 10 knots, +3°C
    let entry = try parser.parse("3610+03")
    #expect(entry == .wind(direction: 360, speed: .knots(10), temperature: 3))
  }

  @Test
  func `provides a speed measurement`() throws {
    let entry = WindsAloftEntry.wind(direction: 270, speed: .knots(50), temperature: -10)
    #expect(entry.speedMeasurement == Measurement<UnitSpeed>(value: 50, unit: .knots))
  }

  @Test
  func `provides a temperature measurement`() throws {
    let entry = WindsAloftEntry.wind(direction: 270, speed: .knots(50), temperature: -10)
    #expect(
      entry.temperatureMeasurement == Measurement<UnitTemperature>(value: -10, unit: .celsius)
    )
  }

  @Test
  func `provides a direction measurement`() throws {
    let entry = WindsAloftEntry.wind(direction: 270, speed: .knots(50), temperature: nil)
    #expect(entry.directionMeasurement == Measurement<UnitAngle>(value: 270, unit: .degrees))
  }

  @Test
  func `returns nil wind measurements for light and variable`() throws {
    let entry = WindsAloftEntry.lightAndVariable(temperature: nil)
    #expect(entry.speedMeasurement == nil)
    #expect(entry.temperatureMeasurement == nil)
    #expect(entry.directionMeasurement == nil)
  }

  @Test
  func `provides a temperature measurement for light and variable`() throws {
    let entry = WindsAloftEntry.lightAndVariable(temperature: -10)
    #expect(
      entry.temperatureMeasurement == Measurement<UnitTemperature>(value: -10, unit: .celsius)
    )
    #expect(entry.speedMeasurement == nil)
    #expect(entry.directionMeasurement == nil)
  }

  @Test
  func `emits canonical coded strings`() {
    #expect(WindsAloftEntry.lightAndVariable(temperature: nil).codedString == "9900")
    #expect(WindsAloftEntry.lightAndVariable(temperature: -10).codedString == "9900-10")
    #expect(WindsAloftEntry.lightAndVariable(temperature: 10).codedString == "9900+10")
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
    WindsAloftEntry.lightAndVariable(temperature: nil),
    .lightAndVariable(temperature: -10),
    .lightAndVariable(temperature: 10),
    .wind(direction: 200, speed: .knots(17), temperature: nil),
    .wind(direction: 320, speed: .knots(9), temperature: 2),
    .wind(direction: 320, speed: .knots(21), temperature: -5),
    .wind(direction: 290, speed: .knots(59), temperature: -47),
    .wind(direction: 230, speed: .knots(108), temperature: nil),
    .wind(direction: 230, speed: .knots(108), temperature: 2),
    .wind(direction: 360, speed: .knots(10), temperature: 3)
  ])
  func `round trips coded string`(_ entry: WindsAloftEntry) throws {
    #expect(try WindsAloftEntry(coded: entry.codedString) == entry)
  }

  @Test
  func `round trips through Codable`() throws {
    let entry = WindsAloftEntry.wind(direction: 270, speed: .knots(50), temperature: -10)
    let data = try JSONEncoder().encode(entry)

    #expect(String(data: data, encoding: .utf8) == #""2750-10""#)
    #expect(try JSONDecoder().decode(WindsAloftEntry.self, from: data) == entry)
  }
}
