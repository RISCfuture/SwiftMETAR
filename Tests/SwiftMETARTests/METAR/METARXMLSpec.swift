import Foundation
import NumberKit
import Testing

@testable import SwiftMETAR

@Suite
struct METARXMLTests {
  @Test
  func parsesABasicMETAR() async throws {
    let xml = """
      <response><data>
      <METAR>
        <raw_text>METAR KOKC 011955Z AUTO 22015G25KT 3/4SM +TSRA BR OVC010CB 18/16 A2992</raw_text>
        <metar_type>METAR</metar_type>
        <station_id>KOKC</station_id>
        <observation_time>2024-01-01T19:55:00Z</observation_time>
        <quality_control_flags>
          <auto>TRUE</auto>
        </quality_control_flags>
        <wind_dir_degrees>220</wind_dir_degrees>
        <wind_speed_kt>15</wind_speed_kt>
        <wind_gust_kt>25</wind_gust_kt>
        <visibility_statute_mi>0.75</visibility_statute_mi>
        <wx_string>+TSRA BR</wx_string>
        <sky_condition sky_cover="OVC" cloud_base_ft_agl="1000" cloud_type="CB"/>
        <temp_c>18.0</temp_c>
        <dewpoint_c>16.0</dewpoint_c>
        <altim_in_hg>29.92</altim_in_hg>
      </METAR>
      </data></response>
      """

    var metars = [METAR]()
    for await result in METAR.from(xml: xml.data(using: .utf8)!) {
      metars.append(try result.get())
    }

    #expect(metars.count == 1)
    let metar = metars[0]

    #expect(metar.stationID == "KOKC")
    #expect(metar.issuance == .routine)
    #expect(metar.observer == .automated)
    #expect(metar.wind == .direction(220, speed: .knots(15), gust: .knots(25)))
    #expect(metar.visibility == .equal(.statuteMilesDecimal(0.75)))
    #expect(metar.conditions == [.overcast(1000, type: .cumulonimbus)])
    #expect(metar.temperature == 18)
    #expect(metar.dewpoint == 16)
    #expect(metar.altimeter == .inHg(2992))
    #expect(metar.runwayVisibility.isEmpty)
    #expect(metar.remarks.isEmpty)
    #expect(metar.remarksString == nil)
  }

  @Test
  func parsesASPECIReport() async throws {
    let xml = """
      <response><data>
      <METAR>
        <raw_text>SPECI KJFK 021530Z 36010KT 10SM FEW250 25/18 A3001</raw_text>
        <metar_type>SPECI</metar_type>
        <station_id>KJFK</station_id>
        <observation_time>2024-01-02T15:30:00Z</observation_time>
        <wind_dir_degrees>360</wind_dir_degrees>
        <wind_speed_kt>10</wind_speed_kt>
        <visibility_statute_mi>10</visibility_statute_mi>
        <sky_condition sky_cover="FEW" cloud_base_ft_agl="25000"/>
        <temp_c>25.0</temp_c>
        <dewpoint_c>18.0</dewpoint_c>
        <altim_in_hg>30.01</altim_in_hg>
      </METAR>
      </data></response>
      """

    var metars = [METAR]()
    for await result in METAR.from(xml: xml.data(using: .utf8)!) {
      metars.append(try result.get())
    }

    #expect(metars.count == 1)
    let metar = metars[0]

    #expect(metar.issuance == .special)
    #expect(metar.observer == .human)
  }

  @Test
  func parsesCalmWinds() async throws {
    let xml = """
      <response><data>
      <METAR>
        <station_id>KDEN</station_id>
        <observation_time>2024-01-01T12:00:00Z</observation_time>
        <wind_dir_degrees>0</wind_dir_degrees>
        <wind_speed_kt>0</wind_speed_kt>
        <visibility_statute_mi>10</visibility_statute_mi>
        <sky_condition sky_cover="CLR"/>
        <temp_c>5.0</temp_c>
        <dewpoint_c>-2.0</dewpoint_c>
        <altim_in_hg>30.12</altim_in_hg>
      </METAR>
      </data></response>
      """

    var metars = [METAR]()
    for await result in METAR.from(xml: xml.data(using: .utf8)!) {
      metars.append(try result.get())
    }

    #expect(metars.count == 1)
    let metar = metars[0]

    #expect(metar.wind == .calm)
    #expect(metar.conditions == [.clear])
    #expect(metar.temperature == 5)
    #expect(metar.dewpoint == -2)
  }

