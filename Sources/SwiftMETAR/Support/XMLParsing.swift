import Foundation
import NumberKit

enum XMLParsing {

  // MARK: - Type Methods

  static func parseISO8601(_ string: String) throws -> DateComponents {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    if let date = formatter.date(from: string) {
      return zuluCal.dateComponents(in: zulu, from: date)
    }
    // Fall back to parsing without fractional seconds
    formatter.formatOptions = [.withInternetDateTime]
    guard let date = formatter.date(from: string) else {
      throw Error.invalidDate(string)
    }
    return zuluCal.dateComponents(in: zulu, from: date)
  }

  static func parseRatio(_ string: String) -> Ratio? {
    if let intVal = Int(string) {
      return Ratio(intVal)
    }

    // Handle decimal like "1.75"
    if string.contains(".") {
      let parts = string.split(separator: ".")
      guard parts.count == 2,
        let whole = Int(parts[0]),
        let fracStr = parts.last
      else { return nil }

      let denominator = Int(pow(10.0, Double(fracStr.count)))
      guard let numerator = Int(fracStr) else { return nil }
      return Ratio(whole * denominator + numerator, denominator)
    }

    // Handle fraction like "3/4"
    if string.contains("/") {
      let parts = string.split(separator: "/")
      guard parts.count == 2,
        let num = Int(parts[0]),
        let den = Int(parts[1])
      else { return nil }
      return Ratio(num, den)
    }

    return nil
  }

  static func buildWind(dirDegrees: String?, speedKt: String?, gustKt: String?) throws -> Wind? {
    guard let speedStr = speedKt else { return nil }
    guard let speed = UInt16(speedStr) else {
      throw Error.invalidWinds(speedStr)
    }

    let gust: UInt16? =
      if let gustStr = gustKt { UInt16(gustStr) } else { nil }

    let dir: UInt16? =
      if let dirStr = dirDegrees { UInt16(dirStr) } else { nil }

    if let dir, dir == 0, speed == 0, gust == nil {
      return .calm
    }

    if dir == nil || (dir == 0 && speed > 0) {
      return .variable(speed: .knots(speed))
    }

    if let dir {
      if let gust {
        return .direction(dir, speed: .knots(speed), gust: .knots(gust))
      }
      return .direction(dir, speed: .knots(speed))
    }

    return nil
  }

  static func buildVisibility(_ visStr: String?) throws -> Visibility? {
    guard let visStr, !visStr.isEmpty else { return nil }

    // Handle "10+" or "6+" format (greater than)
    if visStr.hasSuffix("+") {
      let numStr = String(visStr.dropLast())
      if let value = Double(numStr) {
        return .greaterThan(.statuteMilesDecimal(value))
      }
      throw Error.invalidVisibility(visStr)
    }

    // Parse as decimal
    guard let value = Double(visStr) else {
      throw Error.invalidVisibility(visStr)
    }

    // 10SM is the maximum reportable visibility; it means >= 10
    if value >= 10 {
      return .greaterThan(.statuteMilesDecimal(value))
    }

    // M1/4SM (less than 1/4 SM) is the minimum reportable visibility in METAR.
    // The XML loses the "M" prefix, so we assume <= 1/4 SM means "less than".
    if value <= 0.25 {
      return .lessThan(.statuteMilesDecimal(value))
    }

    return .equal(.statuteMilesDecimal(value))
  }

  static func buildWeather(_ wxString: String?) throws -> [Weather]? {
    guard let wxString, !wxString.isEmpty else { return [] }

    let tokens = wxString.split(separator: " ")
    var parts = tokens.map { Substring($0) }
    let parser = WeatherParser()
    return try parser.parse(&parts)
  }

  static func buildConditions(
    skyConditions: [SkyCondition],
    vertVisFt: String?
  ) throws -> [Condition] {
    var conditions = [Condition]()

    for sky in skyConditions {
      let cover = sky.skyCover
      let base: UInt? =
        if let baseStr = sky.cloudBaseFtAgl { UInt(baseStr) } else { nil }
      let cloudType: Condition.CeilingType? =
        if let typeStr = sky.cloudType { Condition.CeilingType(rawValue: typeStr) } else { nil }

      switch cover {
        case "CLR":
          conditions.append(.clear)
        case "SKC":
          conditions.append(.skyClear)
        case "CAVOK":
          conditions.append(.cavok)
        case "NSC":
          conditions.append(.noSignificantClouds)
        case "OVX":
          if let vvStr = vertVisFt, let vv = UInt(vvStr) {
            conditions.append(.indefinite(vv))
          }
        case "FEW":
          guard let base else { throw Error.invalidConditions(cover) }
          conditions.append(.few(base, type: cloudType))
        case "SCT":
          guard let base else { throw Error.invalidConditions(cover) }
          conditions.append(.scattered(base, type: cloudType))
        case "BKN":
          guard let base else { throw Error.invalidConditions(cover) }
          conditions.append(.broken(base, type: cloudType))
        case "OVC":
          guard let base else { throw Error.invalidConditions(cover) }
          conditions.append(.overcast(base, type: cloudType))
        default:
          throw Error.invalidConditions(cover)
      }
    }

    if conditions.isEmpty, let vvStr = vertVisFt, let vv = UInt(vvStr) {
      conditions.append(.indefinite(vv))
    }

    return conditions
  }

  static func buildAltimeter(_ altimStr: String?) throws -> Altimeter? {
    guard let altimStr else { return nil }
    guard let value = Float(altimStr) else {
      throw Error.invalidAltimeter(altimStr)
    }
    return .inHg(UInt16((value * 100).rounded()))
  }

  // MARK: - Subtypes

  struct SkyCondition: Sendable {
    var skyCover: String
    var cloudBaseFtAgl: String?
    var cloudType: String?
  }
}

extension BinaryFloatingPoint {

  /// Rounds to the nearest integer, with ties (exactly .5) rounding toward zero.
  ///
  /// This matches METAR temperature rounding convention where -4.5°C becomes -4
  /// and 12.5°C becomes 12.
  func roundedHalfTowardZero() -> Self {
    let truncated = rounded(.towardZero)
    let remainder = abs(self - truncated)
    if remainder == 0.5 {
      return truncated
    }
    return rounded()
  }
}
