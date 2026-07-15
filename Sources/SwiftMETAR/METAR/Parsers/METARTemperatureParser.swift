import Foundation
import RegexBuilder

final class METARTemperatureParser: WarmableParser, @unchecked Sendable {
  private let tempParser = AlphaSignedIntegerParser(width: 2)
  private let dewpointParser = AlphaSignedIntegerParser(width: 2)

  private lazy var rx = LockedRegex(
    Regex {
      Anchor.startOfSubject
      tempParser.rx
      "/"
      Optionally { dewpointParser.rx }
    }
  )

  func warmUp() {
    _ = try? rx.wholeMatch(in: "")
  }

  func parse(_ parts: inout [String.SubSequence]) throws -> (Int8?, Int8?) {
    if parts.isEmpty { return (nil, nil) }
    let tempStr = String(parts[0])

    return try rx.wholeMatch(in: tempStr).map { match in
      guard let temp = tempParser.parse(match) else { return (nil, nil) }
      let dp = dewpointParser.parse(match)

      parts.removeFirst()
      return (temp, dp)
    } ?? (nil, nil)
  }
}
