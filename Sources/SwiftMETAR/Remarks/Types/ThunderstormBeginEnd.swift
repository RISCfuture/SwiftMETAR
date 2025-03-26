import Foundation

public extension Remark {

    /// An occurrence of a thunderstorm beginning or ending.
    struct ThunderstormEvent: Codable, Equatable, Sendable {

        /// Whether the thunderstorm began or ended.
        public let type: Remark.EventType

        /// The time when the thunderstorm began or ended.
        public let time: DateComponents
    }
}
