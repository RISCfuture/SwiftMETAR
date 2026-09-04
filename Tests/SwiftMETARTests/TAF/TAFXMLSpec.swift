import Foundation
import NumberKit
import Testing

@testable import SwiftMETAR

@Suite
struct TAFXMLTests {
  @Test
  func `parses a basic TAF`() async throws {
    let xml = """
      <response><data>
      <TAF>
        <raw_text>TAF KORD 021130Z 0212/0312 13012KT P6SM BKN100</raw_text>
        <station_id>KORD</station_id>
        <issue_time>2024-01-02T11:30:00Z</issue_time>
        <forecast>
          <fcst_time_from>2024-01-02T12:00:00Z</fcst_time_from>
          <fcst_time_to>2024-01-03T12:00:00Z</fcst_time_to>
          <wind_dir_degrees>130</wind_dir_degrees>
          <wind_speed_kt>12</wind_speed_kt>
          <visibility_statute_mi>6+</visibility_statute_mi>
          <sky_condition sky_cover="BKN" cloud_base_ft_agl="10000"/>
        </forecast>
      </TAF>
      </data></response>
      """

    var tafs = [TAF]()
    for await result in TAF.from(xml: xml.data(using: .utf8)!) {
      tafs.append(try result.get())
    }

    #expect(tafs.count == 1)
    let taf = tafs[0]

    #expect(taf.airportID == "KORD")
    #expect(taf.issuance == .routine)
    #expect(taf.groups.count == 1)

    let group = taf.groups[0]
    #expect(group.wind == .direction(130, speed: .knots(12)))
    #expect(group.visibility == .greaterThan(.statuteMiles(6)))
    #expect(group.conditions == [.broken(10000)])
  }

  @Test
  func `parses FM groups`() async throws {
    let xml = """
      <response><data>
      <TAF>
        <station_id>KORD</station_id>
        <issue_time>2024-01-02T11:30:00Z</issue_time>
        <forecast>
          <fcst_time_from>2024-01-02T12:00:00Z</fcst_time_from>
          <fcst_time_to>2024-01-03T12:00:00Z</fcst_time_to>
          <wind_dir_degrees>130</wind_dir_degrees>
          <wind_speed_kt>12</wind_speed_kt>
          <visibility_statute_mi>6+</visibility_statute_mi>
          <sky_condition sky_cover="BKN" cloud_base_ft_agl="10000"/>
        </forecast>
        <forecast>
          <change_indicator>FM</change_indicator>
          <fcst_time_from>2024-01-02T16:00:00Z</fcst_time_from>
          <fcst_time_to>2024-01-03T12:00:00Z</fcst_time_to>
          <wind_dir_degrees>180</wind_dir_degrees>
          <wind_speed_kt>15</wind_speed_kt>
          <wind_gust_kt>25</wind_gust_kt>
          <visibility_statute_mi>6+</visibility_statute_mi>
          <sky_condition sky_cover="BKN" cloud_base_ft_agl="5000"/>
        </forecast>
      </TAF>
      </data></response>
      """

    var tafs = [TAF]()
    for await result in TAF.from(xml: xml.data(using: .utf8)!) {
      tafs.append(try result.get())
    }

    let taf = tafs[0]
    #expect(taf.groups.count == 2)

    if case .range = taf.groups[0].period {
    } else {
      Issue.record("Expected .range period for first group")
    }

    if case .from = taf.groups[1].period {
    } else {
      Issue.record("Expected .from period for FM group")
    }

    #expect(taf.groups[1].wind == .direction(180, speed: .knots(15), gust: .knots(25)))
  }

