import Foundation
import RegexBuilder

final class WeatherParser: WarmableParser, @unchecked Sendable {
  private static let intensityRef = Reference<Weather.Intensity>()
  private static let descriptorRef = Reference<Weather.Descriptor?>()
  private static let phenomenaRef = Reference<Substring>()

  // swiftlint:disable force_try
  private static let weatherRx = LockedRegex(
    Regex {
      Anchor.startOfSubject
      Capture(as: intensityRef) {
        try! Weather.Intensity.rx
      } transform: {
        .init(rawValue: String($0))!
      }
      Capture(as: descriptorRef) {
        Optionally { try! Weather.Descriptor.rx }
      } transform: {
        .init(rawValue: String($0))
      }
      Capture(as: phenomenaRef) {
        OneOrMore { try! Weather.Phenomenon.rx }
      }
      Anchor.endOfSubject
    }
  )
  private static let noRecordedWx = LockedRegex(
    Regex {
      Anchor.startOfSubject
      Repeat("/", 2...)
      Anchor.endOfSubject
    }
  )
  // swiftlint:enable force_try

  func parse(_ parts: inout [String.SubSequence]) throws -> [Weather]? {
    var weather = [Weather]()

    while true {
      if parts.isEmpty { return weather }
      let weatherStr = String(parts[0])

      if weatherStr == "NSW" {
        parts.removeFirst()
        return []
      }
      if weatherStr == "VCSH" {  // not technically correct but sometimes coded
        weather.append(.init(intensity: .vicinity, descriptor: .showering, phenomena: [.rain]))
        parts.removeFirst()
        continue
      }
      if try Self.noRecordedWx.wholeMatch(in: weatherStr) != nil {
        parts.removeFirst()
        return []
      }

      if let match = try Self.weatherRx.wholeMatch(in: weatherStr) {
        parts.removeFirst()

        let intensity = match[Self.intensityRef]
        let descriptor = match[Self.descriptorRef]

        let phenomenaStr = match[Self.phenomenaRef]
        let phenomenaStrs = String(phenomenaStr).partition(by: 2)
        let phenomena = try phenomenaStrs.map { code -> Weather.Phenomenon in
          guard let phenomenon = Weather.Phenomenon(rawValue: code) else {
            throw Error.invalidWeather(weatherStr)
          }
          return phenomenon
        }

        weather.append(
          Weather(intensity: intensity, descriptor: descriptor, phenomena: Set(phenomena))
        )
      } else {
        return weather
      }
    }
  }
}
