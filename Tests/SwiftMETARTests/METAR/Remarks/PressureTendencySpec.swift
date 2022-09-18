import Foundation
import Quick
import Nimble

@testable import SwiftMETAR

class PressureTendencySpec: QuickSpec {
    override func spec() {
        describe("pressure tendency") {
            it("parses a '52032' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 52032"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.pressureTendency(character: .steadyUp, change: 3.2)))
            }
        }
    }
}
