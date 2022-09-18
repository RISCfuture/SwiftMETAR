import Foundation
import Quick
import Nimble

@testable import SwiftMETAR

class WaterEquivalentDepthSpec: QuickSpec {
    override func spec() {
        describe("water equivalent depth") {
            it("parses a '933036' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 933036"
                let observation = try! METAR.from(string: string)
                expect(observation.remarks.map { $0.remark }).to(contain(.waterEquivalentDepth(3.6)))
            }
        }
    }
}
