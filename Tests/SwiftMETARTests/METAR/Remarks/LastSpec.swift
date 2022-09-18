import Foundation
import Quick
import Nimble

@testable import SwiftMETAR

class LastSpec: QuickSpec {
    override func spec() {
        describe("last observation/forecast") {
            it("parses a 'LAST' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 LAST"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.last))
            }
        }
    }
}
