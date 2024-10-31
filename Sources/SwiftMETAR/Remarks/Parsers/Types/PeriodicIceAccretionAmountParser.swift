import Foundation
@preconcurrency import RegexBuilder

final class PeriodicIceAccretionAmountParser: RemarkParser {
    var urgency = Remark.Urgency.routine

    private let periodRef = Reference<UInt8>()
    private let amountRef = Reference<Float>()

    private lazy var rx = Regex {
        Anchor.wordBoundary
        "I"
        Capture(as: periodRef) { CharacterClass.anyOf("136") } transform: { UInt8($0)! }
        Capture(as: amountRef) { Repeat(.digit, count: 3) } transform: { Float($0)!/100.0 }
        Anchor.wordBoundary
    }
    
    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let result = try rx.firstMatch(in: remarks) else { return nil }
        let period = result[periodRef], amount = result[amountRef]
        
        remarks.removeSubrange(result.range)
        return .periodicIceAccretionAmount(period: period, amount: amount)
    }
}
