import Foundation
import Quick
import Nimble

@testable import SwiftMETAR

class RunwayCeilingSpec: QuickSpec {
    override func spec() {
        describe("runway ceiling") {
            it("parses a 'CIG 002 RWY11' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 CIG 002 RWY11"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.runwayCeiling(runway: "11", height: 200)))
            }
        }
    }
}
