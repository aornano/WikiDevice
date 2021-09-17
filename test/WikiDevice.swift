//
//  WikiDevice.swift
//  test
//
//  Created by Alessandro Ornano on 14/09/21.
//

import Foundation
import UIKit

public extension UIDevice {
    var identifier: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
            }
        }
        if modelCode == "x86_64" {
            if let simModelCode = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
                if let simMap = String(validatingUTF8: simModelCode) {
                    return simMap
                }
            }
        }
        return modelCode ?? "?unrecognized?"
    }
}
class WikiDevice {
    static func model(_ completion: @escaping ((String) -> ())){
        let unrecognized = "?unrecognized?"
        guard let wikiUrl=URL(string:"https://www.theiphonewiki.com//w/api.php?action=parse&format=json&page=Models") else { return completion(unrecognized) }
        var identifier: String {
            var systemInfo = utsname()
            uname(&systemInfo)
            let modelCode = withUnsafePointer(to: &systemInfo.machine) {
                $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                    ptr in String.init(validatingUTF8: ptr)
                }
            }
            if modelCode == "x86_64" {
                if let simModelCode = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
                    if let simMap = String(validatingUTF8: simModelCode) {
                        return simMap
                    }
                }
            }
            return modelCode ?? unrecognized
        }
        guard identifier != unrecognized else { return completion(unrecognized)}
        let request = URLRequest(url: wikiUrl)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            do {
                guard let data = data,
                    let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode,
                    error == nil else { return completion(unrecognized) }
                guard let convertedString = String(data: data, encoding: String.Encoding.utf8) else { return completion(unrecognized) }
                var wikiTables = convertedString.components(separatedBy: "wikitable")
                wikiTables.removeFirst()
                var tables = [[String]]()
                wikiTables.enumerated().forEach{ index,table in
                    let rawRows = table.components(separatedBy: #"<tr>\n<td"#)
                    var counter = 0
                    var rows = [String]()
                    while counter < rawRows.count {
                        let rawRow = rawRows[counter]
                        if let subRowsNum = rawRow.components(separatedBy: #"rowspan=\""#).dropFirst().compactMap({ sub in
                            (sub.range(of: #"\">"#)?.lowerBound).flatMap { endRange in
                                String(sub[sub.startIndex ..< endRange])
                            }
                        }).first {
                            if let subRowsTot = Int(subRowsNum) {
                                var otherRows = ""
                                for i in counter..<counter+subRowsTot {
                                    otherRows += rawRows[i]
                                }
                                let row = rawRow + otherRows
                                rows.append(row)
                                counter += subRowsTot-1
                            }
                        } else {
                            rows.append(rawRows[counter])
                        }
                        counter += 1
                    }
                    tables.append(rows)
                }
                for table in tables {
                    if let rowIndex = table.firstIndex(where: {$0.lowercased().contains(identifier.lowercased())}) {
                        let rows = table[rowIndex].components(separatedBy: "<td>")
                        if rows.count>0 {
                            if rows[0].contains("title") { //hyperlink
                                if let (cleanedGen) = rows[0].components(separatedBy: #">"#).dropFirst().compactMap({ sub in
                                    (sub.range(of: "</")?.lowerBound).flatMap { endRange in
                                        String(sub[sub.startIndex ..< endRange]).replacingOccurrences(of: #"\n"#, with: "")
                                    }
                                }).first {
                                    completion(cleanedGen)
                                }
                            } else {
                                let raw = rows[0].replacingOccurrences(of: "<td>", with: "")
                                let cleanedGen = raw.replacingOccurrences(of: #"\n"#, with: "")
                                completion(cleanedGen)
                            }
                            return
                        }
                    }
                }
                completion(unrecognized)
            }
        }.resume()
    }
}
