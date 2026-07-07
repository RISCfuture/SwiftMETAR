import Foundation
import NumberKit
import Testing

@testable import SwiftMETAR

@Suite
struct NOSIGTests {
  @Test
  func parsesANOSIGRemark() async throws {
    let string = "LOWK 031520Z AUTO VRB01KT 9999 NCD 05/02 Q1005 NOSIG"
    let observation = try await METAR.from(string: string, lenientRemarks: true)

    #expect(observation.remarks.map(\.remark).contains(.nosig))
  }
}
