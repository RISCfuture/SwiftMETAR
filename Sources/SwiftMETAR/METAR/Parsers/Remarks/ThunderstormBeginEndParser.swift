import Foundation
import Regex

fileprivate let thunderstormBeginEndRegex = "([BE])\(remarkTimeRegex)"

struct ThunderstormBeginEndParser: RemarkParser {
    var urgency = Remark.Urgency.caution
    
    private static let eventRegex = try! Regex(string: thunderstormBeginEndRegex)
    private static let regex = try! Regex(string: "\\bTS(\(thunderstormBeginEndRegex))+\\b")
    
    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let result = Self.regex.firstMatch(in: remarks) else { return nil }
        
        var events = Array<Remark.ThunderstormEvent>()
        for eventResult in Self.eventRegex.allMatches(in: result.matchedString) {
            guard let type = Remark.EventType(rawValue: eventResult.captures[0]!) else { return nil }
            guard let time = parseDate(from: eventResult, index: 1, base: date) else { return nil }
            events.append(.init(type: type, time: time))
        }
        
        remarks.removeSubrange(result.range)
        return .thunderstormBeginEnd(events: events)
    }
}
