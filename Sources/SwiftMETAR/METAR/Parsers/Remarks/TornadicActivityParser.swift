import Foundation
import Regex

fileprivate let nocapTornadicActivityRx = Remark.TornadicActivityType.allCases.map { $0.rawValue }.joined(separator: "|")

struct TornadicActivityParser: RemarkParser {
    var urgency = Remark.Urgency.urgent
    
    private static let regex = try! Regex(string: "\\b(\(nocapTornadicActivityRx)) ([BE])\(remarkTimeRegex) (\\d+) \(remarkDirectionRegex)(?: MOVG? \(remarkDirectionRegex))?\\b")
    
    func parse(remarks: inout String, date: DateComponents) -> Remark? {
        guard let result = Self.regex.firstMatch(in: remarks) else { return nil }
        
        guard let type = Remark.TornadicActivityType(rawValue: result.captures[0]!) else { return nil }
        guard let eventType = Remark.EventType(rawValue: result.captures[1]!) else { return nil }
        guard let time = parseDate(from: result, index: 2, base: date) else { return nil }
        guard let distance = UInt(result.captures[4]!) else { return nil }
        guard let direction = directionFromString[result.captures[5]!] else { return nil }
        
        var movingDirection: Remark.Direction? = nil
        if let movingDirStr = result.captures[6] {
            guard let movingDir = directionFromString[movingDirStr] else { return nil }
            movingDirection = movingDir
        }
        
        var begin: DateComponents? = nil
        var end: DateComponents? = nil
        switch eventType {
            case .began: begin = time
            case .ended: end = time
        }
        
        remarks.removeSubrange(result.range)
        return .tornadicActivity(type: type,
                                 begin: begin,
                                 end: end,
                                 location: .init(direction: direction, distance: distance),
                                 movingDirection: movingDirection)
    }
}
