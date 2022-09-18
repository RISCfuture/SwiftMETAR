import Foundation
import Quick
import Nimble

@testable import SwiftMETAR

class AircraftMishapSpec: QuickSpec {
    override func spec() {
        describe("aircraft mishap") {
            it("parses a 'ACFT MSHP' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 ACFT MSHP"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.aircraftMishap))
            }
        }
    }
}
