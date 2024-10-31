import Foundation
import Quick
import Nimble

@testable import SwiftMETAR

class WindShiftSpec: AsyncSpec {
    override class func spec() {
        let date = Date().this(day: 1, hour: 19, minute: 30)!

        describe("wind shift") {
            it("parses a 'WSHFT 30' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 WSHFT 30"
                let observation = try await METAR.from(string: string)
                expect(observation.remarks.map { $0.remark }).to(contain(.windShift(time: date, frontalPassage: false)))
            }
            
            it("parses a 'WSHFT 30 FROPA' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 WSHFT 30 FROPA"
                let observation = try await METAR.from(string: string)
                expect(observation.remarks.map { $0.remark }).to(contain(.windShift(time: date, frontalPassage: true)))
            }
        }
    }
}
