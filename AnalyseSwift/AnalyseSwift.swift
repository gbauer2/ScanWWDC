//
//  AnalyseSwift.swift
//
//
//  Created by George Bauer on 1/10/18.
//  Copyright © 2018 George Bauer. All rights reserved.
//

import Cocoa

// MARK: - Properties for analyseSwiftFile 
var curlyDepth      = 0                     //accessed from gotOpenCurly, gotCloseCurly, getSelecFileInfo
var blockOnDeck     = BlockInfo()           //accessed from gotOpenCurly,                analyseSwiftFile
var blockStack      = [BlockInfo]()         //accessed from gotOpenCurly, gotCloseCurly, analyseSwiftFile
var codeElements    = [BlockInfo]()         //accessed from               gotCloseCurly, analyseSwiftFile
let paragraphStyleA1 = NSMutableParagraphStyle()    //accessed from showLineItems, showNamedBlock, analyseSwiftFile

// MARK: - Block Structs & Enums
enum BlockType: Int {
    case None           = 0
    case Func           = 1
    case IBAction_Func  = 2
    case Override_Func  = 3
    case Struct         = 4
    case Enum           = 5
    case Extension      = 6
    case Class          = 7
    case isProtocol     = 8
}

enum ProjectType {
    case unknown
    case OSX
    case iOS
}

struct BlockAggregate {
    let blockType:  BlockType
    let subType:    BlockType
    let codeName:   String
    let displayName: String
    let showNone:   Bool
    var count       = 0
}

struct BlockInfo {
    var blockType = BlockType.None
    var lineNum  = 0
    var codeLinesAtStart = 0
    var name     = ""
    var extra    = ""
    var numLines = 0
}

private struct LineItem {
    let lineNum: Int
    let name: String
    let extra: String
}


// MARK: - Helper funcs
// Returns NSMutableAttributedString showing name as a title, followed by list of items (line#, name, extra)
private func showLineItems(name: String, items: [LineItem]) -> NSMutableAttributedString {

    let txt = "\n" + showCount(count: items.count, name: name, ifZero: "No") + ":\n"
    let nsAttTxt = NSMutableAttributedString(string: txt, attributes: [NSAttributedStringKey.font: NSFont.systemFont(ofSize: 18), NSAttributedStringKey.paragraphStyle: paragraphStyleA1])
    for item in items {
        var tx = "      \t@ line # \(item.lineNum)    \t\(item.name)"
        if !item.extra.isEmpty {tx += "  (\(item.extra) )"}
        tx += "\n"
        let nsAttTx = NSAttributedString(string: tx, attributes: [NSAttributedStringKey.font: NSFont.systemFont(ofSize: 14), NSAttributedStringKey.paragraphStyle: paragraphStyleA1])
        nsAttTxt.append(nsAttTx)
    }
    return nsAttTxt
}

// Returns NSMutableAttributedString showing name as a title, followed by list of items (line#, name, extra)
private func showNamedBlock(name: String, blockType : BlockType, list: [BlockInfo]) -> NSMutableAttributedString {
    let items = list.filter { $0.blockType == blockType}
    let paragraphStyleA2 = NSMutableParagraphStyle()
    var tabStop0 = NSTextTab(textAlignment: .left, location: 0)
    paragraphStyleA2.tabStops = [ tabStop0 ]
    tabStop0 = NSTextTab(textAlignment: .right, location: 50)   //rt edge of 1st number
    paragraphStyleA2.addTabStop(tabStop0)
    tabStop0 = NSTextTab(textAlignment: .right, location: 52)    //lines @
    paragraphStyleA2.addTabStop(tabStop0)
    tabStop0 = NSTextTab(textAlignment: .right, location: 150)
    paragraphStyleA2.addTabStop(tabStop0)
    tabStop0 = NSTextTab(textAlignment: .left,  location: 200)
    paragraphStyleA2.addTabStop(tabStop0)
    let txt = "\n" + showCount(count: items.count, name: name, ifZero: "No") + ":\n"
    let nsAttTxt = NSMutableAttributedString(string: txt, attributes: [NSAttributedStringKey.font: NSFont.systemFont(ofSize: 18), NSAttributedStringKey.paragraphStyle: paragraphStyleA1])
    for item in items {
        var tx = "\t\(formatInt(number: item.numLines, fieldLen: 5))\t lines @\t\(item.lineNum) \t\(item.name)"
        if !item.extra.isEmpty {tx += "  (\(item.extra) )"}
        tx += "\n"
        let nsAttTx = NSAttributedString(string: tx, attributes: [NSAttributedStringKey.font: NSFont.systemFont(ofSize: 14), NSAttributedStringKey.paragraphStyle: paragraphStyleA2])
        nsAttTxt.append(nsAttTx)
    }
    return nsAttTxt
}

