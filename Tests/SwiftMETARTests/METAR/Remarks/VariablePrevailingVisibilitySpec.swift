import Foundation
import Nimble
import NumberKit
import Quick

@testable import SwiftMETAR

class VariablePrevailingVisibilitySpec: AsyncSpec {
    override class func spec() {
        describe("variable prevailing visibility") {
            it("parses a 'VIS 1/2V1 1/2' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 VIS 1/2V1 1/2"
                let observation = try await METAR.from(string: string)

                expect(observation.remarks.map(\.remark)).to(contain(.variablePrevailingVisibility(low: 1 / 2 as Ratio, high: 3 / 2 as Ratio)))
            }

            it("parses a 'VIS 1/2V5' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 VIS 1/2V5"
                let observation = try await METAR.from(string: string)

                expect(observation.remarks.map(\.remark)).to(contain(.variablePrevailingVisibility(low: 1 / 2 as Ratio, high: 5 as Ratio)))
            }

            it("parses a 'VIS 2V4' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 VIS 2V4"
                let observation = try await METAR.from(string: string)

                expect(observation.remarks.map(\.remark)).to(contain(.variablePrevailingVisibility(low: 2 as Ratio, high: 4 as Ratio)))
            }
        }
    }
}
