import Foundation
import RegexBuilder

final class WindshearParser: WarmableParser, @unchecked Sendable {
  private static let heightRef = Reference<UInt16>()

  private static let rx = LockedRegex(
    Regex {
      Anchor.startOfSubject
      "WS"
      Capture(as: heightRef) {
        Repeat(.digit, count: 3)
      } transform: {
        .init($0)! * 100
      }
      "/"
      WindParser.noAnchorRx
    }
  )

  func parse(_ parts: inout [String.SubSequence]) throws -> Windshear? {
    guard !parts.isEmpty else { return nil }
    let windshearStr = String(parts[0])
    guard let result = try Self.rx.wholeMatch(in: windshearStr) else { return nil }
    parts.removeFirst()

    let height = result[Self.heightRef]
    let winds = try WindParser.parse(match: result, originalString: windshearStr)

    return Windshear(height: height, wind: winds)
  }
}
