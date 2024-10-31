import Foundation
@preconcurrency import RegexBuilder

final class SensorStatusParser: RemarkParser {
    var urgency = Remark.Urgency.caution

    private let sensorRef = Reference<Sensor?>()
    private let secondarySensorRef = Reference<SecondarySensor?>()
    private let locationRef = Reference<Substring?>()

    private lazy var rx = Regex {
        Anchor.wordBoundary
        ChoiceOf {
            Capture(as: sensorRef) { try! Sensor.rx } transform: { .init(rawValue: String($0)) }
            Regex {
                Capture(as: secondarySensorRef) { try! SecondarySensor.rx } transform: { .init(rawValue: String($0)) }
                " "
                Capture(as: locationRef) { OneOrMore(.word) } transform: { $0 }
            }
        }
        Anchor.wordBoundary
    }

    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let result = try rx.firstMatch(in: remarks) else { return nil }
        let sensor = result[sensorRef],
            secondarySensor = result[secondarySensorRef],
            location = result[locationRef]

        if let sensor {
            let type: Remark.SensorType = switch sensor {
                case .RVR: .RVR
                case .presentWeather: .presentWeather
                case .rain: .rain
                case .freezingRain: .freezingRain
                case .lightning: .lightning
            }

            remarks.removeSubrange(result.range)
            return .inoperativeSensor(type)
        } else if let secondarySensor {
            guard let location else { return nil }
            let type: Remark.SensorType = switch secondarySensor {
                case .visibility: .secondaryVisibility(location: String(location))
                case .ceiling: .secondaryCeiling(location: String(location))
            }

            remarks.removeSubrange(result.range)
            return .inoperativeSensor(type)
        } else {
            return nil
        }
    }

    private enum Sensor: String, RegexCases {
        case RVR = "RVRNO"
        case presentWeather = "PWINO"
        case rain = "PNO"
        case freezingRain = "FZRANO"
        case lightning = "TSNO"
    }

    private enum SecondarySensor: String, RegexCases {
        case visibility = "VISNO"
        case ceiling = "CHINO"
    }
}
