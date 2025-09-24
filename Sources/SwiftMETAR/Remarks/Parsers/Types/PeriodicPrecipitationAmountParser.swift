import Foundation
@preconcurrency import RegexBuilder

final class PeriodicPrecipitationAmountParser: RemarkParser {
  var urgency = Remark.Urgency.routine

  private let indeterminateRef = Reference<Bool?>()
  private let amountRef = Reference<UInt?>()
  private lazy var rx = Regex {
    Anchor.wordBoundary
    "6"
    ChoiceOf {
      Regex {
        Capture(as: amountRef) {
          Repeat(.digit, count: 4)
        } transform: {
          .init($0)
        }
        Anchor.wordBoundary
      }
      Capture(as: indeterminateRef) {
        "////"
      } transform: { _ in
        true
      }
    }
  }

  func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
    guard let result = try rx.firstMatch(in: remarks) else { return nil }

    let period: UInt? =
      switch date.hour {
        case 0, 6, 12, 18: 6
        case 23, 5, 11, 17: 6
        case 3, 9, 15, 21: 3
        case 2, 8, 14, 20: 3
        default: nil
      }
    guard let period else { return nil }

    if let amount = result[amountRef] {
      remarks.removeSubrange(result.range)
      return .periodicPrecipitationAmount(period: period, amount: Float(amount) / 100.0)
    }
    if result[indeterminateRef] == true {
      remarks.removeSubrange(result.range)
      return .periodicPrecipitationAmount(period: period, amount: nil)
    }
    return nil
  }
}
