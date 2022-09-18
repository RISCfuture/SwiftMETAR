import Foundation
import Quick
import Nimble

@testable import SwiftMETAR

class SeaLevelPressureSpec: QuickSpec {
    override func spec() {
        describe("sea-level pressure") {
            it("parses a 'SLP982' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 SLP982"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.seaLevelPressure(998.2)))
            }
            
            it("parses a 'SLPNO' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 SLPNO"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.seaLevelPressure(nil)))
            }
        }
    }
}
