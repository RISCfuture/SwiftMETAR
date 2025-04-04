import Foundation
import Nimble
import NumberKit
import Quick

@testable import SwiftMETAR

class ObservedVisibilitySpec: AsyncSpec {
    override class func spec() {
        describe("observed visibility") {
            it("parses a 'TWR VIS 1 1/2' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 TWR VIS 1 1/2"
                let observation = try await METAR.from(string: string)

                expect(observation.remarks.map(\.remark)).to(contain(.observedVisibility(source: .tower, distance: 3 / 2 as Ratio)))
            }

            it("parses a 'SFC VIS 1/4' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 SFC VIS 1/4"
                let observation = try await METAR.from(string: string)

                expect(observation.remarks.map(\.remark)).to(contain(.observedVisibility(source: .surface, distance: 1 / 4 as Ratio)))
            }

            it("parses a 'TWR VIS 2' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 TWR VIS 2"
                let observation = try await METAR.from(string: string)

                expect(observation.remarks.map(\.remark)).to(contain(.observedVisibility(source: .tower, distance: 2 as Ratio)))
            }
        }
    }
}
