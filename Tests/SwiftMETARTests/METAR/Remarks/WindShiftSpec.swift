import Foundation
import Quick
import Nimble

@testable import SwiftMETAR

class WindShiftSpec: QuickSpec {
    private var date: DateComponents {
        return Date().this(day: 1, hour: 19, minute: 30)!
    }
    
    override func spec() {
        describe("wind shift") {
            it("parses a 'WSHFT 30' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 WSHFT 30"
                let observation = try! METAR.from(string: string)
                expect(observation.remarks.map { $0.remark }).to(contain(.windShift(time: self.date, frontalPassage: false)))
            }
            
            it("parses a 'WSHFT 30 FROPA' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 WSHFT 30 FROPA"
                let observation = try! METAR.from(string: string)
                expect(observation.remarks.map { $0.remark }).to(contain(.windShift(time: self.date, frontalPassage: true)))
            }
        }
    }
}
