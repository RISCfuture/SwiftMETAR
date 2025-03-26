import Foundation

/// Orders ``RemarkEntry`` records by their ``RemarkEntry/urgency``.
public struct RemarkComparator: SortComparator {
    public var order = SortOrder.forward

    public init() {}

    public func compare(_ lhs: RemarkEntry, _ rhs: RemarkEntry) -> ComparisonResult {
        if lhs.urgency < rhs.urgency {
            .orderedDescending
        } else if lhs.urgency > rhs.urgency {
            .orderedAscending
        } else {
            .orderedSame
        }
    }
}