  @Test
  func `parses TEMPO groups`() async throws {
    let xml = """
      <response><data>
      <TAF>
        <station_id>KATL</station_id>
        <issue_time>2024-01-02T11:30:00Z</issue_time>
        <forecast>
          <fcst_time_from>2024-01-02T12:00:00Z</fcst_time_from>
          <fcst_time_to>2024-01-03T12:00:00Z</fcst_time_to>
          <wind_dir_degrees>200</wind_dir_degrees>
          <wind_speed_kt>10</wind_speed_kt>
          <visibility_statute_mi>6+</visibility_statute_mi>
          <sky_condition sky_cover="SCT" cloud_base_ft_agl="4000"/>
        </forecast>
        <forecast>
          <change_indicator>TEMPO</change_indicator>
          <fcst_time_from>2024-01-02T14:00:00Z</fcst_time_from>
          <fcst_time_to>2024-01-02T18:00:00Z</fcst_time_to>
          <visibility_statute_mi>3</visibility_statute_mi>
          <wx_string>TSRA</wx_string>
          <sky_condition sky_cover="BKN" cloud_base_ft_agl="2000" cloud_type="CB"/>
        </forecast>
      </TAF>
      </data></response>
      """

    var tafs = [TAF]()
    for await result in TAF.from(xml: xml.data(using: .utf8)!) {
      tafs.append(try result.get())
    }

    let taf = tafs[0]
    #expect(taf.groups.count == 2)

    if case .temporary = taf.groups[1].period {
    } else {
      Issue.record("Expected .temporary period for TEMPO group")
    }

    #expect(taf.groups[1].visibility == .equal(.statuteMiles(3)))
    #expect(taf.groups[1].conditions == [.broken(2000, type: .cumulonimbus)])
  }

  @Test
  func `parses BECMG groups`() async throws {
    let xml = """
      <response><data>
      <TAF>
        <station_id>KLAX</station_id>
        <issue_time>2024-01-02T11:30:00Z</issue_time>
        <forecast>
          <fcst_time_from>2024-01-02T12:00:00Z</fcst_time_from>
          <fcst_time_to>2024-01-03T12:00:00Z</fcst_time_to>
          <wind_dir_degrees>250</wind_dir_degrees>
          <wind_speed_kt>8</wind_speed_kt>
          <visibility_statute_mi>6+</visibility_statute_mi>
          <sky_condition sky_cover="FEW" cloud_base_ft_agl="10000"/>
        </forecast>
        <forecast>
          <change_indicator>BECMG</change_indicator>
          <fcst_time_from>2024-01-02T20:00:00Z</fcst_time_from>
          <fcst_time_to>2024-01-02T22:00:00Z</fcst_time_to>
          <sky_condition sky_cover="OVC" cloud_base_ft_agl="3000"/>
        </forecast>
      </TAF>
      </data></response>
      """

    var tafs = [TAF]()
    for await result in TAF.from(xml: xml.data(using: .utf8)!) {
      tafs.append(try result.get())
    }

    if case .becoming = tafs[0].groups[1].period {
    } else {
      Issue.record("Expected .becoming period for BECMG group")
    }

    #expect(tafs[0].groups[1].conditions == [.overcast(3000)])
  }

  @Test
  func `parses PROB groups`() async throws {
    let xml = """
      <response><data>
      <TAF>
        <station_id>KJFK</station_id>
        <issue_time>2024-01-02T11:30:00Z</issue_time>
        <forecast>
          <fcst_time_from>2024-01-02T12:00:00Z</fcst_time_from>
          <fcst_time_to>2024-01-03T12:00:00Z</fcst_time_to>
          <wind_dir_degrees>180</wind_dir_degrees>
          <wind_speed_kt>10</wind_speed_kt>
          <visibility_statute_mi>6+</visibility_statute_mi>
          <sky_condition sky_cover="SCT" cloud_base_ft_agl="5000"/>
        </forecast>
        <forecast>
          <change_indicator>PROB</change_indicator>
          <probability>30</probability>
          <fcst_time_from>2024-01-03T00:00:00Z</fcst_time_from>
          <fcst_time_to>2024-01-03T04:00:00Z</fcst_time_to>
          <visibility_statute_mi>3</visibility_statute_mi>
          <wx_string>TSRA</wx_string>
          <sky_condition sky_cover="BKN" cloud_base_ft_agl="3000" cloud_type="CB"/>
        </forecast>
      </TAF>
      </data></response>
      """

    var tafs = [TAF]()
    for await result in TAF.from(xml: xml.data(using: .utf8)!) {
      tafs.append(try result.get())
    }

    let group = tafs[0].groups[1]
    if case let .probability(prob, _) = group.period {
      #expect(prob == 30)
    } else {
      Issue.record("Expected .probability period for PROB group")
    }
  }

