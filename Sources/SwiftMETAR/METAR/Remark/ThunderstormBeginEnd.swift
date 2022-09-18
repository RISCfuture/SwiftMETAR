import Foundation

extension Remark {
    
    /// An occurrence of a thunderstorm beginning or ending.
    public struct ThunderstormEvent: Codable, Equatable {
        
        /// Whether the thunderstorm began or ended.
        public let type: Remark.EventType
        
        /// The time when the thunderstorm began or ended.
        public let time: DateComponents
    }
}
