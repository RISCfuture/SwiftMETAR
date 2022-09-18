import Foundation
import Quick
import Nimble

@testable import SwiftMETAR

class WindDataEstimatedSpec: QuickSpec {
    override func spec() {
        describe("wind data estimated") {
            it("parses a 'WND DATA ESTMD' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 WND DATA ESTMD"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.windDataEstimated))
            }
        }
    }
}
