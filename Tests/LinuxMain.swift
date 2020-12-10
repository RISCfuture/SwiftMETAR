import XCTest

import SwiftMETARTests

var tests = [
    AltimeterSpec.self,
    ConditionsSpec.self,
    METARSpec.self,
    RVRSpec.self,
    TemperatureSpec.self,
    VisibilitySpec.self,
    WeatherSpec.self,
    WindSpec.self,
    TAFSpec.self
]
XCTMain(tests)
