import Foundation
import NumericAnnex
import Quick
import Nimble

@testable import SwiftMETAR

class NoAmendmentsAfterSpec: QuickSpec {
    override func spec() {
        describe("no amendments after") {
            it("parses a 'NO AMDS AFT 2601' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 NO AMDS AFT 2601"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.noAmendmentsAfter(Date().this(day: 26, hour: 1)!)))
            }
        }
    }
}
