import Foundation
import Regex

func parseConditions(_ parts: inout Array<String.SubSequence>) throws -> Array<Condition> {
    var conditions = Array<Condition>()
    
    while let rawCondition = parts.first.map(String.init) {
        guard let condition = Condition(rawValue: rawCondition) else { break }
        parts.removeFirst()
        conditions.append(condition)
    }

    return conditions
}
