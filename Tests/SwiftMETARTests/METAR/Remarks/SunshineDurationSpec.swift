import Foundation
import Nimble
import Quick

@testable import SwiftMETAR

class SunshineDurationSpec: AsyncSpec {
  override class func spec() {
    describe("sunshine duration") {
      it("parses a '98096' remark") {
        let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 98096"
        let observation = try await METAR.from(string: string)

        expect(observation.remarks.map(\.remark)).to(contain(.sunshineDuration(96)))
      }
    }
  }
}
