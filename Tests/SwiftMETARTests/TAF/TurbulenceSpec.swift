import Foundation
import Nimble
import Quick

@testable import SwiftMETAR

class TurbulenceSpec: AsyncSpec {
    override class func spec() {
        describe("turbulence") {
            it("parses turbulence") {
                let string = """
                TAF KBLV 251800Z
                    2515/2615 14005KT 8000 BR FEW030 QNH2960INS
                    BECMG 2614/2615 31012G22KT 9999 NSW SCT040 520004 510909 QNH2952INS
                    BECMG 2614/2615 30008KT 9999 SKC QNH2950INS
                """
                let forecast = try await TAF.from(string: string)
                expect(forecast.groups[0].turbulence).to(beEmpty())
                expect(forecast.groups[1].turbulence).to(equal([
                    .init(location: .clearAir, intensity: .moderate, frequency: .occasional, base: 0, depth: 4000),
                    .init(location: nil, intensity: .light, frequency: nil, base: 9000, depth: 9000)
                ]))
                expect(forecast.groups[2].turbulence).to(beEmpty())
            }
        }
    }
}
