import Foundation
import Nimble
import NumberKit
import Quick

@testable import SwiftMETAR

class NoAmendmentsAfterSpec: AsyncSpec {
    override class func spec() {
        describe("no amendments after") {
            it("parses a 'NO AMDS AFT 2601' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 NO AMDS AFT 2601"
                let observation = try await METAR.from(string: string)

                expect(observation.remarks.map(\.remark)).to(contain(.noAmendmentsAfter(Date().this(day: 26, hour: 1)!)))
            }

            it("parses a 'NO AMD AFT 2601' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 NO AMD AFT 2601"
                let observation = try await METAR.from(string: string)

                expect(observation.remarks.map(\.remark)).to(contain(.noAmendmentsAfter(Date().this(day: 26, hour: 1)!)))
            }
        }
    }
}
