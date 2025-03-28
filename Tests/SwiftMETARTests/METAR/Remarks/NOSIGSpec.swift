import Foundation
import Nimble
import NumberKit
import Quick

@testable import SwiftMETAR

class NOSIGSpec: AsyncSpec {
    override class func spec() {
        describe("NOSIG") {
            it("parses a 'NOSIG' remark") {
                let string = "LOWK 031520Z AUTO VRB01KT 9999 NCD 05/02 Q1005 NOSIG"
                let observation = try await METAR.from(string: string, lenientRemarks: true)

                expect(observation.remarks.map(\.remark)).to(contain(.nosig))
            }
        }
    }
}
