import Foundation
import Quick
import Nimble

@testable import SwiftMETAR

class RapidSnowIncreaseSpec: QuickSpec {
    override func spec() {
        describe("rapid snow increase") {
            it("parses a 'SNINCR 2/10' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 SNINCR 2/10"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.rapidSnowIncrease(2, totalDepth: 10)))
            }
        }
    }
}
