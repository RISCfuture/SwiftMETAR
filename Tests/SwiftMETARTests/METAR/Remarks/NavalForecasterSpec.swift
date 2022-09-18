import Foundation
import Quick
import Nimble

@testable import SwiftMETAR

class NavalForecasterSpec: QuickSpec {
    override func spec() {
        describe("naval forecaster") {
            it("parses a 'FN20066' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 FN20066"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.navalForecaster(center: .norfolk, ID: 20066)))
            }
            
            it("parses a 'FS30067' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 FS30067"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.navalForecaster(center: .sanDiego, ID: 30067)))
            }
        }
    }
}
