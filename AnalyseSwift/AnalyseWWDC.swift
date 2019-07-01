//
//  AnalyseWWDC.swift
//  AnalyseSwiftCode
//
//  Created by George Bauer on 3/17/19.
//  Copyright © 2019 George Bauer. All rights reserved.
//

// Needs cocoa for NSFont
import Cocoa

//TODO: Allow multiple Keywords

let verWWDC = "2.2.1"

//MARK:- analyseWWDC 17-158 = 141-lines
func analyseWWDC(_ str: String, selecFileInfo: FileAttributes) -> (NSAttributedString, String) {
    let lines = str.components(separatedBy: "\n")
    var attTx: NSMutableAttributedString = NSMutableAttributedString(string: "")
    let attTxt:NSMutableAttributedString = NSMutableAttributedString(string: "")
    let attributesLargeFont = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 20)]
    let attributesErrorFont = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 16)]
    let attributesSmallFont = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 12)]

    let downloadedVideos = getDownloads(fromUrl: selecFileInfo.url!)

    var year    = 0
    var lineNum = 0
    for _ in 0...6 {
        let line = lines[lineNum]
        lineNum += 1
        if line .hasPrefix("WWDC") {
            let str = "\(line)\t\t\t\tVersion \(verWWDC)\n"
            attTx  = NSMutableAttributedString(string: str, attributes: attributesLargeFont)
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

    var text = "Year \tSess\tOSX\tiOS\tTitle \tKeyword \twant \tfin \thave \tDescription\n"
    attTx  = NSMutableAttributedString(string: text, attributes: attributesSmallFont)
    attTxt.append(attTx)

    var totalSessions = 0
    var sessionsWithNoKeyword = 0

    // MARK:- 2016, 2017, 2018, 2019,...

    var sessionNum      = "???"
    var totalWithNoOS   = 0
    var header          = ""
    var headers         = [String: Int]()
    var outputLines     = [(line: String, sortBy: String)]()
    text = ""
    //MARK: Loop through text lines 68-144 = 76-lines
    while lineNum < lines.count - 3 {
        let line = lines[lineNum]
        lineNum += 1
        if !line.hasPrefix(" ") {
            printHeaderCount(header: header, headers: headers)
            header = line.trim
            print("\nanalyseWWDC #\(#line) Header line \(lineNum) ---- \"\(header)\" ----")
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
        let vidKey = "\(year)-\(sessionNum)"
        let downloadedVid = downloadedVideos[vidKey] ?? ""
//        if !downloadedVid.isEmpty {
//            print("analyseWWDC #\(#line) Found video file \(vidKey) = \(downloadedVid)  \(title)")
//        }
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

        let keyWords = getKeyWordVal(title: title, desc: desc, year: year)
        var keyWord: String
        if keyWords.isEmpty {
            keyWord = sessionNum
            sessionsWithNoKeyword += 1
        } else {
            keyWord = keyWords[0]
        }
        if keyWords.count > 1 {
            print("analyseWWDC #\(#line) line#\(lineNum) \(keyWords.count) keywords \(keyWords)  \(title)")
        } else if keyWords.count == 0 {
            print("analyseWWDC #\(#line) line#\(lineNum)  <uncatagorized>            \(title)")
        }
        //TODO: Change system for detecting OS
        if tvOS == "1"                          { keyWord = "ztvOS" }
        //if watchOS == "1"                       { keyWord = "WatchOS" }
        let t = "\(year)\t\(sessionNum)\t\(macOS)\t\(iOS)\t\(title)\t\(keyWord)\t\t\t\(downloadedVid)\t\(desc)\n"
        text += t
        outputLines.append((t, keyWord.lowercased()+sessionNum))
    }//loop
    outputLines.sort {$0.sortBy < $1.sortBy}
    let oLines = outputLines.map { $0.line }
    printHeaderCount(header: header, headers: headers)
    print("\n\(totalWithNoOS) Total With No OS")
    text = oLines.joined()
    attTx  = NSMutableAttributedString(string: text, attributes: attributesSmallFont)
    attTxt.append(attTx)
//    pasteBoard.writeObjects([text as NSString])
    let msg = "\(totalSessions) Total Sessions\n \(sessionsWithNoKeyword) with no Keyword\n\(downloadedVideos.count) Videos Downloaded\n\nResults are in Clipboard.\nPaste into blank spreadsheet cell A1"
    print("analyseWWDC #\(#line) \(totalSessions) Total Sessions")
    //alertW("\(totalSessions) Total Sessions", title: "Done")
    copyToClipBoard(textToCopy: attTxt.string)
    return (attTxt, "WWDC-\(year) Done|" + msg)
}//end func analyseWWDC

func getDownloads(fromUrl: URL) -> [String: String] {
    var dict = [String: String]()
    let filename = fromUrl.deletingPathExtension().lastPathComponent
    if filename.count < 9 || !filename.hasPrefix("WWDC") { return dict }
    let yearStr = String(filename.suffix(4))
    guard let year = Int(yearStr) else { return dict }
    if year < 2000 || year > 2050 { return dict }
    let urlVid = fromUrl.deletingLastPathComponent().appendingPathComponent("WWDC " + yearStr)
    print("ViewController #\(#line) \(urlVid.path)")
    guard let files = try? FileManager.default.contentsOfDirectory(atPath: urlVid.path) else { return dict }
    let filteredFiles = files.filter { $0.hasSuffix(".mp4") || $0.hasSuffix(".mov") || $0.hasSuffix(".m4v") }
    for file in filteredFiles {
        let comps = file.components(separatedBy: "_")
        if comps.count < 3 {
            print("😡 ViewController #\(#line) file \"\(file)\" missing underscores")
            continue
        }
        let key = yearStr + "-" + comps[0]
        var value = comps[1]
        if value == "hd" { value = "HD" }
        if dict[key] != "HD" {
            dict[key] = value
        }
        //print(key,value)
    }
    print("🔷 ViewController #\(#line) -- \(filteredFiles.count) session videos found in \(urlVid.path)")
    return dict
}



//MARK:- printHeaderCount
func printHeaderCount(header: String, headers: [String: Int]) {
    if !header.isEmpty {
        if let count = headers[header] {
            print("analyseWWDC #\(#line) \(count) sessions in \"\(header)\"")
        }
    }
}

//MARK:- copyToClipBoard
public func copyToClipBoard(textToCopy: String) {
    let pasteBoard = NSPasteboard.general
    pasteBoard.clearContents()
    pasteBoard.setString(textToCopy, forType: NSPasteboard.PasteboardType.string)
}

//MARK:- getKeyWordVal - Return a list of Keywords
func getKeyWordVal(title: String, desc: String, year: Int) -> [String] {

    enum kw {
        static var accessibility = "Accessibility"
        static var accelerate   = "Accelerate"
        static var airPlay      = "AirPlay"
        static var airPrint     = "AirPrint"
        static var alert        = "Alerts"
        static var applePay     = "ApplePay"
        static var appStore     = "AppStore"
        static var ARVR         = "AR/VR"
        static var AVKit        = "AVKit"
        static var audio        = "Audio"
        static var autoLayout   = "AutoLayout"
        static var batteryLife  = "BatteryLife"
        static var bluetooth    = "Bluetooth"
        static var careKit      = "CareKit"
        static var carPlay      = "CarPlay"
        static var classKit     = "ClassKit"
        static var collectionView = "CollectionView"
        static var coreMotion   = "CoreMotion"
        static var coreData     = "CoreData"
        static var coreLocation = "CoreLocation"
        static var coreML       = "CoreML"
        static var debugging    = "Debugging"
        static var design       = "Design"
        static var dragnDrop    = "Drag&Drop"
        static var enterprise   = "Enterprise"
        static var file         = "File"
        static var font         = "Font"
        static var foundation   = "Foundation"
        static var game         = "Game"
        static var GCD          = "GCD"
        static var haptics      = "Haptics"
        static var healthKit    = "HealthKit"
        static var homeKit      = "HomeKit"
        static var HTTPLIVE     = "HTTPLive"
        static var iCloud       = "iCloud"
        static var image        = "Image"
        static var iMessage     = "iMessage"
        static var localization = "Localization"
        static var mapKit       = "MapKit"
        static var metal        = "Metal"
        static var naturalLang  = "NaturalLang"
        static var NFC          = "NFC"
        static var notification = "Notification"
        static var obsolete     = "Obsolete"
        static var pdfKit       = "PDFKit"
        static var pencil       = "Pencil"
        static var performance  = "Performance"
        //static var photo        = "Photo"
        static var playground   = "Playground"
        static var replayKit    = "ReplayKit"
        static var searchAPI    = "Search API"
        static var security     = "Security"
        static var siri         = "Siri"
        static var sourceContrl = "Source Contrl"
        static var speechRec    = "SpeechRecog'n"
        static var startup      = "Startup"     //Launch
        static var swift        = "Swift"
        static var swiftPackage = "SwiftPackage"
        static var testing      = "Testing"
        static var textKit      = "TextKit"
        static var touchBar     = "Touch Bar"
        static var iOS          = "iOS"
        static var macOS        = "macOS"
        static var watchOS      = "WatchOS"
        static var web          = "Web"
        static var windows      = "Windows" //Multitasking
        static var xcode        = "Xcode"
        static var xcodePreview = "XcodePreview"
        // WWDC-2019
        static var catalyst     = "Catalyst"
        static var combine      = "Combine"
        static var swiftUI      = "SwiftUI"
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

    // Metal trumps Debugging
    //"High Efficiency Image" trumps File
    //PDFKit trumps iOS
    //ARKit trumps iOS
    //HEIF and HEVC -> Image,  not Photo
    //App Icon Design -> Image
    //Localizing trumps Xcode
    //GitHub and the New Source Control
    //Crashes and Crash Logs -> Debugging
    //ReplayKit
    //CarPlay trumps Audio
    //CocoaTouch -> iOS
    //Natural Language
    //AR trumps Game
    //SF Symbols -> Image
    //watchOS but not iOS or macOS in desc
    //AU "Audio Unit"

    //TODO: AVKit, Image -> Media? AVCapture?
    //TODO: 2019-418 Getting the Most Out of Simulator    Metal    (... of Simulator. Find out how Simulator works, discover features you might not know exist, and get a tour of the command-line interface to Simulator for automation. Learn about native GPU acceleration in Simulator via Metal, and how to optimize your Metal code...)

    //TODO: 2018-236 AVSpeechSynthesizer: Making iOS Talk    AVKit->?
    //TODO: 2018-507 AVContentKeySession Best Practices      AVKit->           (management of FairPlay content decryption keys for HTTP Live Streaming.)

    //TODO: 2013-707 What's New in Kext Development    ->Kext
    //TODO: 2013-204 What's New with Multitasking   Windows->? ...new APIs in iOS 7 will let your apps fetch data in the background...

    //2019-803 Designing Great ML Experiences    Design->CoreML  (Machine learning...)
    //2019-602 Working with USD (Universal Scene Description) ->Game
    //2019-417 Improving Battery Life and Performance    Performance->Battery   (new ways to find and fix performance issues during daily development, beta testing, and public release on the App Store. Learn how to catch performance issues during daily development by measuring CPU, memory, and more in your XCTests)
    //2018-228 What’s New in Energy Debugging    Debugging->Battery  (People expect long battery life on their mobile devices ... affects battery consumption ... Xcode Energy Reports...)
    //2017-813 Writing Great Alerts    ->Alerts
    //2017-806 Design For Everyone    Design->Accessibility    ...Learn how designing for accessibility and inclusiveness can...
    //2016-303 Apple Device Management
    //2015-712 Low Energy, High Performance: Compression and Accelerate   Performance->Accelerate   (The Accelerate framework...)
    //2013-219 Making Your App World-Ready    ->Localization   ... and languages is easy with the built-in power of iOS and OS X. Walk through the basics of internationalization and localization...
    //2013-412 Continuous Integration with Xcode 5    Xcode->Testing
    //2013-701 Maximizing Battery Life on OS X ->Battery
    //2013-611 Building Advanced iBooks HTML 5 Widgets and iAd ...   " iAD "->Obs


    //2017-821 Get Started with Display P3   ->Media      (Wide color displays...)
    //2016-301 "Subscription" "iTunes Connect" ->AppStore
    //2016-420 Optimizing Web Content in Your App     debug->Web
    //2016-711 NSURLSession           ->Web
    //2016-712 Wide Color             ->Image
    //2016-612 Game Technologies for Apple Watch      Game->Watch

    // Words later in list override earlier words.
    if allText.contains("UIKit")            { recordKeyWord(keyWord: kw.iOS,            weight:  2) }
    if allText.contains("Swift")            { recordKeyWord(keyWord: kw.swift,          weight:  4) }
    if desc.contains("Xcode")               { recordKeyWord(keyWord: kw.xcode,          weight:  6) }
    if desc.contains("ReplayKit")           { recordKeyWord(keyWord: kw.replayKit,      weight: 20) }
    if desc.contains("Xcode Preview")       { recordKeyWord(keyWord: kw.xcodePreview,   weight: 26) }
    if desc.contains("Swift Package")       { recordKeyWord(keyWord: kw.swiftPackage,   weight: 27) }
    if allText.contains("Network")          { recordKeyWord(keyWord: kw.web,            weight:  8) }
    if desc.contains("AirPlay")             { recordKeyWord(keyWord: kw.airPlay,        weight:  8) }
    if allText.contains("AirPrint")         { recordKeyWord(keyWord: kw.airPrint,       weight: 10) }
    if desc.contains("App Store")           { recordKeyWord(keyWord: kw.appStore,       weight: 12) }
    if desc.contains("Apple Watch")         { recordKeyWord(keyWord: kw.watchOS,        weight: 16) }
    if desc.contains("Wallet")              { recordKeyWord(keyWord: kw.applePay,       weight: 16) }
    if allText.contains("iAd")              { recordKeyWord(keyWord: kw.obsolete,       weight: 18) }
    if allText.contains("StoreKit")         { recordKeyWord(keyWord: kw.appStore,       weight: 72) }
    if allText.contains("Accessib")         { recordKeyWord(keyWord: kw.accessibility,  weight: 22) }
    if   allLc.contains("accessibil")       { recordKeyWord(keyWord: kw.accessibility,  weight: 22) }
    if allText.contains("Accelerate")       { recordKeyWord(keyWord: kw.accelerate,     weight: 26) }
    if desc.contains("Auto Layout")         { recordKeyWord(keyWord: kw.autoLayout,     weight: 28) }
    if desc.contains("AV")                  { recordKeyWord(keyWord: kw.AVKit,          weight: 30) }
    if desc.contains("AR")                  { recordKeyWord(keyWord: kw.ARVR,           weight: 30) }
    if desc.contains("CarPlay")             { recordKeyWord(keyWord: kw.carPlay,        weight: 34) }
    if desc.contains("Cocoa")               { recordKeyWord(keyWord: kw.macOS,          weight: 36) }
    if desc.contains("Cocoa Touch")         { recordKeyWord(keyWord: kw.iOS,            weight: 38) }
    if allText.contains("Core Data")        { recordKeyWord(keyWord: kw.coreData,       weight: 40) }
    if allText.contains("Core Location")    { recordKeyWord(keyWord: kw.coreLocation,   weight: 42) }
    if allText.contains("ML")               { recordKeyWord(keyWord: kw.coreML,         weight: 44) }
    if desc.contains("Audio U")             { recordKeyWord(keyWord: kw.audio,          weight: 45) }
    if desc.contains("Metal")               { recordKeyWord(keyWord: kw.metal,          weight: 46) }
    if   allLc.contains("photo")            { recordKeyWord(keyWord: kw.image,          weight: 48) }
    if desc.contains("Core Image")          { recordKeyWord(keyWord: kw.image,          weight: 50) }
    if desc.contains("PDFKit")              { recordKeyWord(keyWord: kw.pdfKit,         weight: 52) }
    if allLc.contains("watchos") && !allLc.contains("ios") && !allLc.contains("macos") {
                                            recordKeyWord(keyWord: kw.watchOS, weight: 100)
    }

    if allText.contains("UIImage")          { recordKeyWord(keyWord: kw.image,          weight: 52) }
    if allText.contains("HealthKit")        { recordKeyWord(keyWord: kw.healthKit,      weight: 54) }
    if allText.contains("Instruments")      { recordKeyWord(keyWord: kw.performance,    weight: 56) }
    if allText.contains("Profile")          { recordKeyWord(keyWord: kw.performance,    weight: 58) }
    if allText.contains("Siri")             { recordKeyWord(keyWord: kw.siri,           weight: 60) }
    if desc.contains("Web")                 { recordKeyWord(keyWord: kw.web,            weight: 62) }
    if allText.contains("Safari")           { recordKeyWord(keyWord: kw.web,            weight: 62) }
    if allText.contains("Apple Pencil")     { recordKeyWord(keyWord: kw.pencil,         weight: 75) }

    if allLc.contains("website")            { recordKeyWord(keyWord: kw.web,            weight: 62) }
    if allLc.contains("debug")              { recordKeyWord(keyWord: kw.debugging,      weight: 68) }
    if allLc.contains("testing")            { recordKeyWord(keyWord: kw.testing,        weight: 70) }
    if allLc.contains("unit t")             { recordKeyWord(keyWord: kw.testing,        weight: 70) }
    if allLc.contains("uitest")             { recordKeyWord(keyWord: kw.testing,        weight: 70) }
    if desc.contains("HTTP Live")           { recordKeyWord(keyWord: kw.HTTPLIVE,       weight: 71) }

    // title overrides allText
    if title.contains("Design")             { recordKeyWord(keyWord: kw.design,         weight: 100) }
    if allLc.contains("accessibility")      { recordKeyWord(keyWord: kw.accessibility,  weight: 101) }

    if title.contains("Internet")           { recordKeyWord(keyWord: kw.web,            weight: 102) }
    if title.contains("Alerts")             { recordKeyWord(keyWord: kw.alert,          weight: 103) }
    if title.contains("Color")              { recordKeyWord(keyWord: kw.image,          weight: 103) }
    if title.contains("P3")                 { recordKeyWord(keyWord: kw.image,          weight: 103) }
    if title.contains("Performance")        { recordKeyWord(keyWord: kw.performance,    weight: 104) }
    if title.contains("Core Image")         { recordKeyWord(keyWord: kw.image,          weight: 106) }

    if title.contains("Icon")               { recordKeyWord(keyWord: kw.image,          weight: 100) }
    if title.contains("App Icon")           { recordKeyWord(keyWord: kw.image,          weight: 130) }
    if title.contains("Apple Pay")          { recordKeyWord(keyWord: kw.applePay,       weight: 115) }
    if title.contains("Wallet")             { recordKeyWord(keyWord: kw.applePay,       weight: 115) }
    if title.contains("ReplayKit")          { recordKeyWord(keyWord: kw.replayKit,      weight: 116) }

    if title.contains("Subscription")       { recordKeyWord(keyWord: kw.appStore,       weight: 115) }
    if title.contains("iTunes Conn")        { recordKeyWord(keyWord: kw.appStore,       weight: 115) }

    if title.contains("Audio")              { recordKeyWord(keyWord: kw.audio,          weight: 114) }
    if title.contains("CarPlay")            { recordKeyWord(keyWord: kw.carPlay,        weight: 129) }
    if title.contains("Game")               { recordKeyWord(keyWord: kw.game,           weight: 109) }
    if title.contains("AR")                 { recordKeyWord(keyWord: kw.ARVR,           weight: 112) }
    if title.contains("iAd")                { recordKeyWord(keyWord: kw.obsolete,       weight: 112) }
    if title.contains("ClassKit")           { recordKeyWord(keyWord: kw.classKit,       weight: 115) }
    if title.contains("CloudKit")           { recordKeyWord(keyWord: kw.iCloud,         weight: 122) }
    if title.contains("Drag and Drop")      { recordKeyWord(keyWord: kw.dragnDrop,      weight: 122) }
    if titleLc.contains("font")             { recordKeyWord(keyWord: kw.font,           weight: 110) }
    if title.contains("Windows")            { recordKeyWord(keyWord: kw.windows,        weight: 109) }
    if title.contains("Multitasking")       { recordKeyWord(keyWord: kw.windows,        weight: 109) }
    if title.contains("Apple Watch")        { recordKeyWord(keyWord: kw.watchOS,        weight: 150) }
    if titleLc.contains("watch")            { recordKeyWord(keyWord: kw.watchOS,        weight: 108) }
    if titleLc.contains("watchos")          { recordKeyWord(keyWord: kw.watchOS,        weight: 150) }
    if titleLc.contains("thread")           { recordKeyWord(keyWord: kw.GCD,            weight: 108) }
    if title.contains("Xcode")              { recordKeyWord(keyWord: kw.xcode,          weight: 110) }
    if title.contains("Xcode Preview")      { recordKeyWord(keyWord: kw.xcodePreview,   weight: 111) }
    if title.contains("Swift Package")      { recordKeyWord(keyWord: kw.swiftPackage,   weight: 111) }
    if title.contains("Testing")            { recordKeyWord(keyWord: kw.testing,        weight: 111) }
    if title.contains(" Continuous Integ")  { recordKeyWord(keyWord: kw.testing,        weight: 131) }
    if title.contains("UIKit Dynamics")     { recordKeyWord(keyWord: kw.game,           weight: 131) }
    if title.contains("Pencil")             { recordKeyWord(keyWord: kw.pencil,         weight: 115) }
    if title.contains("Profiling")          { recordKeyWord(keyWord: kw.testing,        weight: 111) }
    if title.contains("Documents")          { recordKeyWord(keyWord: kw.file,           weight: 111) }
    if title.contains("Web")                { recordKeyWord(keyWord: kw.web,            weight: 111) }
    if title.contains(" ML ")               { recordKeyWord(keyWord: kw.coreML,         weight: 113) }



    if title.contains("Foundation")         { recordKeyWord(keyWord: kw.foundation,     weight: 112) }  //>"Cocoa"
    if desc.contains("AV")                  { recordKeyWord(keyWord: kw.AVKit,          weight: 113) } //>Foundation
    if title.contains("Natural Language")   { recordKeyWord(keyWord: kw.naturalLang,    weight: 112) }
    if title.contains("Metal")              { recordKeyWord(keyWord: kw.metal,          weight: 150) }
    if title.contains("Localiz")            { recordKeyWord(keyWord: kw.localization,   weight: 112) }
    if titleLc.contains("localization")     { recordKeyWord(keyWord: kw.localization,   weight: 114) }
    if title.contains("SF Symbol")          { recordKeyWord(keyWord: kw.image,          weight: 145) }

    if title.contains("CareKit")            { recordKeyWord(keyWord: kw.careKit,        weight: 115) }
    if title.contains("ResearchKit")        { recordKeyWord(keyWord: kw.careKit,        weight: 115) }
    if title.contains("HomeKit")            { recordKeyWord(keyWord: kw.homeKit,        weight: 116) }
    if title.contains("SceneKit")           { recordKeyWord(keyWord: kw.game,           weight: 116) }
    if title.contains("Sprite Kit")         { recordKeyWord(keyWord: kw.game,           weight: 116) }
    if title.contains("SpriteKit")          { recordKeyWord(keyWord: kw.game,           weight: 116) }
    if title.contains("Scene Kit")          { recordKeyWord(keyWord: kw.game,           weight: 116) }
    if title.contains("PDFKit")             { recordKeyWord(keyWord: kw.pdfKit,         weight: 116) }
    if title.contains("ARKit")              { recordKeyWord(keyWord: kw.ARVR,           weight: 116) }
    if title.contains("TextKit")            { recordKeyWord(keyWord: kw.textKit,        weight: 125) }
    if title.contains("Text Kit")           { recordKeyWord(keyWord: kw.textKit,        weight: 125) }
    if title.contains("AVKit")              { recordKeyWord(keyWord: kw.AVKit,          weight: 125) }
    if title.contains("Map Kit")            { recordKeyWord(keyWord: kw.mapKit,         weight: 125) }
    if titleLc.contains("mapkit")           { recordKeyWord(keyWord: kw.mapKit,         weight: 125) }

    if title.contains("NFC")                { recordKeyWord(keyWord: kw.NFC,            weight: 116) }
    if title.contains("Startup")            { recordKeyWord(keyWord: kw.startup,        weight: 117) }
    if title.contains("Launch")             { recordKeyWord(keyWord: kw.startup,        weight: 117) }
    if title.contains("Notification")       { recordKeyWord(keyWord: kw.notification,   weight: 118) }
    if title.contains("iMessage")           { recordKeyWord(keyWord: kw.iMessage,       weight: 118) }
    if title.contains("Global")             { recordKeyWord(keyWord: kw.localization,   weight: 120) }
    if title.contains("International")      { recordKeyWord(keyWord: kw.localization,   weight: 122) }

    if title.contains("NSURLSession")       { recordKeyWord(keyWord: kw.web,            weight: 125) }

    if title.contains("AirPlay")            { recordKeyWord(keyWord: kw.airPlay,        weight: 124) }
    if title.contains("Maps")               { recordKeyWord(keyWord: kw.mapKit,         weight: 124) }

    if title.contains("RealityKit")         { recordKeyWord(keyWord: kw.ARVR,           weight: 125) }

    if title.contains("CollectionView")     { recordKeyWord(keyWord: kw.collectionView, weight: 125) }
    if title.contains("Collection View")    { recordKeyWord(keyWord: kw.collectionView, weight: 125) }
    if title.contains("Core Motion")        { recordKeyWord(keyWord: kw.coreMotion,     weight: 125) }
    if title.contains("Touch Bar")          { recordKeyWord(keyWord: kw.touchBar,       weight: 126) }
    if title.contains("Speech Recog")       { recordKeyWord(keyWord: kw.speechRec,      weight: 126) }
    if title.contains("Apple Watch")        { recordKeyWord(keyWord: kw.watchOS,        weight: 145) }
    if title.contains("Enterprise")          { recordKeyWord(keyWord: kw.enterprise,    weight: 155) }
    if title.contains("Apple Device") && title.contains("Manag") { recordKeyWord(keyWord: kw.enterprise, weight: 124) }
    if title.contains("Power")  && allLc.contains("battery")    {recordKeyWord(keyWord: kw.batteryLife, weight: 124)}
    if title.contains("iOS") && !title.contains("macOS")  && !title.contains("OS X") { recordKeyWord(keyWord: kw.iOS, weight: 100) }
    if !title.contains("iOS") && (title.contains("macOS") || title.contains("OS X")) { recordKeyWord(keyWord: kw.macOS, weight: 100) }
    if year >= 2018 {
        if title.contains("Shortcut")       { recordKeyWord(keyWord: kw.siri,           weight: 101) }
    }
    if year >= 2019 {
        if title.contains("Catalyst")       { recordKeyWord(keyWord: kw.catalyst,       weight: 140) }
        if title.contains("iPad Apps for Mac") { recordKeyWord(keyWord: kw.catalyst,    weight: 134) }
        if title.contains("Combine")        { recordKeyWord(keyWord: kw.combine,        weight: 140) }
        if titleLc.contains("swiftui")      { recordKeyWord(keyWord: kw.swiftUI,        weight: 141) }
    }
    if title.contains("Security")           { recordKeyWord(keyWord: kw.security,       weight: 132) }
    if title.contains("Privacy")            { recordKeyWord(keyWord: kw.security,       weight: 132) }
    if title.contains("Authenti")           { recordKeyWord(keyWord: kw.security,       weight: 132) }
    if title.contains("Password")           { recordKeyWord(keyWord: kw.security,       weight: 132) }

    if title.contains("LLVM")               { recordKeyWord(keyWord: kw.xcode,          weight: 132) }
    if title.contains("Accessibility")      { recordKeyWord(keyWord: kw.accessibility,  weight: 132) }
    if title.contains("LLDB")               { recordKeyWord(keyWord: kw.debugging,      weight: 134) }
    if title.contains("Debugging")          { recordKeyWord(keyWord: kw.debugging,      weight: 134) }
    if title.contains("Crash")              { recordKeyWord(keyWord: kw.debugging,      weight: 120) }
    if title.contains("GCD")                { recordKeyWord(keyWord: kw.GCD,            weight: 134) }
    if title.contains("File")               { recordKeyWord(keyWord: kw.file,           weight: 133) }
    if title.contains("HLS")                { recordKeyWord(keyWord: kw.HTTPLIVE,       weight: 134) }
    if title.contains("HEVC")               { recordKeyWord(keyWord: kw.image,          weight: 134) }
    if title.contains("High Efficiency Image") { recordKeyWord(keyWord: kw.image,       weight: 134) }
    if title.contains("HEIF")               { recordKeyWord(keyWord: kw.image,          weight: 134) }
    if title.contains("Haptic")             { recordKeyWord(keyWord: kw.haptics,        weight: 134) }
    if title.contains("Search API")         { recordKeyWord(keyWord: kw.searchAPI,      weight: 134) }
    if title.contains("Grand Central")      { recordKeyWord(keyWord: kw.GCD,            weight: 144) }
    if title.contains("Central Dispatch")   { recordKeyWord(keyWord: kw.GCD,            weight: 136) }
    if title.contains("Cocoa")              { recordKeyWord(keyWord: kw.macOS,          weight: 102) }
    if title.contains("Cocoa Touch")        { recordKeyWord(keyWord: kw.iOS,            weight: 103) }  //>"Cocoa"
    if title.contains("Auto Layout")        { recordKeyWord(keyWord: kw.autoLayout,     weight: 138) }
    if title.contains("App Store")          { recordKeyWord(keyWord: kw.appStore,       weight: 140) }
    if title.contains("New in Swift")       { recordKeyWord(keyWord: kw.swift,          weight: 142) }
    if title.contains("HTTP Live")          { recordKeyWord(keyWord: kw.HTTPLIVE,       weight: 134) }
    if title.contains("Dynamic Type")       { recordKeyWord(keyWord: kw.font,           weight: 134) }
    if title.contains("USD") && allLc.contains("scene")     { recordKeyWord(keyWord: kw.game, weight: 134) }
    if title.contains("Energy") && allLc.contains("battery"){ recordKeyWord(keyWord: kw.batteryLife, weight: 135) }
    if title.contains("Accelerate") && desc.contains("Accelerate") { recordKeyWord(keyWord: kw.accelerate, weight: 134) }
    if title.contains("orld") && allLc.contains("localization") { recordKeyWord(keyWord: kw.localization, weight: 134) }
    // These override the above titles
    if title.contains("Source Control")     { recordKeyWord(keyWord: kw.sourceContrl,   weight: 200) }
    if title.contains("Battery Life")       { recordKeyWord(keyWord: kw.batteryLife,    weight: 200) }
    if title.contains("GitHub")             { recordKeyWord(keyWord: kw.sourceContrl,   weight: 200) }
    if title.contains("Keynote")            { recordKeyWord(keyWord: "01",          weight: 206) }
    if title.hasPrefix("Platforms")         { recordKeyWord(keyWord: "02",          weight: 290) }
    if title.contains("Awards")             { recordKeyWord(keyWord: "03",          weight: 204) }
    if allLc.contains("playground")         { recordKeyWord(keyWord: kw.playground,     weight: 202) }
    if title.contains("Bluetooth")          { recordKeyWord(keyWord: kw.bluetooth,      weight: 208) }

    var keyWords = [String]()
    for (key, _) in  dictKeyWord.sorted(by: {$0.value > $1.value}) {
        keyWords.append(key)
    }
    if keyWords.isEmpty && title.contains("Kit") {
        print("😡 analyseWWDC #\(#line)  No keyword in \(title)")
    }
    return keyWords

}//end func getKeyWordVal
