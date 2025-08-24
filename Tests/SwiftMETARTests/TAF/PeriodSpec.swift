import Foundation
import Nimble
import Quick

@testable import SwiftMETAR

class PeriodSpec: AsyncSpec {
    override class func spec() {
        it("parses TAF with group that crosses month boundary") {
            let string = """
            TAF KDVT 311746Z 3118/0118 12007KT P6SM -RA SCT030 OVC050 TEMPO 3118/3119 4SM RA BR BKN020 OVC040 FM311900 13008KT P6SM VCSH SCT030 OVC050 FM312200 12009KT P6SM SCT030 BKN060 FM010800 23010KT P6SM -SHRA VCTS SCT040 OVC050CB PROB30 0108/0112 4SM -TSRA BR OVC040CB
            """
            let referenceDate = Calendar.current.date(from: .init(year: 2024, month: 3, day: 31, hour: 6, minute: 58, second: 2))
            let forecast = try await TAF.from(string: string, on: referenceDate)

            guard case let .range(period) = forecast.groups.first!.period else {
                fail("Expected first period to be of type .range")
                return
            }
            expect(period.start.month).to(equal(3))
            expect(period.start.day).to(equal(31))
            expect(period.end.month).to(equal(4))
            expect(period.end.day).to(equal(1))
        }

        it("throws error for malformed BECMG with end date before start date") {
            let string = """
            TAF COR SPJL 241715Z 2418/2518 32018KT 9999 BKN020 TX17/2419Z TN04/2510Z TEMPO 2418/2422 32022G35KT SCT020TCU SCT100 BECMG 2423/2224 23007KT FM250300 VRB02KT 9999 SCT020
            """
            let referenceDate = Calendar.current.date(from: .init(year: 2025, month: 8, day: 24, hour: 18, minute: 0, second: 0))

            await expect {
                try await TAF.from(string: string, on: referenceDate)
            }.to(throwError { error in
                guard let swiftMETARError = error as? SwiftMETAR.Error else {
                    fail("Expected SwiftMETAR.Error but got \(type(of: error))")
                    return
                }
                guard case .invalidPeriod = swiftMETARError else {
                    fail("Expected .invalidPeriod error but got \(swiftMETARError)")
                    return
                }
            })
        }
    }
}
