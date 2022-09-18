import Foundation
import Quick
import Nimble

@testable import SwiftMETAR

class CloudTypesSpec: QuickSpec {
    override func spec() {
        describe("cloud types") {
            it("parses a '8/6//' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 8/6//"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.cloudTypes(low: .stNebFra, middle: .obscured, high: .obscured)))
            }
            
            it("parses a '8/903' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 8/903"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.cloudTypes(low: .cbCap, middle: .none, high: .ciSpiCb)))
            }
        }
    }
}
