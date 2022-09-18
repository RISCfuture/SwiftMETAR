import Foundation

fileprivate let windshearRxStr = #"^WS(\d{3})\/(\d{3}\d+KTS?|MPS|KPH)$"#
fileprivate let windshearRx = try! NSRegularExpression(pattern: windshearRxStr, options: [])

func parseWindshearConditions(_ parts: inout Array<String.SubSequence>) throws -> Bool {
    guard !parts.isEmpty else { return false }
    
    if parts[0] == "WSCONDS" {
        parts.removeFirst()
        return true
    }
    
    return false
}
