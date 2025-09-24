import Foundation
@preconcurrency import RegexBuilder

final class ObservedVisibilityParser: RemarkParser {
  var urgency = Remark.Urgency.routine

  private let sourceRef = Reference<Remark.VisibilitySource>()
  private let visibilityParser = FractionParser()

  // swiftlint:disable force_try
  private lazy var rx = Regex {
    Anchor.wordBoundary
    Capture(as: sourceRef) {
      try! Remark.VisibilitySource.rx
    } transform: {
      .init(rawValue: String($0))!
    }
    " VIS "
    visibilityParser.rx
    Anchor.wordBoundary
  }
  // swiftlint:enable force_try

  func parse(remarks: inout String, date _: DateComponents) throws -> Remark? {
    guard let result = try rx.firstMatch(in: remarks) else { return nil }
    let source = result[sourceRef]
    let distance = visibilityParser.parse(result)

    remarks.removeSubrange(result.range)
    return .observedVisibility(source: source, distance: distance)
  }
}
