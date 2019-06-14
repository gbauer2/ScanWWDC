//
//  AnalyseWWDC.swift
//  AnalyseSwiftCode
//
//  Created by George Bauer on 3/17/19.
//  Copyright © 2019 George Bauer. All rights reserved.
//

// Needs cocoa for NSFont
import Cocoa

//MARK:- analyseWWDC 150-lines
func analyseWWDC(_ str: String, selecFileInfo: FileAttributes) -> (NSAttributedString, String) {      //211-361 = 150-lines
    let lines = str.components(separatedBy: "\n")
    var attTx: NSMutableAttributedString = NSMutableAttributedString(string: "")
    let attTxt:NSMutableAttributedString = NSMutableAttributedString(string: "")
    let attributesLargeFont = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 20)]
    let attributesErrorFont = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 16)]
    let attributesSmallFont = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 12)]

    var year    = 0
    var lineNum = 0
    for _ in 0...6 {
        let line = lines[lineNum]
        lineNum += 1
        if line .hasPrefix("WWDC") {
            attTx  = NSMutableAttributedString(string: line + "\n", attributes: attributesLargeFont)
            attTxt.append(attTx)
            let comps = line.components(separatedBy: " ")
            if comps.count >= 2 {
                year = Int(comps[1]) ?? 0
                break
            }
        }
    }
    let file = selecFileInfo.url?.lastPathComponent ?? "?filename?"
    if year < 2000 || year > 2099 {
        let msg = "⛔️ analyseWWDC #\(#line) Bad format in \(file)!\nCould not find title \"WWDC 20xx\""
        print(msg)
        attTx  = NSMutableAttributedString(string: msg + "\n", attributes: attributesErrorFont)
        attTxt.append(attTx)
        return (attTxt, "Error|" + msg)
    }//endif bad year

    var prevLine = ""
    var flag = false
    var str = ""
    var text = "Year \tSess\tOSX\tiOS\tTitle \tKeyword \twant \tfin \tlang \tDescription\n"
    var totalSessions = 0

    // MARK:- 2016, 2017, 2018, 2019,...

    if year >= 2000 {
        var sessionNum = "???"
        var totalWithNoOS = 0
        var header = ""
        var headers = [String: Int]()
        while lineNum < lines.count - 3 {
            let line = lines[lineNum]
            lineNum += 1
            if !line.hasPrefix(" ") {
                printHeaderCount(header: header, headers: headers)
                header = line.trim
                print("\nHeader line \(lineNum) \"\(header)\"")
                continue
            }
            let titleIndented = line.dropFirst()
            let title = lines[lineNum]
            lineNum += 1
            if title != titleIndented {
                if lineNum < 10 && title == "FILTER" { continue }
                let msg = "⛔️ analyseWWDC #\(#line) Bad format in \(file)! line#\(lineNum)\n  \"\(titleIndented)\" different from \"\(title)\""
                print(msg)
                attTx  = NSMutableAttributedString(string: msg + "\n", attributes: attributesErrorFont)
                attTxt.append(attTx)
                break
            }
            headers[header, default: 0] += 1
            let sessionAndOS = lines[lineNum]
            lineNum += 1
            let desc = lines[lineNum]
            lineNum += 1
            let comps = sessionAndOS.components(separatedBy: " ")
            if comps.count < 3 || comps[0] != "Session" {
                let msg = "⛔️ analyseWWDC #\(#line) Bad format in \(file)! line#\(lineNum)\n  \"\(sessionAndOS)\""
                print(msg)
                attTx  = NSMutableAttributedString(string: msg + "\n", attributes: attributesErrorFont)
                attTxt.append(attTx)
            }
            totalSessions += 1
            sessionNum = comps[1]
//            for i in 2..<comps.count {
//                print("🇺🇸 \(title) 🔹 \(comps[i])")
//            }
            let allText = title + "|" + desc
            var iOS     = allText.contains("iOS")     ? "1" : "0"
            var macOS   = allText.contains("macOS")   ? "1" : "0"
            //if allText.contains("UI")    { iOS = "1" }
            if allText.contains("ARKit") { iOS = "1" }
            var tvOS    =  "0"
            var watchOS =  "0"
            if iOS == "0" && macOS == "0"  {
                tvOS    = allText.contains("tvOS")    ? "1" : "0"
                watchOS = allText.contains("watchOS") ? "1" : "0"
                if tvOS == "0"  && watchOS == "0" {
                    //print("😡 no OS: \(title) ")
                    iOS     = "1"
                    macOS   = "1"
                    totalWithNoOS += 1
                }
            }

            let keyWords = getKeyWordVal(title: title, desc: desc)
            var keyWord: String
            if keyWords.isEmpty {keyWord = ""} else { keyWord = keyWords[0] }
            if keyWords.count > 1 {
                print("line#\(lineNum) \(keyWords)  \(title)")
            } else if keyWords.count == 0 {
                print("line#\(lineNum)  <uncatagorized>            \(title)")
            }

            if tvOS == "1"                          { keyWord = "ztvOS" }
            if watchOS == "1"                       { keyWord = "WatchOS" }
            text += "\(year)\t\(sessionNum)\t\(macOS)\t\(iOS)\t\(title)\t\(keyWord)\t\t\t\t\(desc.prefix(400))\n"
        }//loop
        printHeaderCount(header: header, headers: headers)
        print("\n\(totalWithNoOS) Total With No OS")
    }
    else

        // MARK:- ... 2013, 2014, 2015
    {
        for line in lines {
            if flag {
                flag = false
                text += "\(str)\t\(line.prefix(350))\n"
            }
            if line.hasPrefix("Session") {
                let comps = line.split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true)
                let sessionNum = String(comps[1])                   // sessionNum
                var listOS = ""
                if comps.count > 2 { listOS = String(comps[2]) }
                let iOS = listOS.contains("iOS") ? "1" : "0"        // iOS
                let macOS = listOS.contains("macOS") ? "1" : "0"    // macOS
                str = "\(year)\t\(sessionNum)\t\(macOS)\t\(iOS)\t\(prevLine)"
                totalSessions += 1
                flag = true
            }
            prevLine = line
        }
    }
    attTx  = NSMutableAttributedString(string: text, attributes: attributesSmallFont)
    attTxt.append(attTx)
    let msg = "\(totalSessions) Total Sessions"
    print("\(totalSessions) Total Sessions")
    //alertW("\(totalSessions) Total Sessions", title: "Done")
    return (attTxt, "Success|" + msg)
}//end func analyseWWDC

