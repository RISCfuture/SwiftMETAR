import Foundation
import NumberKit
import Quick
import Nimble

@testable import SwiftMETAR

class NOSIGSpec: QuickSpec {
    override func spec() {
        describe("NOSIG") {
            it("parses a 'NOSIG' remark") {
                let string = "LOWK 031520Z AUTO VRB01KT 9999 NCD 05/02 Q1005 NOSIG"
                let observation = try! METAR.from(string: string, lenientRemarks: true)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.nosig))
            }
        }
    }
}
