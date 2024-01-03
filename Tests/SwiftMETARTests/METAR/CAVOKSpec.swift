import Foundation
import NumberKit
import Quick
import Nimble

@testable import SwiftMETAR

class CAVOKSpec: QuickSpec {
    override func spec() {
        describe("CAVOK") {
            it("parses a 'CAVOK' note") {
                let string = "LOWK 031520Z AUTO VRB01KT CAVOK 05/02 Q1005 NOSIG"
                let observation = try! METAR.from(string: string, lenientRemarks: true)
                
                expect(observation.conditions).to(contain(.noSignificantClouds))
                expect(observation.visibility).to(equal(.greaterThan(.meters(9999))))
                expect(observation.temperature).to(equal(5))
                expect(observation.dewpoint).to(equal(2))
            }
            
            it("parses a 'CAVOK' with remark") {
                let string = "METAR LFSB 031600Z AUTO 22008KT 150V260 CAVOK 12/05 Q1002 TEMPO 26025G50KT 1200 +SHRA SCT035CB"
                
                let observation = try! METAR.from(string: string, lenientRemarks: true)
                
                expect(observation.conditions).to(contain(.noSignificantClouds))
                expect(observation.visibility).to(equal(.greaterThan(.meters(9999))))
                expect(observation.temperature).to(equal(12))
                expect(observation.dewpoint).to(equal(5))
            }
        }
    }
}
