import Quick
import Nimble
import Foundation

@testable import SwiftMETAR

class PeriodSpec: QuickSpec {
    override func spec() {
        it("parses taf with group that crosses month boundary") {
            let string = """
            TAF KDVT 311746Z 3118/0118 12007KT P6SM -RA SCT030 OVC050 TEMPO 3118/3119 4SM RA BR BKN020 OVC040 FM311900 13008KT P6SM VCSH SCT030 OVC050 FM312200 12009KT P6SM SCT030 BKN060 FM010800 23010KT P6SM -SHRA VCTS SCT040 OVC050CB PROB30 0108/0112 4SM -TSRA BR OVC040CB
            """
            let referenceDate = Date(timeIntervalSince1970: 1711911482) //Sunday, March 31, 2024 6:58:02 PM Zulu
            let forecast = try! TAF.from(string: string, on: referenceDate)
            let firstPeriod = forecast.groups.first!.period
            switch(firstPeriod) {
            case .range(period: let period):
                expect(period.start.day).to(equal(31))
                expect(period.start.month).to(equal(3))
                expect(period.end.day).to(equal(1))
                expect(period.end.month).to(equal(4))
            default:
                fail("Expected first period to be of type .range")
            }
        }
    }
}
