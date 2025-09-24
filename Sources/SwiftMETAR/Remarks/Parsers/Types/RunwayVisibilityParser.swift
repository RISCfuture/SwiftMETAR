import Foundation
@preconcurrency import RegexBuilder

final class RunwayVisibilityParser: RemarkParser {
  var urgency = Remark.Urgency.routine

  private let visibilityParser = FractionParser()
  private let runwayRef = Reference<Substring>()

  private lazy var rx = Regex {
    Anchor.wordBoundary
    "VIS "
    visibilityParser.rx
    " RWY"
    Capture(as: runwayRef) { Repeat(.word, 2...3) }
    Anchor.wordBoundary
  }

  func parse(remarks: inout String, date _: DateComponents) throws -> Remark? {
    guard let result = try rx.firstMatch(in: remarks) else { return nil }
    let distance = visibilityParser.parse(result)
    let runway = result[runwayRef]

    remarks.removeSubrange(result.range)
    return .runwayVisibility(runway: String(runway), distance: distance)
  }
}
