import Foundation
import SwiftMETAR
import Gzip

fileprivate func checkRemarks(_ remarks: Array<RemarkEntry>, string: String) {
    for remark in remarks {
        if case let .unknown(remarkStr) = remark.remark {
            print(string)
            print("-- Unknown remark: \(remarkStr)")
        }
    }
}

let METAR_URL = URL(string: "https://aviationweather.gov/data/cache/metars.cache.csv.gz")!
let METARData = try Data(contentsOf: METAR_URL)
let METARs = String(data: try METARData.gunzipped(), encoding: .ascii)!
METARs.enumerateLines { line, stop in
    guard let range  = line.rangeOfCharacter(from: CharacterSet(charactersIn: ",")) else { return }
    let string = String(line[line.startIndex..<range.lowerBound])
//    guard string != "raw_text" else { return }
    guard string.starts(with: "K") else { return }
    
    do {
        let metar = try METAR.from(string: string)
        checkRemarks(metar.remarks, string: string)
    } catch let error as LocalizedError {
        print(string)
        if let reason = error.failureReason {
            print(" -- \(error.localizedDescription): \(reason)")
        } else {
            print(" -- \(error.localizedDescription)")
        }
    } catch {
        print(string)
        print(" -- \(error.localizedDescription)")
    }
}

let TAF_URL = URL(string: "https://aviationweather.gov/data/cache/tafs.cache.csv.gz")!
let TAFsData = try Data(contentsOf: TAF_URL)
let TAFs = String(data: try TAFsData.gunzipped(), encoding: .ascii)!
TAFs.enumerateLines { line, stop in
    guard let range  = line.rangeOfCharacter(from: CharacterSet(charactersIn: ",")) else { return }
    let string = String(line[line.startIndex..<range.lowerBound])
//    guard string != "raw_text" else { return }
    guard string.starts(with: "TAF K") else { return }
    
    do {
        let taf = try TAF.from(string: string)
        for group in taf.groups {
            checkRemarks(group.remarks, string: string)
        }
        checkRemarks(taf.remarks, string: string)
    } catch let error {
        print(string)
        print(" -- \(error.localizedDescription)")
//        fatalError(error.localizedDescription)
    }
}
