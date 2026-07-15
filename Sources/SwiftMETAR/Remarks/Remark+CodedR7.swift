import Foundation

extension Remark {

  /// The coded form of a ``correction(time:)`` remark, e.g. `"COR 1547"`
  /// (the correction hour and minute, `HHMM`).
  static func coded(correctionTime time: DateComponents) -> String {
    "COR " + String(format: "%02d%02d", time.hour ?? 0, time.minute ?? 0)
  }

  /// The coded form of a ``next(_:)`` remark, e.g. `"NEXT 1518"` (the next
  /// report's day and hour, `DDHH`).
  static func coded(next date: DateComponents) -> String {
    "NEXT " + codedDayHour(date)
  }

  /// The coded form of a ``noAmendmentsAfter(_:)`` remark, e.g.
  /// `"NO AMDS AFT 1518"` (the cutoff day and hour, `DDHH`).
  static func coded(noAmendmentsAfter date: DateComponents) -> String {
    "NO AMDS AFT " + codedDayHour(date)
  }

  private static func codedDayHour(_ date: DateComponents) -> String {
    String(format: "%02d%02d", date.day ?? 0, date.hour ?? 0)
  }
}
