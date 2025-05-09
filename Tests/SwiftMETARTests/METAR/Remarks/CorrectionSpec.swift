import Foundation
import Nimble
import NumberKit
import Quick

@testable import SwiftMETAR

class CorrectionSpec: AsyncSpec {
    override class func spec() {
        describe("correction") {
            it("parses a 'COR 0205' remark") {
                let string = "METAR KGXF 260158Z COR 28009KT 10SM CLR 37/M06 A2972 RMK AO2A SLP051 T03741062 $ COR 0205"
                let observation = try await METAR.from(string: string)

                expect(observation.remarks.map(\.remark)).to(contain(.correction(time: Date().this(day: 26, hour: 2, minute: 5)!)))
            }
        }
    }
}
