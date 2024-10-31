import Foundation
@preconcurrency import RegexBuilder

class TAFTemperatureParser {
    private let typeRef = Reference<TAF.Temperature.TemperatureType?>()
    private let signRef = Reference<Bool>()
    private let temperatureRef = Reference<Int>()
    private let dayRef = Reference<Int>()
    private let hourRef = Reference<Int>()

    private lazy var rx = Regex {
        Anchor.wordBoundary
        "T"
        Capture(as: typeRef) {
            Optionally {
                ChoiceOf {
                    "N"
                    "X"
                }
            }
        } transform: { .init(rawValue: String($0)) }
        Capture(as: signRef) { Optionally("M") } transform: { $0 == "M" }
        Capture(as: temperatureRef) { Repeat(.digit, count: 2) } transform: { Int($0)! }
        "/"
        Capture(as: dayRef) { Repeat(.digit, count: 2) } transform: { Int($0)! }
        Capture(as: hourRef) { Repeat(.digit, count: 2) } transform: { Int($0)! }
        "Z"
        Anchor.wordBoundary
    }

    func parse(_ parts: inout Array<String.SubSequence>, date: DateComponents) throws -> Array<TAF.Temperature>? {
        var temps = Array<TAF.Temperature>()

        while !parts.isEmpty {
            let tempStr = String(parts[0])
            guard let match = try rx.wholeMatch(in: tempStr) else { return nil }
            parts.removeFirst()

            let value = match[signRef] ? -match[temperatureRef] : match[temperatureRef],
                day = match[dayRef],
                hour = match[hourRef],
                type = match[typeRef]
            guard let time = date.merged(with: .init(day: Int(day), hour: Int(hour))) else {
                throw Error.invalidForecastTemperature(tempStr)
            }

            temps.append(.init(type: type, value: value, time: time))
        }

        return temps
    }
}
