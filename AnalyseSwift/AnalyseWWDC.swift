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
func analyseWWDC(_ str: String, selecFileInfo: FileAttributes) -> NSAttributedString {      //211-361 = 150-lines
    let lines = str.components(separatedBy: "\n")
    var attTx: NSMutableAttributedString = NSMutableAttributedString(string: "")
    let attTxt:NSMutableAttributedString = NSMutableAttributedString(string: "")
    let attributesLargeFont   = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 20), NSAttributedString.Key.paragraphStyle: paragraphStyleA1]
    //let attributesMediumFont = [NSAttributedStringKey.font: NSFont.systemFont(ofSize: 16), NSAttributedStringKey.paragraphStyle: paragraphStyleA1]
    let attributesSmallFont   = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 12), NSAttributedString.Key.paragraphStyle: paragraphStyleA1]

    var year = ""
    for i in 0...2 {
        let line = lines[i]
        if line .hasPrefix("WWDC") {
            attTx  = NSMutableAttributedString(string: lines[0] + "\n", attributes: attributesLargeFont)
            attTxt.append(attTx)
            let comps = line.components(separatedBy: " ")
            if comps.count >= 2 {
                year = comps[1]
                break
            }
        }
    }
    if year.isEmpty {
        print("⛔️ analyseWWDC #\(#line) Bad format in \(selecFileInfo.url!.lastPathComponent)!\nCould not find title \"WWDC 20xx\"")
        return attTxt
    }

    var prevLine = ""
    var flag = false
    var str = ""
    var text = "Year \tSess\tOSX\tiOS\tTitle \tKeyword \twant \tfin \tlang \tDescription\n"
    var totalSessions = 0

    if year == "2018" {
        let sessionNum = "???"
        var totalWithNoOS = 0
        var lineNum = 1
        while lineNum < lines.count - 2 {
            if lines[lineNum].isEmpty || lines[lineNum] == " " {
                lineNum += 1
                let titleIndented = lines[lineNum].dropFirst()
                lineNum += 1
                let title = lines[lineNum]
                totalSessions += 1
                if title != titleIndented {
                    print("\(titleIndented) != \(title)")
                }
                lineNum += 1
                let desc    = lines[lineNum]
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
                        print("😡 no OS: \(title) ")
                        iOS     = "1"
                        macOS   = "1"
                        totalWithNoOS += 1
                    }
                }
                let allLc = allText.lowercased()
                var keyWord = ""
                if allText.contains("UIKit")            { keyWord = "UIKit" }
                if allText.contains("Swift")            { keyWord = "Swift" }
                if allText.contains("Xcode")            { keyWord = "Xcode" }
                if allText.contains("AirPlay")          { keyWord = "AirPlay" }
                if allText.contains("AirPrint")         { keyWord = "AirPrint" }
                if allText.contains("App Store")        { keyWord = "AppStore" }
                if allText.contains("Apple Pay")        { keyWord = "ApplePay" }
                if allText.contains("Wallet")           { keyWord = "ApplePay" }
                if allText.contains("iAd")              { keyWord = "AppStore" }
                if allText.contains("StoreKit")         { keyWord = "AppStore" }
                if allText.contains("Accessib")         { keyWord = "Accessibility" }
                if   allLc.contains("accessibil")       { keyWord = "Accessibility" }
                if allText.contains("Accelerate")       { keyWord = "Accelerate" }
                if allText.contains("Auto Layout")      { keyWord = "AutoLayout" }
                if allText.contains("AV")               { keyWord = "AV" }
                if allText.contains("AR")               { keyWord = "AR" }
                if allText.contains("CarPlay")          { keyWord = "CarPlay" }
                if allText.contains("Cocoa")            { keyWord = "Cocoa" }
                if allText.contains("Cocoa Touch")      { keyWord = "CocoaTouch" }
                if allText.contains("Core Data")        { keyWord = "CoreData" }
                if allText.contains("Core Location")    { keyWord = "CoreLocation" }
                if allText.contains("ML")               { keyWord = "CoreML" }
                if allText.contains("Metal")            { keyWord = "Metal" }
                if   allLc.contains("photo")            { keyWord = "Photo" }
                if allText.contains("Core Image")       { keyWord = "Photo" }
                if allText.contains("UIImage")          { keyWord = "Photo" }
                if allText.contains("HealthKit")        { keyWord = "HealthKit" }
                if allText.contains("Instruments")      { keyWord = "Performance" }
                if allText.contains("Profile")          { keyWord = "Performance" }
                if allText.contains("Siri")             { keyWord = "Siri" }

                if title.hasPrefix("Platforms")         { keyWord = "Platforms" }

                if title.contains("HomeKit")            { keyWord = "HomeKit" }
                if title.contains("Notification")       { keyWord = "Notifications" }
                if title.contains("Global")             { keyWord = "Localizing" }
                if title.contains("International")      { keyWord = "Localizing" }
                if title.contains("TextKit")            { keyWord = "TextKit" }
                if title.contains("Maps")               { keyWord = "MapKit" }
                if title.contains("MapKit")             { keyWord = "MapKit" }

                if allLc.contains("playground")         { keyWord = "Playgrounds" }

                if allLc.contains("debug")              { keyWord = "Debugging" }
                if allLc.contains("testing") || allLc.contains("unit t") || allLc.contains("uitest")  { keyWord = "Testing" }

                if title.contains("Awards")             { keyWord = "Awards" }
                if title.contains("Keynote")            { keyWord = "Keynote" }
                if title.contains("Bluetooth")          { keyWord = "Bluetooth" }

                if allText.contains("Safari") || allText.contains("Web") { keyWord = "Web" }
                if allLc.contains("website")                             { keyWord = "Web" }
                if title.contains("Internet") || allText.contains("Web") { keyWord = "Web" }
                if tvOS == "1"                          { keyWord = "ztvOS" }
                if watchOS == "1"                       { keyWord = "zWatch" }
                text += "\(year)\t\(sessionNum)\t\(macOS)\t\(iOS)\t\(title)\t\(keyWord)\t\t\t\t\(desc.prefix(440))\n"
            }
            lineNum += 1
        }
        print("\(totalWithNoOS) Total With No OS")
    } else {
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
    print("\(totalSessions) Total Sessions")
    return attTxt
}//end func analyseWWDC
