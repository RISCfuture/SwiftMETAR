import Foundation

public extension Remark {
    /// An occurrence of precipitation beginning or ending.
    struct PrecipitationEvent: Codable, Equatable, Sendable {

        /// Whether the precipitation began or ended.
        public let event: Remark.EventType

        /// The type of precipitation.
        public let phenomenon: Weather.Phenomenon

        /// The characteristics of the precipitation.
        public let descriptor: Weather.Descriptor?

        /// The time the precipitation began or ended.
        public let time: DateComponents
    }
}