  @Test
  func `parses windshear`() async throws {
    let xml = """
      <response><data>
      <TAF>
        <station_id>KDEN</station_id>
        <issue_time>2024-01-02T11:30:00Z</issue_time>
        <forecast>
          <fcst_time_from>2024-01-02T12:00:00Z</fcst_time_from>
          <fcst_time_to>2024-01-03T12:00:00Z</fcst_time_to>
          <wind_dir_degrees>130</wind_dir_degrees>
          <wind_speed_kt>12</wind_speed_kt>
          <visibility_statute_mi>6+</visibility_statute_mi>
          <sky_condition sky_cover="BKN" cloud_base_ft_agl="10000"/>
          <wind_shear_hgt_ft_agl>2000</wind_shear_hgt_ft_agl>
          <wind_shear_dir_degrees>350</wind_shear_dir_degrees>
          <wind_shear_speed_kt>35</wind_shear_speed_kt>
        </forecast>
      </TAF>
      </data></response>
      """

    var tafs = [TAF]()
    for await result in TAF.from(xml: xml.data(using: .utf8)!) {
      tafs.append(try result.get())
    }

    let group = tafs[0].groups[0]
    #expect(group.windshear != nil)
    #expect(group.windshear?.height == 2000)
    #expect(group.windshear?.wind == .direction(350, speed: .knots(35)))
  }

  @Test
  func `parses turbulence conditions`() async throws {
    let xml = """
      <response><data>
      <TAF>
        <station_id>KORD</station_id>
        <issue_time>2024-01-02T11:30:00Z</issue_time>
        <forecast>
          <fcst_time_from>2024-01-02T12:00:00Z</fcst_time_from>
          <fcst_time_to>2024-01-03T12:00:00Z</fcst_time_to>
          <wind_dir_degrees>180</wind_dir_degrees>
          <wind_speed_kt>10</wind_speed_kt>
          <visibility_statute_mi>6+</visibility_statute_mi>
          <sky_condition sky_cover="BKN" cloud_base_ft_agl="5000"/>
          <turbulence_condition turbulence_intensity="2" turbulence_min_alt_ft_agl="5000" \
      turbulence_max_alt_ft_agl="10000"/>
        </forecast>
      </TAF>
      </data></response>
      """

    var tafs = [TAF]()
    for await result in TAF.from(xml: xml.data(using: .utf8)!) {
      tafs.append(try result.get())
    }

    let group = tafs[0].groups[0]
    #expect(group.turbulence.count == 1)
    #expect(group.turbulence[0].intensity == .moderate)
    #expect(group.turbulence[0].location == .clearAir)
    #expect(group.turbulence[0].frequency == .occasional)
    #expect(group.turbulence[0].base == 5000)
    #expect(group.turbulence[0].depth == 5000)
  }

  @Test
  func `parses icing conditions`() async throws {
    let xml = """
      <response><data>
      <TAF>
        <station_id>KORD</station_id>
        <issue_time>2024-01-02T11:30:00Z</issue_time>
        <forecast>
          <fcst_time_from>2024-01-02T12:00:00Z</fcst_time_from>
          <fcst_time_to>2024-01-03T12:00:00Z</fcst_time_to>
          <wind_dir_degrees>180</wind_dir_degrees>
          <wind_speed_kt>10</wind_speed_kt>
          <visibility_statute_mi>6+</visibility_statute_mi>
          <sky_condition sky_cover="OVC" cloud_base_ft_agl="3000"/>
          <icing_condition icing_intensity="5" icing_min_alt_ft_agl="3000" \
      icing_max_alt_ft_agl="8000"/>
        </forecast>
      </TAF>
      </data></response>
      """

    var tafs = [TAF]()
    for await result in TAF.from(xml: xml.data(using: .utf8)!) {
      tafs.append(try result.get())
    }

    let group = tafs[0].groups[0]
    #expect(group.icing.count == 1)
    #expect(group.icing[0].type == .moderateRime)
    #expect(group.icing[0].base == 3000)
    #expect(group.icing[0].depth == 5000)
  }