  @Test
  func parsesCorrectedReport() async throws {
    let xml = """
      <response><data>
      <METAR>
        <station_id>KORD</station_id>
        <observation_time>2024-01-01T12:00:00Z</observation_time>
        <quality_control_flags>
          <corrected>TRUE</corrected>
        </quality_control_flags>
        <wind_dir_degrees>180</wind_dir_degrees>
        <wind_speed_kt>5</wind_speed_kt>
        <visibility_statute_mi>6+</visibility_statute_mi>
        <sky_condition sky_cover="SCT" cloud_base_ft_agl="5000"/>
        <temp_c>20.0</temp_c>
        <dewpoint_c>15.0</dewpoint_c>
        <altim_in_hg>29.88</altim_in_hg>
      </METAR>
      </data></response>
      """

    var metars = [METAR]()
    for await result in METAR.from(xml: xml.data(using: .utf8)!) {
      metars.append(try result.get())
    }

    let metar = metars[0]
    #expect(metar.observer == .corrected)
    #expect(metar.visibility == .greaterThan(.statuteMilesDecimal(6)))
  }

  @Test
  func parsesLowVisibilityAsLessThanM1SlashFourSMThreshold() async throws {
    let xml = """
      <response><data>
      <METAR>
        <station_id>KLNP</station_id>
        <observation_time>2024-01-01T12:00:00Z</observation_time>
        <wind_dir_degrees>350</wind_dir_degrees>
        <wind_speed_kt>7</wind_speed_kt>
        <visibility_statute_mi>0.25</visibility_statute_mi>
        <wx_string>FZFG</wx_string>
        <sky_condition sky_cover="OVC" cloud_base_ft_agl="100"/>
        <temp_c>-5.0</temp_c>
        <dewpoint_c>-5.0</dewpoint_c>
        <altim_in_hg>30.10</altim_in_hg>
      </METAR>
      </data></response>
      """

    var metars = [METAR]()
    for await result in METAR.from(xml: xml.data(using: .utf8)!) {
      metars.append(try result.get())
    }

    // M1/4SM is the minimum reportable visibility; XML loses the "M" prefix
    // so we assume visibility <= 1/4 SM is "less than"
    let metar = metars[0]
    #expect(metar.visibility == .lessThan(.statuteMiles(Ratio(1, 4))))
  }

  @Test
  func parsesVerticalVisibility() async throws {
    let xml = """
      <response><data>
      <METAR>
        <station_id>KSFO</station_id>
        <observation_time>2024-01-01T12:00:00Z</observation_time>
        <wind_dir_degrees>0</wind_dir_degrees>
        <wind_speed_kt>3</wind_speed_kt>
        <visibility_statute_mi>0.25</visibility_statute_mi>
        <vert_vis_ft>200</vert_vis_ft>
        <temp_c>12.0</temp_c>
        <dewpoint_c>12.0</dewpoint_c>
        <altim_in_hg>30.05</altim_in_hg>
      </METAR>
      </data></response>
      """

    var metars = [METAR]()
    for await result in METAR.from(xml: xml.data(using: .utf8)!) {
      metars.append(try result.get())
    }

    let metar = metars[0]
    #expect(metar.conditions == [.indefinite(200)])
  }

  @Test
  func parsesMultipleMETARs() async throws {
    let xml = """
      <response><data>
      <METAR>
        <station_id>KORD</station_id>
        <observation_time>2024-01-01T12:00:00Z</observation_time>
        <wind_dir_degrees>180</wind_dir_degrees>
        <wind_speed_kt>10</wind_speed_kt>
        <visibility_statute_mi>10</visibility_statute_mi>
        <sky_condition sky_cover="SKC"/>
        <temp_c>20.0</temp_c>
        <dewpoint_c>10.0</dewpoint_c>
        <altim_in_hg>30.00</altim_in_hg>
      </METAR>
      <METAR>
        <station_id>KJFK</station_id>
        <observation_time>2024-01-01T12:00:00Z</observation_time>
        <wind_dir_degrees>270</wind_dir_degrees>
        <wind_speed_kt>8</wind_speed_kt>
        <visibility_statute_mi>10</visibility_statute_mi>
        <sky_condition sky_cover="FEW" cloud_base_ft_agl="3000"/>
        <temp_c>22.0</temp_c>
        <dewpoint_c>14.0</dewpoint_c>
        <altim_in_hg>29.95</altim_in_hg>
      </METAR>
      </data></response>
      """

    var metars = [METAR]()
    for await result in METAR.from(xml: xml.data(using: .utf8)!) {
      metars.append(try result.get())
    }

    #expect(metars.count == 2)
    #expect(metars[0].stationID == "KORD")
    #expect(metars[1].stationID == "KJFK")
  }

