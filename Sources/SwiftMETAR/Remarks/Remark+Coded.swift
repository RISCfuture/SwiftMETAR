import Foundation

extension Remark: CodedRepresentable {

  /// The canonical coded form of this remark, e.g. `"SLP132"` or
  /// `"PK WND 28045/1547"`. Because several remark forms collapse distinct
  /// inputs to one canonical output (see the per-case notes), re-encoding is
  /// not guaranteed to be byte-identical to the original text.
  public var codedString: String {
    switch self {
      // Pressure & temperature
      case let .seaLevelPressure(pressure): Self.coded(seaLevelPressure: pressure)
      case let .pressureTendency(character, change):
        Self.coded(pressureTendency: character, change: change)
      case let .rapidPressureChange(change): Self.coded(rapidPressureChange: change)
      case let .temperatureDewpoint(temperature, dewpoint):
        Self.coded(temperatureDewpoint: temperature, dewpoint: dewpoint)
      case let .sixHourTemperatureExtreme(type, temperature):
        Self.coded(sixHourTemperatureExtreme: type, temperature: temperature)
      case let .dailyTemperatureExtremes(low, high):
        Self.coded(dailyTemperatureExtremes: low, high: high)
      case let .relativeHumidity(percent): Self.coded(relativeHumidity: percent)

      // Precipitation & snow
      case let .hourlyPrecipitationAmount(amount):
        Self.coded(hourlyPrecipitationAmount: amount)
      case let .dailyPrecipitationAmount(amount): Self.coded(dailyPrecipitationAmount: amount)
      case let .periodicPrecipitationAmount(period, amount):
        Self.coded(periodicPrecipitationAmount: period, amount: amount)
      case let .precipitationBeginEnd(events): Self.coded(precipitationBeginEnd: events)
      case let .waterEquivalentDepth(depth): Self.coded(waterEquivalentDepth: depth)
      case let .snowDepth(depth): Self.coded(snowDepth: depth)
      case let .rapidSnowIncrease(depthIncrease, totalDepth):
        Self.coded(rapidSnowIncrease: depthIncrease, totalDepth: totalDepth)
      case let .periodicIceAccretionAmount(period, amount):
        Self.coded(periodicIceAccretionAmount: period, amount: amount)

      // Wind
      case let .peakWinds(wind, time): Self.coded(peakWinds: wind, time: time)
      case let .windShift(time, frontalPassage):
        Self.coded(windShift: time, frontalPassage: frontalPassage)
      case let .windChange(wind, after): Self.coded(windChange: wind, after: after)
      case let .variableWindDirection(heading1, heading2):
        Self.coded(variableWindDirection: heading1, heading2)
      case .windDataEstimated: Self.coded(windDataEstimated: ())

      // Visibility, ceiling & sky
      case let .observedVisibility(source, distance):
        Self.coded(observedVisibility: source, distance: distance)
      case let .sectorVisibility(direction, distance):
        Self.coded(sectorVisibility: direction, distance: distance)
      case let .runwayVisibility(runway, distance):
        Self.coded(runwayVisibility: runway, distance: distance)
      case let .variablePrevailingVisibility(low, high):
        Self.coded(variablePrevailingVisibility: low, high: high)
      case let .runwayCeiling(runway, height):
        Self.coded(runwayCeiling: runway, height: height)
      case let .variableCeilingHeight(low, high):
        Self.coded(variableCeilingHeight: low, high: high)
      case let .variableSkyCondition(low, high, height):
        Self.coded(variableSkyCondition: low, high: high, height: height)
      case let .obscuration(type, amount, height):
        Self.coded(obscuration: type, amount: amount, height: height)

      // Convective & hazards
      case let .thunderstormBeginEnd(events): Self.coded(thunderstormBeginEnd: events)
      case let .thunderstormLocation(proximity, directions, movingDirection):
        Self.coded(
          thunderstormLocation: proximity,
          directions: directions,
          movingDirection: movingDirection
        )
      case let .tornadicActivity(type, begin, end, location, movingDirection):
        Self.coded(
          tornadicActivity: type,
          begin: begin,
          end: end,
          location: location,
          movingDirection: movingDirection
        )
      case let .lightning(frequency, types, proximity, directions):
        Self.coded(
          lightning: frequency,
          types: types,
          proximity: proximity,
          directions: directions
        )
      case let .hailstoneSize(size): Self.coded(hailstoneSize: size)
      case let .significantClouds(type, directions, movingDirection, distant, apparent):
        Self.coded(
          significantClouds: type,
          directions: directions,
          movingDirection: movingDirection,
          distant: distant,
          apparent: apparent
        )
      case let .observedPrecipitation(type, proximity, directions):
        Self.coded(observedPrecipitation: type, proximity: proximity, directions: directions)

      // Clouds, station, sensors & meta
      case let .cloudTypes(low, middle, high):
        Self.coded(cloudTypesLow: low, middle: middle, high: high)
      case let .observationType(type, augmented):
        Self.coded(observationType: type, augmented: augmented)
      case let .inoperativeSensor(type): Self.coded(inoperativeSensor: type)
      case let .sunshineDuration(duration): Self.coded(sunshineDuration: duration)
      case let .navalForecaster(center, ID): Self.coded(navalForecasterCenter: center, ID: ID)

      // Flags, times & unknown
      case .nosig: "NOSIG"
      case .aircraftMishap: "ACFT MSHP"
      case .maintenance: "$"
      case .last: "LAST"
      case .noSPECI: "NOSPECI"
      case let .correction(time): Self.coded(correctionTime: time)
      case let .next(date): Self.coded(next: date)
      case let .noAmendmentsAfter(date): Self.coded(noAmendmentsAfter: date)
      case let .unknown(remark): remark
    }
  }

  /**
   Parses a single coded remark, e.g. `"SLP132"` or `"PK WND 28045/1547"`. This
   is the synchronous decoding path used by `Codable`; it takes no reference date
   (dates resolve against the current date) and returns the first remark parsed
   from the string.

   - Parameter coded: The coded remark string.
   - Throws: An ``Error`` if `coded` contains no recognizable remark.
   */
  public init(coded: String) throws {
    var parts = coded.split(whereSeparator: \.isWhitespace)
    let date = zuluCal.dateComponents(in: zulu, from: Date())
    let (entries, _) = try RemarksParser.parse(
      &parts,
      using: RemarksParser.sharedParsers,
      date: date,
      lenientRemarks: true
    )
    guard let remark = entries.first?.remark else { throw Error.badFormat }
    self = remark
  }

  /// The canonical coded ordering of a set of directions, joined by spaces
  /// (e.g. `"N E SE"`). Because a direction ``Direction/all`` or a "through"
  /// range collapses to a set, re-encoding is a canonical, potentially lossy
  /// form.
  static func codedDirections(_ directions: Set<Direction>) -> String {
    if directions.contains(.all) { return Direction.all.codedString }
    let order: [Direction] = [
      .north, .northeast, .east, .southeast, .south, .southwest, .west, .northwest
    ]
    return order.filter(directions.contains).map(\.codedString).joined(separator: " ")
  }
}

extension Remark.Direction {

  /// The coded compass abbreviation for this direction, e.g. `"NE"` (and
  /// `"ALQDS"` for ``all``).
  var codedString: String {
    switch self {
      case .all: "ALQDS"
      case .north: "N"
      case .northeast: "NE"
      case .east: "E"
      case .southeast: "SE"
      case .south: "S"
      case .southwest: "SW"
      case .west: "W"
      case .northwest: "NW"
    }
  }
}
