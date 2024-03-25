import Foundation
import Regex

public struct DirectionalVisibility: Codable, RawRepresentable {
    
    public let rawValue: String
    
    public let vilibility: Visibility
    public let direction: Direction
    
    public init?(rawValue: String) {
        self.rawValue = rawValue
        var rawValue = rawValue
        
        let match = Direction.rx.firstMatch(in: rawValue)
        match.map(\.range).map { range in
            rawValue = rawValue.replacingCharacters(in: range, with: "")
        }
        
        self.direction = match.map(\.matchedString).flatMap(Direction.init(rawValue:)) ?? .all
        guard let visibility = Visibility(rawValue: rawValue) else { return nil }
        self.vilibility = visibility
    }
}

private extension Direction {
    private static var rawRX = allCases
        .filter { $0 != .all }
        .map(\.rawValue)
        .map(NSRegularExpression.escapedPattern(for:))
        .joined(separator: "|")
    
    static var rx = try! Regex(string: "(\(rawRX))$")
}
