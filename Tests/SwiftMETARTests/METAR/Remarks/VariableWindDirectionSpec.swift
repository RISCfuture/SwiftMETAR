import Foundation
import Quick
import Nimble

@testable import SwiftMETAR

class VariableWindDirectionSpec: AsyncSpec {
    override class func spec() {
        describe("variable wind direction") {
            it("parses a 'WND 060V120' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 WND 060V120"
                let observation = try await METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.variableWindDirection(60, 120)))
            }
        }
    }
}
