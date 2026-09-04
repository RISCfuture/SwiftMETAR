import Foundation
import Testing

@testable import SwiftMETAR

@Suite
struct WindshearTests {
  @Test
  func `emits canonical coded strings`() {
    #expect(
      Windshear(height: 2000, wind: .direction(240, speed: .knots(25))).codedString
        == "WS020/24025KT"
    )
    #expect(
      Windshear(height: 500, wind: .direction(100, speed: .knots(30), gust: .knots(45)))
        .codedString == "WS005/10030G45KT"
    )
    #expect(
      Windshear(height: 1500, wind: .variable(speed: .knots(10))).codedString == "WS015/VRB10KT"
    )
  }

  @Test(arguments: [
    Windshear(height: 2000, wind: .direction(240, speed: .knots(25))),
    Windshear(height: 500, wind: .direction(100, speed: .knots(30), gust: .knots(45))),
    Windshear(height: 1500, wind: .variable(speed: .knots(10))),
    Windshear(height: 300, wind: .direction(90, speed: .mps(5)))
  ])
  func `round trips coded string`(_ windshear: Windshear) throws {
    #expect(try Windshear(coded: windshear.codedString) == windshear)
  }

  @Test
  func `round trips through Codable`() throws {
    let windshear = Windshear(height: 2000, wind: .direction(240, speed: .knots(25)))
    let encoder = JSONEncoder()
    encoder.outputFormatting = .withoutEscapingSlashes
    let data = try encoder.encode(windshear)

    #expect(String(data: data, encoding: .utf8) == #""WS020/24025KT""#)
    #expect(try JSONDecoder().decode(Windshear.self, from: data) == windshear)
  }
}
