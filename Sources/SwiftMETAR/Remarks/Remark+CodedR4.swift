import Foundation
import NumberKit

extension Remark {

  /// Codes a visibility/measurement ``Ratio`` in the fractional form used by
  /// remark visibility groups: a whole number (`"2"`), a bare fraction
  /// (`"3/4"`), or a mixed number (`"1 1/2"`).
  static func codedFraction(_ ratio: Ratio) -> String {
    let whole = ratio.numerator / ratio.denominator
    let remainder = ratio.numerator % ratio.denominator
    if remainder == 0 { return "\(whole)" }
    if whole == 0 { return "\(ratio.numerator)/\(ratio.denominator)" }
    return "\(whole) \(remainder)/\(ratio.denominator)"
  }

  /// Codes a ceiling/cloud height (in feet) as the parser's three-digit
  /// hundreds-of-feet token, e.g. `500` → `"005"`.
  static func codedHundredsOfFeet(_ height: UInt) -> String {
    String(format: "%03d", Int(height / 100))
  }

  static func coded(observedVisibility source: VisibilitySource, distance: Ratio) -> String {
    "\(source.rawValue) VIS \(codedFraction(distance))"
  }

  static func coded(sectorVisibility direction: Direction, distance: Ratio) -> String {
    "VIS \(direction.codedString) \(codedFraction(distance))"
  }

  static func coded(runwayVisibility runway: String, distance: Ratio) -> String {
    "VIS \(codedFraction(distance)) RWY\(runway)"
  }

  static func coded(variablePrevailingVisibility low: Ratio, high: Ratio) -> String {
    "VIS \(codedFraction(low))V\(codedFraction(high))"
  }

  static func coded(runwayCeiling runway: String, height: UInt) -> String {
    "CIG \(codedHundredsOfFeet(height)) RWY\(runway)"
  }

  static func coded(variableCeilingHeight low: UInt, high: UInt) -> String {
    "CIG \(codedHundredsOfFeet(low))V\(codedHundredsOfFeet(high))"
  }

  static func coded(variableSkyCondition low: Coverage, high: Coverage, height: UInt?) -> String {
    let heightToken = height.map { codedHundredsOfFeet($0) } ?? ""
    return "\(low.rawValue)\(heightToken) V \(high.rawValue)"
  }

  static func coded(obscuration type: Weather.Phenomenon, amount: Coverage?, height: UInt) -> String
  {
    "\(type.rawValue) \(amount?.rawValue ?? "")\(codedHundredsOfFeet(height))"
  }
}
