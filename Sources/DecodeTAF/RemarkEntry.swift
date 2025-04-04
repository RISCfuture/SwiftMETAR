import BuildableMacro
import Foundation
import METARFormatting
import SwiftMETAR

public extension RemarkEntry {

    /// Formatter for `RemarkEntry`
    @Buildable
    struct FormatStyle: Foundation.FormatStyle, Sendable {

        /// The format to use when printing times.
        public var dateFormat = Date.FormatStyle(date: .omitted, time: .shortened)

        public func format(_ value: RemarkEntry) -> String {
            switch value.urgency {
                case .unknown: String(localized: "(?) \(value.remark, format: .remark(dateFormat: dateFormat))", comment: "unknown remark")
                case .routine: String(localized: "(R) \(value.remark, format: .remark(dateFormat: dateFormat))", comment: "routine remark")
                case .caution: String(localized: "(C) \(value.remark, format: .remark(dateFormat: dateFormat))", comment: "caution remark")
                case .urgent: String(localized: "(U) \(value.remark, format: .remark(dateFormat: dateFormat))", comment: "urgent remark")
            }
        }
    }
}

// swiftlint:disable missing_docs
public extension FormatStyle where Self == RemarkEntry.FormatStyle {
    static var remark: Self { .init() }

    static func remark(dateFormat: Date.FormatStyle? = nil) -> Self {
        dateFormat.map { .init(dateFormat: $0) } ?? .init()
    }
}
// swiftlint:enable missing_docs
