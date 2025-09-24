import Foundation
@preconcurrency import RegexBuilder

class FractionParser {
  let ref = Reference<Substring>()
  lazy var rx = Regex {
    Capture(as: ref) {
      ChoiceOf {
        Regex {
          Repeat(.digit, 1...2)
          " "
          Repeat(.digit, 1...2)
          "/"
          Repeat(.digit, 1...2)
        }
        Regex {
          Repeat(.digit, 1...2)
          "/"
          Repeat(.digit, 1...2)
        }
        Repeat(.digit, 1...2)
      }
    }
  }

  func parse<T>(_ match: Regex<T>.Match) -> Ratio {
    let str = match[ref]
    let words = str.split(separator: " ")

    if words.count == 2 {
      let whole = Int(words[0])!
      let fraction = words[1].split(separator: "/")
      let numerator = Int(fraction[0])!
      let denominator = Int(fraction[1])!
      return Ratio(whole, numerator: numerator, denominator: denominator)
    }
    if words[0].contains("/") {
      let fraction = words[0].split(separator: "/")
      let numerator = Int(fraction[0])!
      let denominator = Int(fraction[1])!
      return Ratio(numerator, denominator)
    }
    let whole = Int(words[0])!
    return Ratio(whole)
  }
}

class AlphaSignedIntegerParser {
  private let isNegativeRef = Reference<Bool?>()
  private let valueRef = Reference<Int8?>()

  private let width: Int
  lazy var rx = Regex {
    Capture(as: isNegativeRef) {
      Optionally("M")
    } transform: {
      $0 == "M"
    }
    Capture(as: valueRef) {
      Repeat(.digit, count: width)
    } transform: {
      .init($0)!
    }
  }

  init(width: Int) {
    self.width = width
  }

  func parse<T>(_ match: Regex<T>.Match) -> Int8? {
    guard let value = match[valueRef],
      let isNegative = match[isNegativeRef]
    else { return nil }
    return isNegative ? -value : value
  }
}

class NumericSignedIntegerParser {
  private let isNegativeRef = Reference<Bool?>()
  private let valueRef = Reference<Int?>()

  private let width: Int
  lazy var rx = Regex {
    Capture(as: isNegativeRef) {
      ChoiceOf {
        "0"
        "1"
      }
    } transform: {
      $0 == "1"
    }
    Capture(as: valueRef) {
      Repeat(.digit, count: width)
    } transform: {
      .init($0)!
    }
  }

  init(width: Int) {
    self.width = width
  }

  func parse<T>(_ match: Regex<T>.Match) -> Int? {
    let value = match[valueRef]
    let isNegative = match[isNegativeRef]
    guard let value, let isNegative else { return nil }
    return isNegative ? -value : value
  }
}
