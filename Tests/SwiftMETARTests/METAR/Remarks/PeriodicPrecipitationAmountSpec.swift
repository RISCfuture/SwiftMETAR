import Foundation
import Quick
import Nimble

@testable import SwiftMETAR

class PeriodicPrecipitationAmountSpec: QuickSpec {
    override func spec() {
        describe("periodic precipitation amount") {
            it("parses a '60217' remark") {
                let string = "METAR KOKC 011255Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 60217"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.periodicPrecipitationAmount(period: 6, amount: 2.17)))
            }
            
            it("parses a '60000' remark") {
                let string = "METAR KOKC 011155Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 60000"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.periodicPrecipitationAmount(period: 6, amount: 0)))
            }
            
            it("parses a '6////' remark") {
                let string = "METAR KOKC 011255Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 6////"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.periodicPrecipitationAmount(period: 6, amount: nil)))
            }
        }
    }
}