  @Test
  func throwsOnMissingStationId() async throws {
    let xml = """
      <response><data>
      <METAR>
        <observation_time>2024-01-01T12:00:00Z</observation_time>
        <wind_dir_degrees>180</wind_dir_degrees>
        <wind_speed_kt>10</wind_speed_kt>
      </METAR>
      </data></response>
      """

    var results = [XMLParseResult<METAR>]()
    for await result in METAR.from(xml: xml.data(using: .utf8)!) {
      results.append(result)
    }

    #expect(results.count == 1)
    guard case .failure(let error, _) = results[0] else {
      Issue.record("Expected failure")
      return
    }
    #expect(error as? SwiftMETAR.Error == .badFormat)
  }

  @Test
  func reportsErrorOnInvalidObservationTime() async throws {
    let xml = """
      <response><data>
      <METAR>
        <station_id>KORD</station_id>
        <observation_time>not-a-date</observation_time>
        <wind_dir_degrees>180</wind_dir_degrees>
        <wind_speed_kt>10</wind_speed_kt>
        <visibility_statute_mi>10</visibility_statute_mi>
        <sky_condition sky_cover="SKC"/>
        <temp_c>20.0</temp_c>
        <dewpoint_c>10.0</dewpoint_c>
        <altim_in_hg>30.00</altim_in_hg>
      </METAR>
      </data></response>
      """

    var results = [XMLParseResult<METAR>]()
    for await result in METAR.from(xml: xml.data(using: .utf8)!) {
      results.append(result)
    }

    #expect(results.count == 1)
    guard case .failure(let error, _) = results[0] else {
      Issue.record("Expected failure")
      return
    }
    #expect(error as? SwiftMETAR.Error == .invalidDate("not-a-date"))
  }

  @Test
  func reportsErrorOnInvalidVisibility() async throws {
    let xml = """
      <response><data>
      <METAR>
        <station_id>KORD</station_id>
        <observation_time>2024-01-01T12:00:00Z</observation_time>
        <wind_dir_degrees>180</wind_dir_degrees>
        <wind_speed_kt>10</wind_speed_kt>
        <visibility_statute_mi>abc</visibility_statute_mi>
        <sky_condition sky_cover="SKC"/>
        <temp_c>20.0</temp_c>
        <dewpoint_c>10.0</dewpoint_c>
        <altim_in_hg>30.00</altim_in_hg>
      </METAR>
      </data></response>
      """

    var results = [XMLParseResult<METAR>]()
    for await result in METAR.from(xml: xml.data(using: .utf8)!) {
      results.append(result)
    }

    #expect(results.count == 1)
    guard case .failure(let error, _) = results[0] else {
      Issue.record("Expected failure")
      return
    }
    #expect(error as? SwiftMETAR.Error == .invalidVisibility("abc"))
  }

  @Test
  func parsesWeatherPhenomenaFromWxString() async throws {
    let xml = """
      <response><data>
      <METAR>
        <station_id>KATL</station_id>
        <observation_time>2024-01-01T18:00:00Z</observation_time>
        <wind_dir_degrees>240</wind_dir_degrees>
        <wind_speed_kt>12</wind_speed_kt>
        <visibility_statute_mi>3</visibility_statute_mi>
        <wx_string>-RA BR</wx_string>
        <sky_condition sky_cover="BKN" cloud_base_ft_agl="1500"/>
        <sky_condition sky_cover="OVC" cloud_base_ft_agl="3000"/>
        <temp_c>15.0</temp_c>
        <dewpoint_c>14.0</dewpoint_c>
        <altim_in_hg>29.85</altim_in_hg>
      </METAR>
      </data></response>
      """

    var metars = [METAR]()
    for await result in METAR.from(xml: xml.data(using: .utf8)!) {
      metars.append(try result.get())
    }

    let metar = metars[0]
    #expect(metar.weather != nil)
    #expect(metar.weather?.count == 2)
    #expect(metar.weather?[0].intensity == .light)
    #expect(metar.weather?[0].phenomena == Set([.rain]))
    #expect(metar.weather?[1].phenomena == Set([.mist]))

    #expect(metar.conditions.count == 2)
    #expect(metar.conditions[0] == .broken(1500))
    #expect(metar.conditions[1] == .overcast(3000))
  }

