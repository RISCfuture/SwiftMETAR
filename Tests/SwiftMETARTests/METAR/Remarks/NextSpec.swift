import Foundation
import Nimble
import NumberKit
import Quick

@testable import SwiftMETAR

class NextSpec: AsyncSpec {
    override class func spec() {
        describe("next forecast") {
            it("parses a 'NEXT 2611' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 NEXT 2611"
                let observation = try await METAR.from(string: string)

                expect(observation.remarks.map(\.remark)).to(contain(.next(Date().this(day: 26, hour: 11)!)))
            }
        }
    }
}
