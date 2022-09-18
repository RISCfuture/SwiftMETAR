import Foundation
import NumericAnnex
import Quick
import Nimble

@testable import SwiftMETAR

class HailstoneSizeSpec: QuickSpec {
    override func spec() {
        describe("hailstone size") {
            it("parses a 'GR 1 3/4' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 GR 1 3/4"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.hailstoneSize(7/4 as Ratio)))
            }
        }
    }
}
