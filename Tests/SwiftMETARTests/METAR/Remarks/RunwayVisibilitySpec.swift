import Foundation
import Nimble
import NumberKit
import Quick

@testable import SwiftMETAR

class RunwayVisibilitySpec: AsyncSpec {
  override class func spec() {
    describe("runway visibility") {
      it("parses a 'VIS 2 1/2 RWY11' remark") {
        let string =
          "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 VIS 2 1/2 RWY11"
        let observation = try await METAR.from(string: string)

        expect(observation.remarks.map(\.remark)).to(
          contain(.runwayVisibility(runway: "11", distance: 5 / 2 as Ratio))
        )
      }

      it("parses a 'VIS 1/2 RWY11' remark") {
        let string =
          "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 VIS 1/2 RWY11"
        let observation = try await METAR.from(string: string)

        expect(observation.remarks.map(\.remark)).to(
          contain(.runwayVisibility(runway: "11", distance: 1 / 2 as Ratio))
        )
      }

      it("parses a 'VIS 1 RWY11' remark") {
        let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 VIS 1 RWY11"
        let observation = try await METAR.from(string: string)

        expect(observation.remarks.map(\.remark)).to(
          contain(.runwayVisibility(runway: "11", distance: 1 as Ratio))
        )
      }
    }
  }
}
