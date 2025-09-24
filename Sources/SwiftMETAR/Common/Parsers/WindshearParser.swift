import Foundation
@preconcurrency import RegexBuilder

class WindshearParser {
  private let heightRef = Reference<UInt16>()
  private let windParser = WindParser()

  private lazy var rx = Regex {
    Anchor.startOfSubject
    "WS"
    Capture(as: heightRef) {
      Repeat(.digit, count: 3)
    } transform: {
      .init($0)! * 100
    }
    "/"
    windParser.noAnchorRx
  }

  func parse(_ parts: inout [String.SubSequence]) throws -> Windshear? {
    guard !parts.isEmpty else { return nil }
    let windshearStr = String(parts[0])
    guard let result = try rx.wholeMatch(in: windshearStr) else { return nil }
    parts.removeFirst()

    let height = result[heightRef]
    let winds = try windParser.parse(match: result, originalString: windshearStr)

    return Windshear(height: height, wind: winds)
  }
}
