import Foundation
import NumericAnnex
import Quick
import Nimble

@testable import SwiftMETAR

class RelativeHumiditySpec: QuickSpec {
    override func spec() {
        describe("relative humidity") {
            it("parses a 'RH/31' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 RH/31"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.relativeHumidity(31)))
            }
        }
    }
}
