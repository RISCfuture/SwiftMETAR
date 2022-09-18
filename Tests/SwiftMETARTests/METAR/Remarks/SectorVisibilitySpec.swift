import Foundation
import NumericAnnex
import Quick
import Nimble

@testable import SwiftMETAR

class SectorVisibilitySpec: QuickSpec {
    override func spec() {
        describe("sector visibility") {
            it("parses a 'VIS NE 2 1/2' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 VIS NE 2 1/2"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.sectorVisibility(direction: .northeast, distance: 5/2 as Ratio)))
            }
        }
    }
}
