import Foundation

extension Remark {

  static func coded(hourlyPrecipitationAmount amount: Float) -> String {
    String(format: "P%04d", Int((amount * 100).rounded()))
  }

  static func coded(dailyPrecipitationAmount amount: Float?) -> String {
    guard let amount else { return "7////" }
    return String(format: "7%04d", Int((amount * 100).rounded()))
  }

  static func coded(periodicPrecipitationAmount _: UInt, amount: Float?) -> String {
    guard let amount else { return "6////" }
    return String(format: "6%04d", Int((amount * 100).rounded()))
  }

  static func coded(precipitationBeginEnd events: [PrecipitationEvent]) -> String {
    var result = ""
    var lastGroup: String?
    for event in events {
      let group = (event.descriptor?.rawValue ?? "") + event.phenomenon.rawValue
      if group != lastGroup {
        result += group
        lastGroup = group
      }
      let time = String(format: "%02d%02d", event.time.hour ?? 0, event.time.minute ?? 0)
      result += event.event.rawValue + time
    }
    return result
  }

  static func coded(waterEquivalentDepth depth: Float) -> String {
    String(format: "933%03d", Int((depth * 10).rounded()))
  }

  static func coded(snowDepth depth: UInt) -> String {
    String(format: "4/%03d", Int(depth))
  }

  static func coded(rapidSnowIncrease depthIncrease: UInt, totalDepth: UInt) -> String {
    "SNINCR \(depthIncrease)/\(totalDepth)"
  }

  static func coded(periodicIceAccretionAmount period: UInt8, amount: Float) -> String {
    String(format: "I%d%03d", Int(period), Int((amount * 100).rounded()))
  }
}
