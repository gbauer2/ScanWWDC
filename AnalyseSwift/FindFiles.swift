//
//  FindFiles.swift
//  AnalyseSwiftCode
//
//  Created by George Bauer on 11/11/18.
//  Copyright © 2018 Ray Wenderlich. All rights reserved.
//

import Foundation

var xcodeprojURLs = [URL]()

let baseURL = URL(fileURLWithPath: "~")

// Recursive func to find .xcodeproj files & list them in Global var xcodprojURLs
public func findAllXcodeprojFiles(_ folder: URL) {
    do {
        let contents = try FileManager.default.contentsOfDirectory(atPath: folder.path) // fileNames
        let urls = contents
            .filter({ return !$0.hasPrefix(".") })    // filter out hidden (or not)
            .map { return folder.appendingPathComponent($0) }           // create array with full path

        for url in urls {
            if url.pathExtension == "xcodeproj" {
                xcodeprojURLs.append((url))
            } else if url.hasDirectoryPath {
                findAllXcodeprojFiles(url)
            }
        }
    }
    catch {
        print("⛔️\(error) Error listing contents of \(folder)")
    }
}
