import Foundation
import Nimble
import Quick

@testable import SwiftMETAR

class RunwayCeilingSpec: AsyncSpec {
    override class func spec() {
        describe("runway ceiling") {
            it("parses a 'CIG 002 RWY11' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 CIG 002 RWY11"
                let observation = try await METAR.from(string: string)

                expect(observation.remarks.map(\.remark)).to(contain(.runwayCeiling(runway: "11", height: 200)))
            }
        }
    }
}