// push "ondeck" onto stack, clear ondeck,  stackedCounter = nCodeLines
private func gotOpenCurly(lineNum: Int) {
    //print("\(lineNum) got open curly; depth \(curlyDepth) -> \(curlyDepth+1)")
    blockStack.insert(blockOnDeck, at: 0)
    blockOnDeck = BlockInfo()
    curlyDepth += 1
}

// pop stackedCounter lines4item = nCodeLines - stackedCounter
private func gotCloseCurly(lineNum: Int, nCodeLine: Int) {

    //print("\(lineNum) got close curly; depth \(curlyDepth) -> \(curlyDepth-1)")
    curlyDepth -= 1
    var block = blockStack.remove(at: 0)
    if block.blockType != .None {
        //print("\(block.name)")
        block.numLines = nCodeLine - block.codeLinesAtStart // lineNum - block.lineNum
        codeElements.append(block)
    }
}

// Check that there is no "}" and no more the 1 "{" and only AFTER class,extension,func,struc,enum declaration
private func checkCurlys(codeName: String, itemName: String,posItem: Int, pOpenCurlyF: Int, pOpenCurlyR: Int, pCloseCurlyF: Int, pCloseCurlyR: Int) {
    if pOpenCurlyF > 0 && pOpenCurlyF < posItem {
        print("⛔️ open curly before \(codeName) \(itemName)")
    }
    if pOpenCurlyF != pOpenCurlyR {
        print("⛔️ more than 1 open curly on \(codeName) \(itemName) line")
    }
    if pCloseCurlyR > 0 {
        print("⛔️ close curly on \(codeName) \(itemName) line")
    }
    if pOpenCurlyR > posItem {
        //print("😃 open curly after \(codeName) \(itemName)")
    }
}

// Strip comment from line, returning code portion and comment-including-leading-spaces
func stripComment(fullLine: String, lineNum: Int) -> (codeLine: String, comment: String) {
    if !fullLine.contains("//") { return (fullLine, "") }               // No comment here

    var pCommentF   = fullLine.IndexOf("//")              // Leftmost "//"
    var pCommentR   = fullLine.IndexOfRev("//")           // Rightmost "//"
    let pQuoteF     = fullLine.IndexOf("\"")
    //let pQuoteR     = fullLine.IndexOfRev("\"")

    if pQuoteF >= 0 {                                           // we have a Quote
        var inQuote = false
        var isEscaped = false
        for p in 0..<fullLine.count {
            let char = fullLine.mid(begin: p, length: 1)
            if char == "\"" && !isEscaped { inQuote = !inQuote }    // if Quote not escaped,
            if inQuote {
                if p == pCommentF {
                    pCommentF = fullLine.IndexOf(searchforStr: "//", startPoint: p+1)
                }
                if p == pCommentR { pCommentR = -1 }
                isEscaped = (!isEscaped && (char == "\\"))
            }
        }

        if pCommentF < 0 { pCommentF = pCommentR }
        if pCommentR < 0 { pCommentR = pCommentF }

        if pCommentF != pCommentR {
            print("⚠️\(lineNum) Comment mismatch \(fullLine)")
        }

    }//endif pQuoteF >= 0

    if pCommentF >= 0 {
        let codeLinePlus = "^" + fullLine.left(pCommentF)
        let codeLineP = codeLinePlus.trim
        let nSpaces  = codeLinePlus.count - codeLineP.count
        let codeLine = String(codeLineP.dropFirst())
        let spaces: String = String(repeating: " ", count: nSpaces)
        let comment  = spaces + fullLine.mid(begin: pCommentF)
        return (codeLine, comment)
    }
    return (fullLine, "")
}//end func stripComment

