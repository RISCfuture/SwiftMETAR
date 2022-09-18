import Foundation
import NumericAnnex
import Quick
import Nimble

@testable import SwiftMETAR

class RunwayVisibilitySpec: QuickSpec {
    override func spec() {
        describe("runway visibility") {
            it("parses a 'VIS 2 1/2 RWY11' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 VIS 2 1/2 RWY11"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.runwayVisibility(runway: "11", distance: 5/2 as Ratio)))
            }
        }
    }
}
