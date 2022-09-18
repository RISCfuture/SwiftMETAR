import Foundation
import Quick
import Nimble

@testable import SwiftMETAR

class IcingConditionsSpec: QuickSpec {
    override func spec() {
        describe("icing conditions") {
            it("parses icing conditions") {
                let string = """
                TAF KBLV 251800Z
                    2515/2615 14005KT 8000 BR FEW030 QNH2960INS
                    BECMG 2614/2615 29008KT 3200 -RA OVC030 620304 QNH2958INS
                    BECMG 2614/2615 30008KT 9999 SKC QNH2950INS
                """
                let forecast = try! TAF.from(string: string)
                expect(forecast.groups[0].icing).to(beNil())
                expect(forecast.groups[1].icing).to(equal(.init(type: .lightRime, base: 3000, depth: 4000)))
                expect(forecast.groups[2].icing).to(beNil())
            }
        }
    }
}
