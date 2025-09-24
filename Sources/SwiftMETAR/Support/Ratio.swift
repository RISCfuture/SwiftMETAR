import Foundation
import NumberKit

/// A ratio of two integers.
public typealias Ratio = Rational<Int>

extension Float {
  init(_ ratio: Ratio) {
    self = ratio.floatValue
  }
}

extension Ratio {
  init(_ whole: Int, numerator: Int, denominator: Int) {
    self.init(denominator * whole + numerator, denominator)
  }
}
