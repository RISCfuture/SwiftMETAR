import Foundation

extension Remark {

  static func coded(thunderstormBeginEnd events: [ThunderstormEvent]) -> String {
    let sequence =
      events
      .map { "\($0.type.rawValue)\(codedHourMinute($0.time))" }
      .joined()
    return "TS\(sequence)"
  }

  static func coded(
    thunderstormLocation proximity: Proximity?,
    directions: Set<Direction>,
    movingDirection: Direction?
  ) -> String {
    var result = "TS"
    if let proximity { result += " \(proximity.rawValue)" }
    if !directions.isEmpty { result += " \(codedDirections(directions))" }
    if let movingDirection { result += " MOV \(movingDirection.codedString)" }
    return result
  }

  static func coded(
    tornadicActivity type: TornadicActivityType,
    begin: DateComponents?,
    end: DateComponents?,
    location: Location,
    movingDirection: Direction?
  ) -> String {
    let (eventType, time): (EventType, DateComponents?) =
      if let begin { (.began, begin) } else { (.ended, end) }
    var result = "\(type.rawValue) \(eventType.rawValue)"
    if let time { result += codedHourMinute(time) }
    result += " \(location.distance) \(location.direction.codedString)"
    if let movingDirection { result += " MOV \(movingDirection.codedString)" }
    return result
  }

  static func coded(
    lightning frequency: Frequency?,
    types: Set<LightningType>,
    proximity: Proximity?,
    directions: Set<Direction>
  ) -> String {
    var result = ""
    if let frequency { result += "\(frequency.rawValue) " }
    result += "LTG"
    result += codedLightningTypes(types)
    if let proximity { result += " \(proximity.rawValue)" }
    if !directions.isEmpty { result += " \(codedDirections(directions))" }
    return result
  }

  static func coded(hailstoneSize size: Ratio) -> String {
    "GR \(codedFraction(size))"
  }

  static func coded(
    significantClouds type: SignificantCloudType,
    directions: Set<Direction>,
    movingDirection: Direction?,
    distant: Bool,
    apparent: Bool
  ) -> String {
    var result = ""
    if apparent { result += "APRNT " }
    result += "\(type.rawValue) "
    if distant { result += "DSNT " }
    result += codedDirections(directions)
    if let movingDirection { result += " MOV \(movingDirection.codedString)" }
    return result
  }

  static func coded(
    observedPrecipitation type: ObservedPrecipitationType,
    proximity: Proximity?,
    directions: Set<Direction>
  ) -> String {
    var result = type.rawValue
    if let proximity { result += " \(proximity.rawValue)" }
    if !directions.isEmpty { result += " \(codedDirections(directions))" }
    return result
  }

  /// Formats an event time as `HHMM` (or `MM` when the hour is unknown).
  private static func codedHourMinute(_ components: DateComponents) -> String {
    if let hour = components.hour {
      return String(format: "%02d%02d", hour, components.minute ?? 0)
    }
    return String(format: "%02d", components.minute ?? 0)
  }

  /// Concatenates lightning types in canonical order (`CG`, `IC`, `CC`, `CA`).
  private static func codedLightningTypes(_ types: Set<LightningType>) -> String {
    let order: [LightningType] = [.cloudToGround, .withinCloud, .cloudToCloud, .cloudToAir]
    return order.filter(types.contains).map(\.rawValue).joined()
  }
}