func analyseWWDC(_ str: String, selecFileInfo: FileAttributes) -> NSAttributedString {
    let lines = str.components(separatedBy: "\n")
    var attTx: NSMutableAttributedString = NSMutableAttributedString(string: "")
    let attTxt:NSMutableAttributedString = NSMutableAttributedString(string: "")
    let attributesLargeFont  = [NSAttributedStringKey.font: NSFont.systemFont(ofSize: 20), NSAttributedStringKey.paragraphStyle: paragraphStyleA1]
    //let attributesMediumFont = [NSAttributedStringKey.font: NSFont.systemFont(ofSize: 16), NSAttributedStringKey.paragraphStyle: paragraphStyleA1]
    let attributesSmallFont  = [NSAttributedStringKey.font: NSFont.systemFont(ofSize: 12), NSAttributedStringKey.paragraphStyle: paragraphStyleA1]
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
        print("⛔️ Bad format in \(selecFileInfo.url!.lastPathComponent)!\nCould not find title \"WWDC 20xx\"")
        return attTxt
    }

    var prevLine = ""
    var flag = false
    var str = ""
    var text = "Year\tSess\tOSX\tiOS\tTitle\tKeyword\twant\tfin\tlang\tDescription\n"
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

                if   allLc.contains("playground")       { keyWord = "Playgrounds" }

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
                let sessionNum = String(comps[1])
                var listOS = ""
                if comps.count > 2 { listOS = String(comps[2]) }
                let iOS = listOS.contains("iOS") ? "1" : "0"
                let macOS = listOS.contains("macOS") ? "1" : "0"
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
}


