import Foundation
@preconcurrency import RegexBuilder

final class WaterEquivalentDepthParser: RemarkParser {
  var urgency = Remark.Urgency.routine

  private let depthRef = Reference<Float>()
  private lazy var rx = Regex {
    Anchor.wordBoundary
    "933"
    Capture(as: depthRef) {
      Repeat(.digit, count: 3)
    } transform: {
      .init($0)! / 10.0
    }
    Anchor.wordBoundary
  }

  func parse(remarks: inout String, date _: DateComponents) throws -> Remark? {
    guard let result = try rx.firstMatch(in: remarks) else { return nil }
    let depth = result[depthRef]

    remarks.removeSubrange(result.range)
    return .waterEquivalentDepth(depth)
  }
}
