import Foundation
import SwiftMETAR
import BuildableMacro

extension Remark.Direction {
    var next: Self {
        switch self {
            case .all: .all
            case .north: .northeast
            case .northeast: .east
            case .east: .southeast
            case .southeast: .south
            case .south: .southwest
            case .southwest: .west
            case .west: .northwest
            case .northwest: .north
        }
    }
}

public extension Remark.Direction {
    
    /// Formatter for `Remark.Direction`
    @Buildable struct FormatStyle: Foundation.FormatStyle, Sendable {
        
        /// The width to use.
        public var width = Width.full
        
        public func format(_ value: Remark.Direction) -> String {
            switch width {
                case .abbreviated:
                    switch value {
                        case .all: String(localized: "all quadrants", comment: "direction")
                        case .north: String(localized: "N", comment: "direction")
                        case .northeast: String(localized: "NE", comment: "direction")
                        case .east: String(localized: "E", comment: "direction")
                        case .southeast: String(localized: "SE", comment: "direction")
                        case .south: String(localized: "S", comment: "direction")
                        case .southwest: String(localized: "SW", comment: "direction")
                        case .west: String(localized: "W", comment: "direction")
                        case .northwest: String(localized: "NW", comment: "direction")
                    }
                case .full:
                    switch value {
                        case .all: String(localized: "all quadrants", comment: "direction")
                        case .north: String(localized: "north", comment: "direction")
                        case .northeast: String(localized: "northeast", comment: "direction")
                        case .east: String(localized: "east", comment: "direction")
                        case .southeast: String(localized: "southeast", comment: "direction")
                        case .south: String(localized: "south", comment: "direction")
                        case .southwest: String(localized: "southwest", comment: "direction")
                        case .west: String(localized: "west", comment: "direction")
                        case .northwest: String(localized: "northwest", comment: "direction")
                    }
            }
        }
        
        /// Direction widths
        public enum Width: Sendable, Codable {
            
            /// Abbreviated directions (N, NE, E, etc.)
            case abbreviated
            
            /// Longer directions (north, northeast, east, etc.)
            case full
        }
    }
     
    /// Formatter for `Set<Remark.Direction>`. Consolidates consecutive
    /// directions into ranges (e.g., "north–east").
    @Buildable struct RangeFormatStyle: Foundation.FormatStyle, Sendable {
        
        /// The width to use.
        public var width = Remark.Direction.FormatStyle.Width.full
        
        public func format(_ value: Set<Remark.Direction>) -> String {
            let summary = FormatStyle(width: width)
            if value.contains(.all) {
                return summary.format(.all)
            }
            if value.isEmpty {
                return String(localized: "<unknown direction>")
            }
            
            var ranges = Array<(Remark.Direction, Remark.Direction)>()
            for direction in value {
                if ranges.isEmpty {
                    ranges.append((direction, direction))
                    continue
                }
                if ranges.last!.1.next == direction {
                    let range = ranges.popLast()!
                    ranges.append((range.0, direction))
                    if ranges.last!.1 == ranges.first!.0 {
                        let firstRange = ranges.removeFirst()
                        let lastRange = ranges.popLast()!
                        ranges.insert((lastRange.0, firstRange.1), at: 0)
                        break
                    }
                } else {
                    ranges.append((direction, direction))
                }
            }
            
            if ranges.count == 1 && ranges[0].0 == ranges[0].1 {
                return summary.format(.all)
            }
            
            let values = ranges.map { range in
                if range.0 == range.1 {
                    summary.format(range.0)
                } else {
                    String(localized: "\(range.0, format: .direction(width: width)) through \(range.1, format: .direction(width: width))")
                }
            }
            
            return ListFormatStyle.list(type: .and).format(values)
        }
    }
}

public extension FormatStyle where Self == Remark.Direction.FormatStyle {
    static func direction(width: Remark.Direction.FormatStyle.Width) -> Self {
        .init(width: width)
    }
    
    static var direction: Self { .init() }
}

public extension FormatStyle where Self == Remark.Direction.RangeFormatStyle {
    static func range(width: Remark.Direction.FormatStyle.Width) -> Self {
        .init(width: width)
    }
    
    static var range: Self { .init() }
}
