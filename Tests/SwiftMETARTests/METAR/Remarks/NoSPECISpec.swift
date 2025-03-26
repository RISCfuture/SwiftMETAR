import Foundation
import Nimble
import Quick

@testable import SwiftMETAR

class NoSPECISpec: AsyncSpec {
    override class func spec() {
        describe("no SPECI") {
            it("parses a 'NOSPECI' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 NOSPECI"
                let observation = try await METAR.from(string: string)

                expect(observation.remarks.map(\.remark)).to(contain(.noSPECI))
            }
        }
    }
}
