import Foundation
import Quick
import Nimble

@testable import SwiftMETAR

class LightningSpec: QuickSpec {
    override func spec() {
        describe("lightning") {
            it("parses a 'OCNL LTGICCG OHD' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 OCNL LTGICCG OHD"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.lightning(frequency: .occasional, types: [.cloudToGround, .withinCloud], proximity: .overhead, directions: [])))
            }
        }
    }
}