func printHeaderCount(header: String, headers: [String: Int]) {
    if !header.isEmpty {
        if let count = headers[header] {
            print("\(count) sessions in \"\(header)\"")
        }
    }
}

//MARK:- getKeyWordVal - Return a list of Keywords
func getKeyWordVal(title: String, desc: String) -> [String] {

    enum kw {
        static var accessibility = "Accessibility"
        static var accelerate   = "Accelerate"
        static var airPlay      = "AirPlay"
        static var airPrint     = "AirPrint"
        static var applePay     = "ApplePay"
        static var appStore     = "AppStore"
        static var debugging    = "Debugging"
        static var file         = "File"
        static var GCD          = "GCD"
        static var localization = "Localization"
        static var metal        = "Metal"
        static var performance  = "Performance"
        static var photo        = "Photo"
        static var siri         = "Siri"
        static var swift        = "Swift"
        static var swiftPackage = "SwiftPackage"
        static var testing      = "Testing"
        static var uiKit        = "UIKit"
        static var watchOS      = "WatchOS"
        static var web          = "Web"
        static var xcode        = "Xcode"
        static var xcodePreview = "XcodePreview"
    }
    var dictKeyWord = [String: Int]()

    func recordKeyWord(keyWord: String, weight: Int) {
        let prevWeight = dictKeyWord[keyWord] ?? 0
        if weight > prevWeight {
            dictKeyWord[keyWord] = weight
        }
    }

    let allText = title + "|" + desc
    let allLc = allText.lowercased()
    let titleLc = title.lowercased()

    // Words later in list override earlier words.
    if allText.contains("UIKit")            { recordKeyWord(keyWord: kw.uiKit,          weight:  2) }
    if allText.contains("Swift")            { recordKeyWord(keyWord: kw.swift,          weight:  4) }
    if allText.contains("Xcode")            { recordKeyWord(keyWord: kw.xcode,          weight:  6) }
    if desc.contains("Xcode Preview")       { recordKeyWord(keyWord: kw.xcodePreview,   weight: 26) }
    if desc.contains("Swift Package")       { recordKeyWord(keyWord: kw.swiftPackage,   weight: 27) }
    if allText.contains("Network")          { recordKeyWord(keyWord: kw.web,            weight:  8) }
    if allText.contains("AirPlay")          { recordKeyWord(keyWord: kw.airPlay,        weight:  8) }
    if allText.contains("AirPrint")         { recordKeyWord(keyWord: kw.airPrint,       weight: 10) }
    if allText.contains("App Store")        { recordKeyWord(keyWord: kw.appStore,       weight: 12) }
    if allText.contains("Apple Pay")        { recordKeyWord(keyWord: kw.applePay,       weight: 16) }
    if allText.contains("Wallet")           { recordKeyWord(keyWord: kw.applePay,       weight: 16) }
    if allText.contains("iAd")              { recordKeyWord(keyWord: kw.appStore,       weight: 18) }
    if allText.contains("StoreKit")         { recordKeyWord(keyWord: kw.appStore,       weight: 20) }
    if allText.contains("Accessib")         { recordKeyWord(keyWord: kw.accessibility,  weight: 22) }
    if   allLc.contains("accessibil")       { recordKeyWord(keyWord: kw.accessibility,  weight: 22) }
    if allText.contains("Accelerate")       { recordKeyWord(keyWord: kw.accelerate,     weight: 26) }
    if allText.contains("Auto Layout")      { recordKeyWord(keyWord: "AutoLayout",  weight: 28) }
    if allText.contains("AV")               { recordKeyWord(keyWord: "AV",          weight: 30) }
    if allText.contains("AR")               { recordKeyWord(keyWord: "AR",          weight: 32) }
    if allText.contains("CarPlay")          { recordKeyWord(keyWord: "CarPlay",     weight: 34) }
    if allText.contains("Cocoa")            { recordKeyWord(keyWord: "Cocoa",       weight: 36) }
    if allText.contains("Cocoa Touch")      { recordKeyWord(keyWord: "CocoaTouch",  weight: 38) }
    if allText.contains("Core Data")        { recordKeyWord(keyWord: "CoreData",    weight: 40) }
    if allText.contains("Core Location")    { recordKeyWord(keyWord: "CoreLocation",weight: 42) }
    if allText.contains("ML")               { recordKeyWord(keyWord: "CoreML",      weight: 44) }
    if allText.contains("Metal")            { recordKeyWord(keyWord: kw.metal,          weight: 46) }
    if   allLc.contains("photo")            { recordKeyWord(keyWord: kw.photo,          weight: 48) }
    if allText.contains("Core Image")       { recordKeyWord(keyWord: kw.photo,          weight: 50) }
    if allText.contains("UIImage")          { recordKeyWord(keyWord: kw.photo,          weight: 52) }
    if allText.contains("HealthKit")        { recordKeyWord(keyWord: "HealthKit",   weight: 54) }
    if allText.contains("Instruments")      { recordKeyWord(keyWord: kw.performance,    weight: 56) }
    if allText.contains("Profile")          { recordKeyWord(keyWord: kw.performance,    weight: 58) }
    if allText.contains("Siri")             { recordKeyWord(keyWord: kw.siri,           weight: 60) }
    if allText.contains("Web")              { recordKeyWord(keyWord: kw.web,            weight: 62) }
    if allText.contains("Safari")           { recordKeyWord(keyWord: kw.web,            weight: 62) }
    if allLc.contains("website")            { recordKeyWord(keyWord: kw.web,            weight: 62) }
    if allLc.contains("debug")              { recordKeyWord(keyWord: kw.debugging,      weight: 68) }
    if allLc.contains("testing")            { recordKeyWord(keyWord: kw.testing,        weight: 70) }
    if allLc.contains("unit t")             { recordKeyWord(keyWord: kw.testing,        weight: 70) }
    if allLc.contains("uitest")             { recordKeyWord(keyWord: kw.testing,        weight: 70) }

    // title overrides allText
    if title.contains("Shortcut")           { recordKeyWord(keyWord: kw.siri,           weight: 101)}
    if title.contains("Internet")           { recordKeyWord(keyWord: kw.web,            weight: 102) }
    if title.contains("Performance")        { recordKeyWord(keyWord: kw.performance,    weight: 104) }
    if title.contains("Core Image")         { recordKeyWord(keyWord: kw.photo,          weight: 106) }
    if titleLc.contains("watch")            { recordKeyWord(keyWord: kw.watchOS,        weight: 108) }
    if titleLc.contains("watchos")          { recordKeyWord(keyWord: kw.watchOS,        weight: 150) }
    if titleLc.contains("thread")           { recordKeyWord(keyWord: kw.GCD,            weight: 108) }
    if title.contains("Xcode")              { recordKeyWord(keyWord: kw.xcode,          weight: 110) }
    if title.contains("Xcode Preview")      { recordKeyWord(keyWord: kw.xcodePreview,   weight: 111) }
    if title.contains("Swift Package")      { recordKeyWord(keyWord: kw.swiftPackage,   weight: 111) }
    if title.contains("Testing")            { recordKeyWord(keyWord: kw.testing,        weight: 111) }
    if title.contains("Profiling")          { recordKeyWord(keyWord: kw.testing,        weight: 111) }
    if title.contains("Documents")          { recordKeyWord(keyWord: kw.file,           weight: 111) }
    if title.contains("Metal")              { recordKeyWord(keyWord: kw.metal,          weight: 112) }
    if title.contains("Localized")          { recordKeyWord(keyWord: kw.localization,   weight: 112) }
    if titleLc.contains("localization")     { recordKeyWord(keyWord: kw.localization,   weight: 114) }
    if title.contains("HomeKit")            { recordKeyWord(keyWord: "HomeKit",       weight: 116) }
    if title.contains("Notification")       { recordKeyWord(keyWord: "Notifications", weight: 118) }
    if title.contains("Global")             { recordKeyWord(keyWord: kw.localization,   weight: 120) }
    if title.contains("International")      { recordKeyWord(keyWord: kw.localization,   weight: 122) }
    if title.contains("TextKit")            { recordKeyWord(keyWord: "TextKit",       weight: 124) }
    if title.contains("AVKit")              { recordKeyWord(keyWord: "AV",            weight: 124) }
    if title.contains("AirPlay")            { recordKeyWord(keyWord: kw.airPlay,        weight: 124) }
    if title.contains("Maps")               { recordKeyWord(keyWord: "MapKit",      weight: 125) }
    if titleLc.contains("mapkit")           { recordKeyWord(keyWord: "MapKit",      weight: 125) }
    if titleLc.contains("swiftui")          { recordKeyWord(keyWord: "SwiftUI",     weight: 140) }
    if title.contains("LLVM")               { recordKeyWord(keyWord: kw.xcode,          weight: 132) }
    if title.contains("Accessibility")      { recordKeyWord(keyWord: kw.accessibility,  weight: 132) }
    if title.contains("LLDB")               { recordKeyWord(keyWord: kw.debugging,      weight: 134) }
    if title.contains("GCD")                { recordKeyWord(keyWord: kw.GCD,            weight: 134) }
    if title.contains("Debugging")          { recordKeyWord(keyWord: kw.debugging,      weight: 134) }
    if title.contains("File")               { recordKeyWord(keyWord: kw.file,           weight: 134) }
    if title.contains("Haptic")             { recordKeyWord(keyWord: "Haptics",     weight: 134) }
    if title.contains("Grand Central")      { recordKeyWord(keyWord: kw.GCD,            weight: 144) }
    if title.contains("Central Dispatch")   { recordKeyWord(keyWord: kw.GCD,            weight: 144) }
    if title.contains("Cocoa Touch")        { recordKeyWord(keyWord: "CocoaTouch",  weight: 136) }
    if title.contains("Auto Layout")        { recordKeyWord(keyWord: "AutoLayout",  weight: 138) }
    if title.contains("App Store")          { recordKeyWord(keyWord: kw.appStore,       weight: 140) }
    if title.contains("New in Swift")       { recordKeyWord(keyWord: kw.swift,          weight: 142) }
    if title.contains("iPad Apps for Mac")  { recordKeyWord(keyWord: "iPadToMac",   weight: 134) }

    // These override the above titles
    if title.contains("Keynote")            { recordKeyWord(keyWord: "01",          weight: 206) }
    if title.hasPrefix("Platforms")         { recordKeyWord(keyWord: "02",          weight: 290) }
    if title.contains("Awards")             { recordKeyWord(keyWord: "03",          weight: 204) }
    if allLc.contains("playground")         { recordKeyWord(keyWord: "Playgrounds", weight: 202) }
    if title.contains("Bluetooth")          { recordKeyWord(keyWord: "Bluetooth",   weight: 208) }

    var keyWords = [String]()
    for (key, _) in  dictKeyWord.sorted(by: {$0.value > $1.value}) {
        keyWords.append(key)
    }
    return keyWords

}//end func getKeyWordVal
