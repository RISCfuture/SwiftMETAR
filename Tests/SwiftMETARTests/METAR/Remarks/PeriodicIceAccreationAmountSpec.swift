import Foundation
import Nimble
import Quick

@testable import SwiftMETAR

class PeriodicIceAccreationAmountSpec: AsyncSpec {
    override class func spec() {
        describe("periodic ice accretion") {
            it("parses a 'I3051' remark") {
                let string = "METAR KOKC 011255Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 I3051"
                let observation = try await METAR.from(string: string)

                expect(observation.remarks.map(\.remark)).to(contain(.periodicIceAccretionAmount(period: 3, amount: 0.51)))
            }

            it("parses a 'I3000' remark") {
                let string = "METAR KOKC 011255Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 I3000"
                let observation = try await METAR.from(string: string)

                expect(observation.remarks.map(\.remark)).to(contain(.periodicIceAccretionAmount(period: 3, amount: 0)))
            }
        }
    }
}
