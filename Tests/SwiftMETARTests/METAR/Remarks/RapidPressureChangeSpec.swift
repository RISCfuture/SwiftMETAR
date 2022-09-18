import Foundation
import Quick
import Nimble

@testable import SwiftMETAR

class RapidPressureChangeSpec: QuickSpec {
    override func spec() {
        describe("rapid pressure change") {
            it("parses a 'PRESRR' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 PRESRR"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.rapidPressureChange(.rising)))
            }
            
            it("parses a 'PRESRR' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 PRESFR"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.rapidPressureChange(.falling)))
            }
        }
    }
}
