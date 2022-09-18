import Foundation
import Regex

fileprivate let apparent = "APRNT"
fileprivate let distant = "DSNT"
fileprivate let moving = "MOVG?"
fileprivate let rotorCloud = "ROTOR CLD"
fileprivate let nocapCloudTypeRegex = Remark.SignificantCloudType.allCases.map { $0.rawValue }.joined(separator: "|") + "|" + rotorCloud
fileprivate let cloudTypeRegex = "(\(nocapCloudTypeRegex))"

struct SignificantCloudsParser: RemarkParser {
    var urgency = Remark.Urgency.caution
    
    static private let regex = try! Regex(string: "\\b(\(apparent) )?\(cloudTypeRegex) (\(distant) )?\(remarkDirectionsRegex)(?: \(moving) \(remarkDirectionRegex))?\\b")
    
    func parse(remarks: inout String, date: DateComponents) -> Remark? {
        guard let result = Self.regex.firstMatch(in: remarks) else { return nil }
        
        let apparent = result.captures[0] != nil
        
        guard let type = Remark.SignificantCloudType.from(raw: result.captures[1]!) else { return nil }
        
        let distant = result.captures[2] != nil
        
        guard let directions = parseDirections(from: result, index: 3) else { return nil }
        
        var movingDirection: Remark.Direction? = nil
        if let movingDirStr = result.captures[6] {
            guard let movingDir = directionFromString[movingDirStr] else { return nil }
            movingDirection = movingDir
        }
        
        remarks.removeSubrange(result.range)
        return .significantClouds(type: type,
                                  directions: directions,
                                  movingDirection: movingDirection,
                                  distant: distant,
                                  apparent: apparent)
    }
}

extension Remark.SignificantCloudType {
    public static func from(raw: String) -> Self? {
        if raw == rotorCloud { return .rotor }
        else { return .init(rawValue: raw) }
    }
}
