import Foundation
import Quick
import Nimble
import NumericAnnex

@testable import SwiftMETAR

class VariablePrevailingVisibilitySpec: QuickSpec {
    override func spec() {
        describe("variable prevailing visibility") {
            it("parses a 'VIS 1/2V1 1/2' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 VIS 1/2V1 1/2"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.variablePrevailingVisibility(low: 1/2 as Ratio, high: 3/2 as Ratio)))
            }
        }
    }
}
