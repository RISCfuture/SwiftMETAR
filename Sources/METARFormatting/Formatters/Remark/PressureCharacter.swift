import Foundation
import SwiftMETAR

public extension Remark.PressureCharacter {

    /// Formatter for `Remark.PressureCharacter`
    struct FormatStyle: Foundation.FormatStyle, Sendable {
        public func format(_ value: Remark.PressureCharacter) -> String {
            switch value {
                case .inflectedDown: String(localized: "pressure was increasing, now decreasing", comment: "pressure character")
                case .deceleratingUp: String(localized: "pressure is increasing more slowly", comment: "pressure character")
                case .steadyUp: String(localized: "pressure is increasing", comment: "pressure character")
                case .acceleratingUp: String(localized: "pressure is increasing more rapidly", comment: "pressure character")
                case .zero: String(localized: "pressure unchanged", comment: "pressure character")
                case .inflectedUp: String(localized: "pressure was decreasing, now increasing", comment: "pressure character")
                case .deceleratingDown: String(localized: "pressure is decreasing more slowly", comment: "pressure character")
                case .steadyDown: String(localized: "pressure is decreasing", comment: "pressure character")
                case .acceleratingDown: String(localized: "pressure is decreasing more rapidly", comment: "pressure character")
            }
        }
    }
}

// swiftlint:disable missing_docs
public extension FormatStyle where Self == Remark.PressureCharacter.FormatStyle {
    static var pressureCharacter: Self { .init() }
}
// swiftlint:enable missing_docs
