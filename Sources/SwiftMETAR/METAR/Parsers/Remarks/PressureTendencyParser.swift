import Foundation
import Regex

fileprivate let nocapPressureCharacterRegex = Remark.PressureCharacter.allCases.map { $0.rawValue }.joined(separator: "|")

struct PressureTendencyParser: RemarkParser {
    var urgency = Remark.Urgency.routine
    
    private static let regex = try! Regex(string: "\\b5(\(nocapPressureCharacterRegex))(\\d{3})\\b")
    
    func parse(remarks: inout String, date: DateComponents) -> Remark? {
        guard let result = Self.regex.firstMatch(in: remarks) else { return nil }
        
        guard let character = Remark.PressureCharacter(rawValue: result.captures[0]!) else { return nil }
        guard let amount = UInt(result.captures[1]!) else { return nil }
        
        remarks.removeSubrange(result.range)
        return .pressureTendency(character: character, change: Float(amount)/10.0)
    }
}
