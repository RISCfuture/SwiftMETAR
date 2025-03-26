import Foundation
import Nimble
import Quick

@testable import SwiftMETAR

class VariableCeilingHeightSpec: AsyncSpec {
    override class func spec() {
        describe("variable ceiling height") {
            it("parses a 'CIG 005V010' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 CIG 005V010"
                let observation = try await METAR.from(string: string)

                expect(observation.remarks.map(\.remark)).to(contain(.variableCeilingHeight(low: 500, high: 1000)))
            }
        }
    }
}