// MARK: - the main event
// called from analyseContentsButtonClicked
func analyseSwiftFile(_ str: String, selecFileInfo: FileAttributes) -> NSAttributedString {
    let lines = str.components(separatedBy: "\n")

    var blockTypes = [BlockAggregate]()
    blockTypes.append(BlockAggregate(blockType: .None,          subType: .None, codeName: "",              displayName: "unNamed",      showNone: false, count: 0))
    blockTypes.append(BlockAggregate(blockType: .Func,          subType: .Func, codeName: "func",          displayName: "Regular func", showNone: true, count: 0))
    blockTypes.append(BlockAggregate(blockType: .IBAction_Func, subType: .Func, codeName: "IBAction func", displayName: "IBAction func",showNone: false, count: 0))
    blockTypes.append(BlockAggregate(blockType: .Override_Func, subType: .Func, codeName: "override func", displayName: "Override func",showNone: false, count: 0))
    blockTypes.append(BlockAggregate(blockType: .Struct,        subType: .Struct, codeName: "struct",      displayName: "Struct",       showNone: false, count: 0))
    blockTypes.append(BlockAggregate(blockType: .Enum,          subType: .Enum,  codeName: "enum",         displayName: "Enum",         showNone: false, count: 0))
    blockTypes.append(BlockAggregate(blockType: .Extension,     subType: .Class, codeName: "extension",    displayName: "Extension",    showNone: false, count: 0))
    blockTypes.append(BlockAggregate(blockType: .Class,         subType: .Class, codeName: "class",        displayName: "Class",        showNone: true, count: 0))
    blockTypes.append(BlockAggregate(blockType: .isProtocol,    subType: .isProtocol,codeName: "protocol", displayName: "Protocol",     showNone: false, count: 0))
    for i in 0..<blockTypes.count {         // Error check location in array vs. enum
        let ty = blockTypes[i]
        if i != ty.blockType.rawValue {
            print("⛔️ Error \(ty.blockType) \(i) <> \(ty.blockType.rawValue)")
        }
    }

    curlyDepth   = 0
    blockOnDeck  = BlockInfo()
    blockStack   = []
    codeElements = []

    var copyright       = ""
    var createdBy       = ""
    var version         = ""
    var containerName   = ""
    var projectType     = ProjectType.unknown
    var whatViewController = ""
    var index        = 0
    var lineNum      = 0
    var nCommentLine = 0
    var nBlankLine   = 0
    var nCodeLine    = 0
    var nTrailing    = 0

    var inMultiLineComment  = false
    var inQuote             = false
    var inTripleQuote       = false

    var inBlockName         = ["","","","","","","","",""]

    var imports         = [LineItem]()

    //var enums           = [LineItem]()
    //var classes         = [LineItem]()
    //var extensions      = [LineItem]()

    //infoTextView.string = "Analysing..."
    // MARK: - Main Loop
    for line in lines {
        if selecFileInfo.url != ViewController.latestUrl {
            if let latestUrl = ViewController.latestUrl {
                print("😎Working on \(selecFileInfo.url!),\n but \(latestUrl) is now current😎")
                let tx  = NSMutableAttributedString(string: "Abort!")
                return tx
            }
        }
        lineNum += 1
        var netCurlys = 0
        let aa = line.trim
        if aa.hasPrefix("/*") {                         // "/*"
            inMultiLineComment = true
        }

        if aa.hasPrefix("*/") {                         // "*/"
            inMultiLineComment = false
        }

        if aa.hasPrefix("//") || inMultiLineComment {   // "//"
            nCommentLine += 1
            if nCodeLine == 0 {
                if line.contains("Copyright") {
                    copyright = line
                } else if line.contains("Created by ") {
                    createdBy = line
                } else if line.contains("Ver") {
                    version = line
                }
            }
        } else if aa.isEmpty {
            nBlankLine += 1
        } else if aa.count == 1 {
            nBlankLine += 1
            if aa == "{" { gotOpenCurly(lineNum: lineNum) }                                 // single "{" on line
            if aa == "}" { gotCloseCurly(lineNum: lineNum, nCodeLine: nCodeLine) }          // single "}" on line
        } else {                                        // code! 232 - 439
            // MARK: - Code!
            nCodeLine += 1

            let (codeLine, comment) = stripComment(fullLine: aa, lineNum: lineNum)
            if !comment.isEmpty { nTrailing += 1 }

            let pQuoteF = codeLine.IndexOf("\"")
            let pQuoteR = codeLine.IndexOfRev("\"")

            var pOpenCurlyF = codeLine.IndexOf("{")
            var pOpenCurlyR = codeLine.IndexOfRev("{")
            var pCloseCurlyF = codeLine.IndexOf("}")
            var pCloseCurlyR = codeLine.IndexOfRev("}")

            inQuote = false
            var isEscaped = false
            for p in 0..<codeLine.count {
                let char = codeLine.mid(begin: p, length: 1)
                if char == "\"" && !isEscaped { inQuote = !inQuote }
                if inQuote {
                    if p == pOpenCurlyF  { pOpenCurlyF  = -1 }
                    if p == pOpenCurlyR  { pOpenCurlyR  = -1 }
                    if p == pCloseCurlyF { pCloseCurlyF = -1 }
                    if p == pCloseCurlyR { pCloseCurlyR = -1 }
                    isEscaped = (!isEscaped && (char == "\\"))
                } else {
                    if char == "{" { netCurlys += 1 }
                    if char == "}" { netCurlys -= 1 }
                }
            }
            if inQuote {
                print("🔶\(lineNum) Odd number of Quotes - \(aa)")
            }
            if (pQuoteF == pQuoteR) && (pQuoteF >= 0) {
                print("🔶\(lineNum) Unmatched Quote \(aa)")
            }
            if pOpenCurlyF >= 0 && (pOpenCurlyF != pOpenCurlyR) {
                print("🔶\(lineNum) multiple open curlys \(aa)")
            }
            if pCloseCurlyF >= 0 && (pCloseCurlyF != pCloseCurlyR) {
                print("🔶\(lineNum) multiple close curlys \(aa)")
            }
            // Create a CharacterSet of delimiters.
            let separators = CharacterSet(charactersIn: "\t (:")
            // Split based on characters.
            let wordsWithEmpty = codeLine.components(separatedBy: separators)
            // Use filter to eliminate empty strings.
            let words = wordsWithEmpty.filter { (x) -> Bool in !x.isEmpty }

            //if words.count < 2 { continue }                         // if less than 2 words, fogetaboutit

            var codeName = "import"
            if words.first! == codeName {
                let itemName = words[1]
                let lineItem = LineItem(lineNum: lineNum, name: itemName, extra: "")
                imports.append(lineItem)
                if itemName == "Cocoa" {
                    projectType = ProjectType.OSX
                } else if itemName == "UIKit"  {
                    projectType = ProjectType.iOS
                } else {

                }
                //print("\(lineNum) \(codeName) = \(itemName)")
                continue                                        // isImport
            }

            //MARK: - Blocks -> func, struc, enum, class, extension
            var foundNamedBlock = false

            //---------------------------------------------------------------   // func
            codeName = "func"
            if !foundNamedBlock && codeLine.contains(codeName) {
                //print("\(codeLine)")
                var posItem = -1
                for i in 0..<words.count {
                    if words[i] == codeName {
                        posItem = i
                        break
                    }
                }
                if posItem >= 0 {
                    //codeType = BlockType.isFunc
                    var itemName = "????"
                    if posItem < words.count {
                        itemName = words[posItem + 1]
                    }

                    checkCurlys(codeName: codeName, itemName: itemName, posItem: posItem, pOpenCurlyF: pOpenCurlyF, pOpenCurlyR: pOpenCurlyR, pCloseCurlyF: pCloseCurlyF, pCloseCurlyR: pCloseCurlyR)
                    blockOnDeck = BlockInfo(blockType: .Func, lineNum: lineNum, codeLinesAtStart: nCodeLine, name: itemName, extra: "", numLines: 0)
                    //inFuncName = itemName
                    if words.first! == "override" {
                        index = BlockType.Override_Func.rawValue                                // Override_Func
                        blockOnDeck.blockType = .Override_Func
                        blockTypes[index].count += 1
                    } else if words.first! == "@IBAction" {
                        index = BlockType.IBAction_Func.rawValue                                // IBAction_Func
                        blockOnDeck.blockType = .IBAction_Func
                        blockTypes[index].count += 1
                    } else {                            //private, internal, fileprivate, public
                        index = BlockType.Func.rawValue                                         // Func
                        containerName = ""
                        if blockStack.count > 0 {
                            containerName = (blockStack.last!.name)
                            blockOnDeck.name = "\(containerName).\(blockOnDeck.name)"
                        }

                        print("🔶func \(blockOnDeck.name)")
                        blockTypes[index].count += 1
                    }
                    foundNamedBlock = true
                }//endif posFunc
            }//end contains "func"

            for index in 4...8 {        // containers: 4)Struct, 5)Enum, 6)Extension, 7)Class, 8)isProtocol
                if foundNamedBlock { break }
                codeName = blockTypes[index].codeName
                if codeLine.contains(codeName) {
                    var posItem = -1
                    for i in 0...1 {
                        if words[i] == codeName {
                            posItem = i                 // position of Struct, Extension, Class, ...
                            break
                        }
                    }//next i

                    if posItem >= 0 {
                        let itemName = words[posItem + 1]
                        var extra = ""
                        for i in (posItem + 2)..<words.count {
                            if words[i].count > 1 {
                                extra += " " + words[i]
                            }
                        }
                        if codeName == "class" && words.count >= 3 && words[2].contains("ViewController") {
                            whatViewController = words[2]
                        }
                        checkCurlys(codeName: codeName, itemName: itemName, posItem: posItem, pOpenCurlyF: pOpenCurlyF, pOpenCurlyR: pOpenCurlyR, pCloseCurlyF: pCloseCurlyF, pCloseCurlyR: pCloseCurlyR)
                        blockOnDeck = BlockInfo(blockType: blockTypes[index].blockType, lineNum: lineNum, codeLinesAtStart: nCodeLine, name: itemName, extra: extra, numLines: 0)

                        inBlockName[index] = itemName                               // isStruct

                        blockTypes[index].count += 1
                        foundNamedBlock = true
                    }
                }//endif codeLine.contains
            }

            //---------------------------------------------------------------   //end Named Blocks

            if pOpenCurlyF >= 0 && (pCloseCurlyF < 0 || pCloseCurlyF > pOpenCurlyF) {       // starts with {
                gotOpenCurly(lineNum: lineNum)
                pOpenCurlyF = -1
                netCurlys -= 1
            }
            if pCloseCurlyF >= 0 && (pOpenCurlyF < 0 || pCloseCurlyF < pOpenCurlyF) {       // starts with }
                gotCloseCurly(lineNum: lineNum, nCodeLine: nCodeLine)
                netCurlys += 1
            }

            while netCurlys != 0 {
                if netCurlys > 0 {
                    gotOpenCurly(lineNum: lineNum)
                    netCurlys -= 1
                } else if netCurlys < 0 {
                    gotCloseCurly(lineNum: lineNum, nCodeLine: nCodeLine)
                    netCurlys += 1
                }
            }

        }//end is CodeLine
    }//next line

    //MARK:- end Main Loop
    //MARK:- Analysis display: NSMutableAttributedString

    // class: (superclass), (protocols)
    // extension: (protocols)
    // protocol, struct, enum
    var tx: NSMutableAttributedString = NSMutableAttributedString(string: "")
    let txt:NSMutableAttributedString = NSMutableAttributedString(string: "")

    print()
    //paragraphStyleA1
    let tabInterval: CGFloat = 100.0
    //var tabStops = [NSTextTab]()
    var tabStop0 = NSTextTab(textAlignment: .left, location: 0)
    paragraphStyleA1.tabStops = [ tabStop0 ]
    for i in 1...8 {
        tabStop0 = NSTextTab(textAlignment: .left, location: tabInterval * CGFloat(i))
        paragraphStyleA1.addTabStop(tabStop0)
    }

    let attributesLargeFont  = [NSAttributedStringKey.font: NSFont.systemFont(ofSize: 20), NSAttributedStringKey.paragraphStyle: paragraphStyleA1]
    let attributesMediumFont = [NSAttributedStringKey.font: NSFont.systemFont(ofSize: 16), NSAttributedStringKey.paragraphStyle: paragraphStyleA1]
    let attributesSmallFont  = [NSAttributedStringKey.font: NSFont.systemFont(ofSize: 12), NSAttributedStringKey.paragraphStyle: paragraphStyleA1]

    tx  = NSMutableAttributedString(string: "\t1\t2\t3\t4\t5\n", attributes: attributesSmallFont)
    txt.append(tx)

    if projectType == ProjectType.OSX {
        tx = NSMutableAttributedString(string: "Mac OSX  ", attributes: attributesLargeFont)
        txt.append(tx)
    } else if projectType == ProjectType.iOS {
        tx = NSMutableAttributedString(string: "iOS    ", attributes: attributesLargeFont)
        txt.append(tx)
    }

    tx  = NSMutableAttributedString(string: "\(selecFileInfo.name) \(whatViewController)\n", attributes: attributesLargeFont)
    txt.append(tx)

    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    let cDate = dateFormatter.string(from: selecFileInfo.creationDate!)

    dateFormatter.timeStyle = .short
    let mDate = dateFormatter.string(from: selecFileInfo.modificationDate!)

    tx  = NSMutableAttributedString(string: "created: \(cDate)     modified: \(mDate)\n", attributes: attributesSmallFont)
    txt.append(tx)
    tx  = NSMutableAttributedString(string: "\(createdBy)\n\(copyright)\n\(version)\n", attributes: attributesSmallFont)
    txt.append(tx)


    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    //numberFormatter.locale = unitedStatesLocale
    let sizeStr = numberFormatter.string(from: selecFileInfo.size as NSNumber)!

    tx  = NSMutableAttributedString(string: "\(sizeStr) bytes.\n", attributes: attributesMediumFont)
    txt.append(tx)

    tx  = NSMutableAttributedString(string: "\(lineNum) lines total.  ", attributes: attributesMediumFont)
    txt.append(tx)
    tx  = NSMutableAttributedString(string: "\(nCommentLine) comment lines.  ", attributes: attributesSmallFont)
    txt.append(tx)
    tx  = NSMutableAttributedString(string: "\(nBlankLine) blank lines.\n", attributes: attributesSmallFont)
    txt.append(tx)
    tx  = NSMutableAttributedString(string: "\(nCodeLine) lines of code.  ", attributes: attributesMediumFont)
    txt.append(tx)
    tx  = NSMutableAttributedString(string: "\(nTrailing) with trailing comments.\n", attributes: attributesSmallFont)
    txt.append(tx)
    //print()

    tx = showLineItems(name: "Import", items: imports)
    //print(tx.string)
    txt.append(tx)

    let printOrder = [BlockType.Enum.rawValue,
                      BlockType.Struct.rawValue,
                      BlockType.isProtocol.rawValue,
                      BlockType.Class.rawValue,
                      BlockType.Extension.rawValue,
                      BlockType.Override_Func.rawValue,
                      BlockType.IBAction_Func.rawValue,
                      BlockType.Func.rawValue,
                      BlockType.None.rawValue]

    if blockTypes.count != printOrder.count {           // Error Check
        print("⛔️ Error - \(blockTypes.count) blockTypes,  but \(printOrder.count) items in printOrder")
    }

    // for each named blockType, show the list of blocks in printOrder
    for i in 0..<blockTypes.count - 1 {
        let b = blockTypes[printOrder[i]]
        tx = showNamedBlock(name: b.displayName, blockType: b.blockType, list: codeElements)
        print(tx.string)
        if b.showNone || b.count > 0 {txt.append(tx)}
    }

    if curlyDepth != 0 {                                // Error Check
        print("😡⛔️😡 Error: Final Curly-Depth = \(curlyDepth) 😡⛔️😡")
    }

    print(codeElements.count, " named blocks")          // Sanity Check
    for c in codeElements {
        let i = Int(c.blockType.rawValue)
        let cType = ("\(c.blockType)" + "        ").left(14)
        print("# \(c.lineNum),\t\(c.numLines) lines, \t\(cType)\t\(c.name)  \(c.extra)  \(i)")
    }
    print()
    return txt
}//end func analyseSwiftFile
