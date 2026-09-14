import Foundation
import RegexBuilder

final class WeatherParser: WarmableParser, @unchecked Sendable {
  private static let intensityRef = Reference<Weather.Intensity>()
  private static let descriptorRef = Reference<Weather.Descriptor?>()
  private static let phenomenaRef = Reference<Substring>()

  private static let weatherRx = LockedRegex(
    Regex {
      Anchor.startOfSubject
      Capture(as: intensityRef) {
        Weather.Intensity.rx
      } transform: {
        .init(rawValue: String($0))!
      }
      Capture(as: descriptorRef) {
        Optionally { Weather.Descriptor.rx }
      } transform: {
        .init(rawValue: String($0))
      }
      Capture(as: phenomenaRef) {
        OneOrMore { Weather.Phenomenon.rx }
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

  func parse(_ parts: inout [String.SubSequence]) throws(Error) -> [Weather]? {
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

        var phenomena = Set<Weather.Phenomenon>()
        for code in String(match[Self.phenomenaRef]).partition(by: 2) {
          guard let phenomenon = Weather.Phenomenon(rawValue: code) else {
            throw Error.invalidWeather(weatherStr)
          }
          phenomena.insert(phenomenon)
        }

        weather.append(
          Weather(intensity: intensity, descriptor: descriptor, phenomena: phenomena)
        )
      } else {
        return weather
      }
    }
  }
}