  @Test
  func `parses multiple TAFs`() async throws {
    let xml = """
      <response><data>
      <TAF>
        <station_id>KORD</station_id>
        <issue_time>2024-01-02T11:30:00Z</issue_time>
        <forecast>
          <fcst_time_from>2024-01-02T12:00:00Z</fcst_time_from>
          <fcst_time_to>2024-01-03T12:00:00Z</fcst_time_to>
          <wind_dir_degrees>180</wind_dir_degrees>
          <wind_speed_kt>10</wind_speed_kt>
          <visibility_statute_mi>6+</visibility_statute_mi>
          <sky_condition sky_cover="BKN" cloud_base_ft_agl="5000"/>
        </forecast>
      </TAF>
      <TAF>
        <station_id>KJFK</station_id>
        <issue_time>2024-01-02T11:30:00Z</issue_time>
        <forecast>
          <fcst_time_from>2024-01-02T12:00:00Z</fcst_time_from>
          <fcst_time_to>2024-01-03T12:00:00Z</fcst_time_to>
          <wind_dir_degrees>270</wind_dir_degrees>
          <wind_speed_kt>8</wind_speed_kt>
          <visibility_statute_mi>10</visibility_statute_mi>
          <sky_condition sky_cover="SCT" cloud_base_ft_agl="8000"/>
        </forecast>
      </TAF>
      </data></response>
      """

    var tafs = [TAF]()
    for await result in TAF.from(xml: xml.data(using: .utf8)!) {
      tafs.append(try result.get())
    }

    #expect(tafs.count == 2)
    #expect(tafs[0].airportID == "KORD")
    #expect(tafs[1].airportID == "KJFK")
  }

  @Test
  func `parses the remarks string`() async throws {
    let xml = """
      <response><data>
      <TAF>
        <station_id>KORD</station_id>
        <issue_time>2024-01-02T11:30:00Z</issue_time>
        <remarks>AMD NOT SKED AFT 0218 NEXT 0300Z</remarks>
        <forecast>
          <fcst_time_from>2024-01-02T12:00:00Z</fcst_time_from>
          <fcst_time_to>2024-01-03T12:00:00Z</fcst_time_to>
          <wind_dir_degrees>180</wind_dir_degrees>
          <wind_speed_kt>10</wind_speed_kt>
          <visibility_statute_mi>6+</visibility_statute_mi>
          <sky_condition sky_cover="SCT" cloud_base_ft_agl="5000"/>
        </forecast>
      </TAF>
      </data></response>
      """

    var tafs = [TAF]()
    for await result in TAF.from(xml: xml.data(using: .utf8)!) {
      tafs.append(try result.get())
    }

    #expect(tafs[0].remarksString == "AMD NOT SKED AFT 0218 NEXT 0300Z")
    #expect(tafs[0].remarks.isEmpty)
  }

  @Test
  func `reports error on entries with no valid forecast groups`() async throws {
    let xml = """
      <response><data>
      <TAF>
        <station_id>KBAD</station_id>
        <issue_time>2024-01-02T11:30:00Z</issue_time>
      </TAF>
      </data></response>
      """

    var results = [XMLParseResult<TAF>]()
    for await result in TAF.from(xml: xml.data(using: .utf8)!) {
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
  func `reports error on invalid period`() async throws {
    let xml = """
      <response><data>
      <TAF>
        <station_id>KORD</station_id>
        <issue_time>2024-01-02T11:30:00Z</issue_time>
        <forecast>
          <fcst_time_from>not-a-date</fcst_time_from>
          <fcst_time_to>2024-01-03T12:00:00Z</fcst_time_to>
          <wind_dir_degrees>180</wind_dir_degrees>
          <wind_speed_kt>10</wind_speed_kt>
          <visibility_statute_mi>6+</visibility_statute_mi>
          <sky_condition sky_cover="SCT" cloud_base_ft_agl="5000"/>
        </forecast>
      </TAF>
      </data></response>
      """

    var results = [XMLParseResult<TAF>]()
    for await result in TAF.from(xml: xml.data(using: .utf8)!) {
      results.append(result)
    }

    #expect(results.count == 1)
    guard case .failure(let error, _) = results[0] else {
      Issue.record("Expected failure")
      return
    }
    #expect(error as? SwiftMETAR.Error == .invalidDate("not-a-date"))
  }
}
