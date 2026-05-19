import Foundation
import NumberKit

/// A ratio of two integers.
public typealias Ratio = Rational<Int>

extension Ratio {
  init(_ whole: Int, numerator: Int, denominator: Int) {
    self.init(denominator * whole + numerator, denominator)
  }
}
