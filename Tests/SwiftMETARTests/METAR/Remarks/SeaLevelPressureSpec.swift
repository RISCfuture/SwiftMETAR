import Foundation
import Nimble
import Quick

@testable import SwiftMETAR

class SeaLevelPressureSpec: AsyncSpec {
    override class func spec() {
        describe("sea-level pressure") {
            it("parses a 'SLP982' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 SLP982"
                let observation = try await METAR.from(string: string)

                expect(observation.remarks.map(\.remark)).to(contain(.seaLevelPressure(998.2)))
            }

            it("parses a 'SLPNO' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 SLPNO"
                let observation = try await METAR.from(string: string)

                expect(observation.remarks.map(\.remark)).to(contain(.seaLevelPressure(nil)))
            }
        }
    }
}
