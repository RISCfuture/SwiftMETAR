import Foundation
import Regex

fileprivate let nocapTimeRegex = #"(?:\d{2})?\d{2}"#
fileprivate let nocapPrecipElementRegex = "(?:\(nocapPrecipitationDescriptorRegex))?(?:\(nocapPhenomenonRegex))(?:[BE]\(nocapTimeRegex))+"

struct PrecipitationBeginEndParser: RemarkParser {
    var urgency = Remark.Urgency.routine
    
    private static let beginEndRegex = try! Regex(string: "(\(nocapPrecipElementRegex))+\\b")
    private static let precipitationElementRegex = try! Regex(string: "\(precipitationDescriptorRegex)?\(phenomenonRegex)((?:[BE]\(nocapTimeRegex))+)")
    private static let precipitationEventRegex = try! Regex(string: "([BE])\(remarkTimeRegex)")
    
    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let result = Self.beginEndRegex.firstMatch(in: remarks) else { return nil }
        
        var events = Array<Remark.PrecipitationEvent>()
        for elementResult in Self.precipitationElementRegex.allMatches(in: result.matchedString) {
            var descriptor: Weather.Descriptor? = nil
            if let descriptorStr = elementResult.captures[0] {
                guard let desc = Weather.Descriptor(rawValue: descriptorStr) else { return nil }
                descriptor = desc
            }
            
            guard let type = Weather.Phenomenon(rawValue: elementResult.captures[1]!) else { return nil }
            
            for eventResult in Self.precipitationEventRegex.allMatches(in: elementResult.captures[2]!) {
                guard let event = Remark.EventType(rawValue: eventResult.captures[0]!) else { return nil }
                guard let time = parseDate(from: eventResult, index: 1, base: date) else { return nil }
                
                events.append(.init(event: event,
                                    type: type,
                                    descriptor: descriptor,
                                    time: time))
            }
        }
        guard !events.isEmpty else { return nil }
        
        remarks.removeSubrange(result.range)
        return .precipitationBeginEnd(events: events)
    }
}