  @Test
  func parsesVariableWindsDir0WithSpeedGreaterThan0() async throws {
    let xml = """
      <response><data>
      <METAR>
        <station_id>KLAX</station_id>
        <observation_time>2024-01-01T12:00:00Z</observation_time>
        <wind_dir_degrees>0</wind_dir_degrees>
        <wind_speed_kt>5</wind_speed_kt>
        <visibility_statute_mi>10</visibility_statute_mi>
        <sky_condition sky_cover="SKC"/>
        <temp_c>20.0</temp_c>
        <dewpoint_c>12.0</dewpoint_c>
        <altim_in_hg>30.10</altim_in_hg>
      </METAR>
      </data></response>
      """

    var metars = [METAR]()
    for await result in METAR.from(xml: xml.data(using: .utf8)!) {
      metars.append(try result.get())
    }

    let metar = metars[0]
    #expect(metar.wind == .variable(speed: .knots(5)))
  }

  @Test
  func roundsTemperaturesCorrectlyHalfTowardZero() async throws {
    let xml = """
      <response><data>
      <METAR>
        <station_id>KBOS</station_id>
        <observation_time>2024-01-01T12:00:00Z</observation_time>
        <wind_dir_degrees>90</wind_dir_degrees>
        <wind_speed_kt>8</wind_speed_kt>
        <visibility_statute_mi>10</visibility_statute_mi>
        <sky_condition sky_cover="FEW" cloud_base_ft_agl="10000"/>
        <temp_c>18.9</temp_c>
        <dewpoint_c>-3.4</dewpoint_c>
        <altim_in_hg>30.00</altim_in_hg>
      </METAR>
      </data></response>
      """

    var metars = [METAR]()
    for await result in METAR.from(xml: xml.data(using: .utf8)!) {
      metars.append(try result.get())
    }

    // Normal rounding for non-.5 values
    let metar = metars[0]
    #expect(metar.temperature == 19)  // 18.9 → 19
    #expect(metar.dewpoint == -3)  // -3.4 → -3
  }

  @Test
  func rounds5ValuesTowardZeroMatchingMETARFormat() async throws {
    let xml = """
      <response><data>
      <METAR>
        <station_id>KTEST</station_id>
        <observation_time>2024-01-01T12:00:00Z</observation_time>
        <wind_dir_degrees>90</wind_dir_degrees>
        <wind_speed_kt>8</wind_speed_kt>
        <visibility_statute_mi>10</visibility_statute_mi>
        <sky_condition sky_cover="CLR"/>
        <temp_c>12.5</temp_c>
        <dewpoint_c>-4.5</dewpoint_c>
        <altim_in_hg>30.00</altim_in_hg>
      </METAR>
      </data></response>
      """

    var metars = [METAR]()
    for await result in METAR.from(xml: xml.data(using: .utf8)!) {
      metars.append(try result.get())
    }

    // METAR rounds .5 toward zero: 12.5 → 12, -4.5 → -4
    let metar = metars[0]
    #expect(metar.temperature == 12)
    #expect(metar.dewpoint == -4)
  }

  @Test
  func parsesTheRawText() async throws {
    let xml = """
      <response><data>
      <METAR>
        <raw_text>METAR KORD 011955Z 22010KT 10SM FEW250 20/10 A3000</raw_text>
        <station_id>KORD</station_id>
        <observation_time>2024-01-01T19:55:00Z</observation_time>
        <wind_dir_degrees>220</wind_dir_degrees>
        <wind_speed_kt>10</wind_speed_kt>
        <visibility_statute_mi>10</visibility_statute_mi>
        <sky_condition sky_cover="FEW" cloud_base_ft_agl="25000"/>
        <temp_c>20.0</temp_c>
        <dewpoint_c>10.0</dewpoint_c>
        <altim_in_hg>30.00</altim_in_hg>
      </METAR>
      </data></response>
      """

    var metars = [METAR]()
    for await result in METAR.from(xml: xml.data(using: .utf8)!) {
      metars.append(try result.get())
    }

    #expect(metars[0].text == "METAR KORD 011955Z 22010KT 10SM FEW250 20/10 A3000")
  }

  @Test
  func parsesOVXWithVerticalVisibilityFromSkyCondition() async throws {
    let xml = """
      <response><data>
      <METAR>
        <station_id>KSFO</station_id>
        <observation_time>2024-01-01T12:00:00Z</observation_time>
        <wind_dir_degrees>0</wind_dir_degrees>
        <wind_speed_kt>0</wind_speed_kt>
        <visibility_statute_mi>0.25</visibility_statute_mi>
        <sky_condition sky_cover="OVX"/>
        <vert_vis_ft>100</vert_vis_ft>
        <temp_c>10.0</temp_c>
        <dewpoint_c>10.0</dewpoint_c>
        <altim_in_hg>30.00</altim_in_hg>
      </METAR>
      </data></response>
      """

    var metars = [METAR]()
    for await result in METAR.from(xml: xml.data(using: .utf8)!) {
      metars.append(try result.get())
    }

    #expect(metars[0].conditions == [.indefinite(100)])
  }
}
