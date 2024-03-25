import Foundation

/// A direction from an observation station.
public enum Direction: String, CaseIterable, Codable {
    case all = ""
    case north = "N"
    case northeast = "NE"
    case east = "E"
    case southeast = "SE"
    case south = "S"
    case southwest = "SW"
    case west = "W"
    case northwest = "NW"
}
