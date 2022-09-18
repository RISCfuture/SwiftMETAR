import Foundation
import Quick
import Nimble

@testable import SwiftMETAR

class VariableCeilingHeightSpec: QuickSpec {
    override func spec() {
        describe("variable ceiling height") {
            it("parses a 'CIG 005V010' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 CIG 005V010"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.variableCeilingHeight(low: 500, high: 1000)))
            }
        }
    }
}
