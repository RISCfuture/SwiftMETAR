import Foundation

extension Remark {

  static func coded(peakWinds wind: Wind, time: DateComponents) -> String {
    "PK WND \(unitlessWind(wind))/\(hourMinute(time))"
  }

  static func coded(windShift time: DateComponents, frontalPassage: Bool) -> String {
    "WSHFT \(hourMinute(time))\(frontalPassage ? " FROPA" : "")"
  }

  static func coded(windChange wind: Wind, after: DateComponents) -> String {
    "WND \(wind.codedString) AFT \(dayHour(after))"
  }

  static func coded(variableWindDirection heading1: UInt16, _ heading2: UInt16) -> String {
    "WND \(String(format: "%03d", heading1))V\(String(format: "%03d", heading2))"
  }

  static func coded(windDataEstimated _: Void) -> String {
    "WND DATA ESTMD"
  }

  /// A wind's coded form with its trailing speed-unit suffix (e.g. `"KT"`)
  /// removed, as peak-wind groups carry no unit: `"28045KT"` → `"28045"`.
  private static func unitlessWind(_ wind: Wind) -> String {
    var coded = wind.codedString
    while let last = coded.last, last.isLetter { coded.removeLast() }
    return coded
  }

  /// Encodes an hour/minute time as the `HHMM` group used by wind remarks,
  /// falling back to a bare `MM` group when no hour is present.
  private static func hourMinute(_ time: DateComponents) -> String {
    let minute = String(format: "%02d", time.minute ?? 0)
    guard let hour = time.hour else { return minute }
    return "\(String(format: "%02d", hour))\(minute)"
  }

  /// Encodes a day/hour time as the `ddhh` group used by TAF wind-change
  /// remarks, e.g. day 26 hour 14 → `"2614"`.
  private static func dayHour(_ time: DateComponents) -> String {
    String(format: "%02d%02d", time.day ?? 0, time.hour ?? 0)
  }
}
