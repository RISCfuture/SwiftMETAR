import Foundation
@preconcurrency import RegexBuilder

class WeatherParser {
    private let intensityRef = Reference<Weather.Intensity>()
    private let descriptorRef = Reference<Weather.Descriptor?>()
    private let phenomenaRef = Reference<Substring>()

    private lazy var weatherRx = Regex {
        Anchor.startOfSubject
        Capture(as: intensityRef) {
            try! Weather.Intensity.rx
        } transform: { .init(rawValue: String($0))! }
        Capture(as: descriptorRef) {
            Optionally { try! Weather.Descriptor.rx }
        } transform: { .init(rawValue: String($0)) }
        Capture(as: phenomenaRef) {
            OneOrMore { try! Weather.Phenomenon.rx }
        }
        Anchor.endOfSubject
    }
    private lazy var noRecordedWx = Regex {
        Anchor.startOfSubject
        Repeat("/", 2...)
        Anchor.endOfSubject
    }

    func parse(_ parts: inout Array<String.SubSequence>) throws -> Array<Weather>? {
        var weather = Array<Weather>()

        while true {
            if parts.isEmpty { return weather }
            let weatherStr = String(parts[0])

            if weatherStr == "NSW" {
                parts.removeFirst()
                return []
            }
            if weatherStr == "VCSH" { // not technically correct but sometimes coded
                weather.append(.init(intensity: .vicinity, descriptor: .showering, phenomena: [.rain]))
                parts.removeFirst()
                continue
            }
            if try noRecordedWx.wholeMatch(in: weatherStr) != nil {
                parts.removeFirst()
                return []
            }

            if let match = try weatherRx.wholeMatch(in: weatherStr) {
                parts.removeFirst()

                let intensity = match[intensityRef],
                    descriptor = match[descriptorRef]

                let phenomenaStr = match[phenomenaRef]
                let phenomenaStrs = String(phenomenaStr).partition(by: 2)
                let phenomena = try phenomenaStrs.map { code -> Weather.Phenomenon in
                    guard let phenomenon = Weather.Phenomenon(rawValue: code) else {
                        throw Error.invalidWeather(weatherStr)
                    }
                    return phenomenon
                }

                weather.append(Weather(intensity: intensity, descriptor: descriptor, phenomena: Set(phenomena)))
            } else {
                return weather
            }
        }
    }
}
