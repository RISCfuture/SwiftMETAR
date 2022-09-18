import Foundation
import Quick
import Nimble

@testable import SwiftMETAR

class SensorStatusSpec: QuickSpec {
    override func spec() {
        describe("sensor status") {
            it("parses a 'RVRNO' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 RVRNO"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.inoperativeSensor(.RVR)))
            }
            
            it("parses a 'VISNO RWY11' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 VISNO RWY11"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.inoperativeSensor(.secondaryVisibility(location: "RWY11"))))
            }
        }
    }
}
