import Foundation
@preconcurrency import RegexBuilder

final class RapidSnowIncreaseParser: RemarkParser {
  var urgency = Remark.Urgency.caution

  private let increaseRef = Reference<UInt>()
  private let totalRef = Reference<UInt>()

  private lazy var rx = Regex {
    Anchor.wordBoundary
    "SNINCR "
    Capture(as: increaseRef) {
      OneOrMore(.digit)
    } transform: {
      .init($0)!
    }
    "/"
    Capture(as: totalRef) {
      OneOrMore(.digit)
    } transform: {
      .init($0)!
    }
    Anchor.wordBoundary
  }

  func parse(remarks: inout String, date _: DateComponents) throws -> Remark? {
    guard let result = try rx.firstMatch(in: remarks) else { return nil }
    let increase = result[increaseRef]
    let total = result[totalRef]

    remarks.removeSubrange(result.range)
    return .rapidSnowIncrease(increase, totalDepth: total)
  }
}
