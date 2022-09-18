import Foundation
import NumericAnnex
import Quick
import Nimble

@testable import SwiftMETAR

class CorrectionSpec: QuickSpec {
    override func spec() {
        describe("correction") {
            it("parses a 'COR 0205' remark") {
                let string = "METAR KGXF 260158Z COR 28009KT 10SM CLR 37/M06 A2972 RMK AO2A SLP051 T03741062 $ COR 0205"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.correction(time: Date().this(day: 26, hour: 2, minute: 5)!)))
            }
        }
    }
}
