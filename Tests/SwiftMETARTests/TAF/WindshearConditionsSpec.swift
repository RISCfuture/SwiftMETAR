import Foundation
import Quick
import Nimble

@testable import SwiftMETAR

class WindshearConditionsSpec: QuickSpec {
    override func spec() {
        describe("windshear conditions") {
            it("parses windshear conditions") {
                let string = """
                TAF KVOK 251700Z
                    2517/2623 09012KT 6000 -RA BKN005 OVC015 QNH2981INS
                    BECMG 2521/2522 06006KT 4800 -RA OVC005 QNH2976INS
                    BECMG 2604/2605 01006KT 9999 NSW OVC005 WSCONDS QNH2975INS
                    BECMG 2618/2619 34006KT 9999 SCT007 BKN015 QNH2980INS
                    TX14/2617Z TN10/2517Z LAST NO AMDS AFT 2522 NEXT 2609
                """
                let forecast = try! TAF.from(string: string, lenientRemarks: true)
                expect(forecast.groups[0].windshearConditions).to(beFalse())
                expect(forecast.groups[1].windshearConditions).to(beFalse())
                expect(forecast.groups[2].windshearConditions).to(beTrue())
                expect(forecast.groups[3].windshearConditions).to(beFalse())
            }
        }
    }
}
