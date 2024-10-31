import Foundation
@preconcurrency import RegexBuilder

class RemarkDirectionParser {
    private static let directionFromString: Dictionary<String, Remark.Direction> = [
        "N": .north,
        "NE": .northeast,
        "E": .east,
        "SE": .southeast,
        "S": .south,
        "SW": .southwest,
        "W": .west,
        "NW": .northwest,
        "ALQS": .all,
        "ALQDS": .all
    ]
    private let directionRef = Reference<Remark.Direction?>()
    lazy var rx = Regex {
        Capture(as: directionRef) {
            try! Regex<Substring>("(?:\(RemarkDirectionParser.directionFromString.keys.joined(separator: "|")))")
        } transform: { RemarkDirectionParser.directionFromString[String($0)] }
    }

    func parse<T>(_ match: Regex<T>.Match) -> Remark.Direction? {
        return match[directionRef]
    }

    func parse(_ string: String) -> Remark.Direction? {
        return Self.directionFromString[string]
    }

    static func isDirectionString(_ string: String) -> Bool {
        Self.directionFromString.keys.contains(string)
    }
}

class RemarkDirectionsParser {
    private static let order: Array<Remark.Direction> = [.north, .northeast, .east, .southeast, .south, .southwest, .west, .northwest]

    private let directionParser = RemarkDirectionParser()
    private let directionsRef = Reference<Substring?>()
    lazy var rx = Regex {
        Capture(as: directionsRef) {
            directionParser.rx
            ZeroOrMore {
                ChoiceOf {
                    Regex {
                        "-"
                        directionParser.rx
                    }
                    Regex {
                        " THRU "
                        directionParser.rx
                    }
                    Regex {
                        " AND "
                        directionParser.rx
                    }
                    Regex {
                        " "
                        directionParser.rx
                    }
                }
            }
        } transform: { $0 }
    }

    func parse(_ string: String) -> Set<Remark.Direction>? {
        var directions = Set<Remark.Direction>()
        var parts = string.components(separatedBy: .whitespaces)

        repeat {
            guard !parts.isEmpty else { break }
            guard let (direction1, direction2) = parseDirectionString(parts.first!) else { break }
            parts.removeFirst()
            if let direction2 {
                directions.formUnion(directionRange(from: direction1, to: direction2))
                break // one continuous range per remark
            } else {
                directions.insert(direction1)
                guard let joiner = parts.first else { break }
                if joiner == "THRU" {
                    parts.removeFirst()
                    guard let direction2Str = parts.first else { break }
                    guard let direction2 = directionParser.parse(direction2Str) else { break }
                    directions.formUnion(directionRange(from: direction1, to: direction2))
                    break // one continuous range per remark
                } else if joiner == "AND" {
                    parts.removeFirst()
                    continue // add it on the next loop
                } else if RemarkDirectionParser.isDirectionString(joiner) {
                    continue // add it on the next loop
                } else {
                    break
                }
            }
        } while true

        return directions
    }

    func parse<T>(_ match: Regex<T>.Match) -> Set<Remark.Direction>? {
        guard let string = match[directionsRef] else { return nil }
        return parse(String(string))
    }

    private func parseDirectionString(_ string: String) -> (Remark.Direction, Remark.Direction?)? {
        let parts = string.split(separator: "-")
        let directions = parts.map { directionParser.parse(String($0)) }
        if directions.contains(where: { $0 == nil }) { return nil }

        if parts.count == 1 {
            return (directions[0]!, nil)
        } else if directions.count == 2 {
            return (directions[0]!, directions[1])
        } else {
            return nil
        }
    }

    private func directionRange(from direction1: Remark.Direction, to direction2: Remark.Direction) -> Set<Remark.Direction> {
        var directions = Set<Remark.Direction>([direction1, direction2])
        var rangeIndex = Self.order.firstIndex(of: direction1)!
        let lastIndex = Self.order.firstIndex(of: direction2)!
        while rangeIndex != lastIndex {
            rangeIndex += 1
            if rangeIndex == Self.order.count { rangeIndex = 0 }
            directions.insert(Self.order[rangeIndex])
        }
        return directions
    }
}
