import Foundation
import RegexBuilder

protocol RegexCases: RawRepresentable, CaseIterable {
    static var rx: Regex<Substring> { get throws }
}

extension RegexCases where RawValue == String {
    static var rx: Regex<Substring> {
        get throws {
            let cases = allCases.map { NSRegularExpression.escapedPattern(for: $0.rawValue) }.joined(separator: "|")
            return try Regex(cases)
        }
    }
}
