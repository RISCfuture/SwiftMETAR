import Foundation

extension Remark {
    /// An occurrence of precipitation beginning or ending.
    public struct PrecipitationEvent: Codable, Equatable {
        
        /// Whether the precipitation began or ended.
        public let event: Remark.EventType
        
        /// The type of precipitation.
        public let type: Weather.Phenomenon
        
        /// The characteristics of the precipitation.
        public let descriptor: Weather.Descriptor?
        
        /// The time the precipitation began or ended.
        public let time: DateComponents
    }
}
