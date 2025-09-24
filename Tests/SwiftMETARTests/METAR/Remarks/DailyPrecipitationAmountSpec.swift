import Foundation
import Nimble
import Quick

@testable import SwiftMETAR

class DailyPrecipitationAmountSpec: AsyncSpec {
  override class func spec() {
    describe("daily precipitation amount") {
      it("parses a '70125' remark") {
        let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 70125"
        let observation = try await METAR.from(string: string)

        expect(observation.remarks.map(\.remark)).to(contain(.dailyPrecipitationAmount(1.25)))
      }

      it("parses a '7////' remark") {
        let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 7////"
        let observation = try await METAR.from(string: string)

        expect(observation.remarks.map(\.remark)).to(contain(.dailyPrecipitationAmount(nil)))
      }
    }
  }
}
