import Foundation
import Nimble
import Quick

@testable import SwiftMETAR

class HourlyPrecipitationAmountSpec: AsyncSpec {
  override class func spec() {
    describe("hourly precipitation amount") {
      it("parses a 'P0009' remark") {
        let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 P0009"
        let observation = try await METAR.from(string: string)

        expect(observation.remarks.map(\.remark)).to(contain(.hourlyPrecipitationAmount(0.09)))
      }

      it("parses a 'P0000' remark") {
        let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 P0000"
        let observation = try await METAR.from(string: string)

        expect(observation.remarks.map(\.remark)).to(contain(.hourlyPrecipitationAmount(0)))
      }
    }
  }
}
