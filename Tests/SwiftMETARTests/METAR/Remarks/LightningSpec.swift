import Foundation
import Nimble
import Quick

@testable import SwiftMETAR

class LightningSpec: AsyncSpec {
  override class func spec() {
    describe("lightning") {
      it("parses a 'OCNL LTGICCG OHD' remark") {
        let string =
          "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 OCNL LTGICCG OHD"
        let observation = try await METAR.from(string: string)

        expect(observation.remarks.map(\.remark)).to(
          contain(
            .lightning(
              frequency: .occasional,
              types: [.cloudToGround, .withinCloud],
              proximity: .overhead,
              directions: []
            )
          )
        )
      }
    }
  }
}
