import Foundation
@preconcurrency import RegexBuilder

final class VariableSkyConditionParser: RemarkParser {
  var urgency = Remark.Urgency.routine

  private let coverage1Ref = Reference<Remark.Coverage>()
  private let coverage2Ref = Reference<Remark.Coverage>()
  private let heightRef = Reference<UInt?>()

  // swiftlint:disable force_try
  private lazy var rx = Regex {
    Anchor.wordBoundary
    Capture(as: coverage1Ref) {
      try! Remark.Coverage.rx
    } transform: {
      .init(rawValue: String($0))!
    }
    Optionally {
      Capture(as: heightRef) {
        Repeat(.digit, count: 3)
      } transform: {
        .init($0)
      }
    }
    " V "
    Capture(as: coverage2Ref) {
      try! Remark.Coverage.rx
    } transform: {
      .init(rawValue: String($0))!
    }
    Anchor.wordBoundary
  }
  // swiftlint:enable force_try

  func parse(remarks: inout String, date _: DateComponents) throws -> Remark? {
    guard let result = try rx.firstMatch(in: remarks) else { return nil }
    let coverage1 = result[coverage1Ref]
    let coverage2 = result[coverage2Ref]
    let height = result[heightRef]

    remarks.removeSubrange(result.range)
    return .variableSkyCondition(
      low: coverage1,
      high: coverage2,
      height: height != nil ? height! * 100 : nil
    )
  }
}
