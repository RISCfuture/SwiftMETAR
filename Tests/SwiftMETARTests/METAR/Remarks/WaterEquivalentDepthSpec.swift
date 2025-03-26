import Foundation
import Nimble
import Quick

@testable import SwiftMETAR

class WaterEquivalentDepthSpec: AsyncSpec {
    override class func spec() {
        describe("water equivalent depth") {
            it("parses a '933036' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 933036"
                let observation = try await METAR.from(string: string)
                expect(observation.remarks.map(\.remark)).to(contain(.waterEquivalentDepth(3.6)))
            }
        }
    }
}
