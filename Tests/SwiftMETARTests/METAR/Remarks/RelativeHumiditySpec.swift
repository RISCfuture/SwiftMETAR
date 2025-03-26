import Foundation
import Nimble
import NumberKit
import Quick

@testable import SwiftMETAR

class RelativeHumiditySpec: AsyncSpec {
    override class func spec() {
        describe("relative humidity") {
            it("parses a 'RH/31' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 RH/31"
                let observation = try await METAR.from(string: string)

                expect(observation.remarks.map(\.remark)).to(contain(.relativeHumidity(31)))
            }
        }
    }
}
