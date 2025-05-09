import Foundation
import Nimble
import NumberKit
import Quick

@testable import SwiftMETAR

class SectorVisibilitySpec: AsyncSpec {
    override class func spec() {
        describe("sector visibility") {
            it("parses a 'VIS NE 2 1/2' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 VIS NE 2 1/2"
                let observation = try await METAR.from(string: string)

                expect(observation.remarks.map(\.remark)).to(contain(.sectorVisibility(direction: .northeast, distance: 5 / 2 as Ratio)))
            }
        }
    }
}
