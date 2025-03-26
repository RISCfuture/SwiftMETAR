import Foundation
import Nimble
import Quick

@testable import SwiftMETAR

class SnowDepthSpec: AsyncSpec {
    override class func spec() {
        describe("snow depth") {
            it("parses a '4/021' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 4/021"
                let observation = try await METAR.from(string: string)

                expect(observation.remarks.map(\.remark)).to(contain(.snowDepth(21)))
            }
        }
    }
}
