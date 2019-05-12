//
//  FormatSwiftSummary.swift
//  AnalyseSwiftCode
//
//  Created by George Bauer on 5/3/19.
//  Copyright © 2019 George Bauer. All rights reserved.
//

import Cocoa

public func formatSwiftSummary(swiftSummary: SwiftSummary,
                               fileInfo:     FileAttributes,
                               deBug:        Bool = true)    -> NSAttributedString  {
    var tx: NSMutableAttributedString = NSMutableAttributedString(string: "")
    let txt:NSMutableAttributedString = NSMutableAttributedString(string: "")

    if deBug {print()}

    // Set the Tab-stops
    let tabInterval: CGFloat = 100.0
    var tabStop0 = NSTextTab(textAlignment: .left, location: 0)
    paragraphStyleA1.tabStops = [ tabStop0 ]
    for i in 0...7 {
        tabStop0 = NSTextTab(textAlignment: .left, location: tabInterval * CGFloat(i))
        paragraphStyleA1.addTabStop(tabStop0)
    }

    // Set the Fonts
    let attributesLargeFont  = [
        NSAttributedString.Key.font: NSFont.monospacedDigitSystemFont(ofSize: 18, weight: NSFont.Weight.medium)]
    let attributesMediumFont = [
        NSAttributedString.Key.font: NSFont.monospacedDigitSystemFont(ofSize: 15, weight: NSFont.Weight.medium)]
    let attributesSmallFont  = [
        NSAttributedString.Key.font: NSFont.systemFont(ofSize: 12),
        NSAttributedString.Key.paragraphStyle: paragraphStyleA1]

    var str = ""

    // Test the Tabs
    str  = "|0\t|100\t|200\t|300\t|400\t|500\n"
    txt.append(NSMutableAttributedString(string: str, attributes: attributesSmallFont))

    // Print the OS LargeFont
    if swiftSummary.projectType == ProjectType.OSX {
        str = "Mac OSX  "
    } else if swiftSummary.projectType == ProjectType.iOS {
        str = "iOS    "
    }
    txt.append(NSMutableAttributedString(string: str, attributes: attributesMediumFont))

    // Print File Name LargeFont
    str = "\(fileInfo.name)   \(swiftSummary.viewController)\n"
    txt.append(NSMutableAttributedString(string: str, attributes: attributesLargeFont))

    // Print dateCreated, dateModified, createdBy, copyright, version SmallFont
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    let dateCreated = dateFormatter.string(from: (fileInfo.creationDate ?? Date.distantPast))

    dateFormatter.timeStyle = .short
    let dateModified = dateFormatter.string(from: (fileInfo.modificationDate ?? Date.distantPast))

    str = "created: \(dateCreated)     modified: \(dateModified)\n"
    txt.append(NSMutableAttributedString(string: str, attributes: attributesSmallFont))
    str = "\(swiftSummary.createdBy)\n\(swiftSummary.copyright)\n\(swiftSummary.version)\n"
    txt.append(NSMutableAttributedString(string: str, attributes: attributesSmallFont))

    // Print FileSize & various line counts.
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    let sizeStr = numberFormatter.string(from: fileInfo.size as NSNumber) ?? "???"
    str = "\(sizeStr) bytes.\n"
    txt.append(NSMutableAttributedString(string: str, attributes: attributesMediumFont))

    let ww = 5
    str = "\(swiftSummary.totalLineCount.rtj(ww)) lines total.  "
    txt.append(NSMutableAttributedString(string: str, attributes: attributesMediumFont))
    str = "\(swiftSummary.commentLineCount) comment lines.  "
    txt.append(NSMutableAttributedString(string: str, attributes: attributesSmallFont))
    str = "\(swiftSummary.blankLineCount) blank lines.\n"
    txt.append(NSMutableAttributedString(string: str, attributes: attributesSmallFont))

    str = "\(swiftSummary.codeLineCount.rtj(ww)) lines of code.  "
    txt.append(NSMutableAttributedString(string: str, attributes: attributesMediumFont))
    str = "\(swiftSummary.nTrailing) with trailing comments.  "
    txt.append(NSMutableAttributedString(string: str, attributes: attributesSmallFont))
    str = "\(swiftSummary.nEmbedded) with embedded comments.\n"
    txt.append(NSMutableAttributedString(string: str, attributes: attributesSmallFont))

    if swiftSummary.continueLineCount > 0 {
        str = "\(swiftSummary.continueLineCount.rtj(ww)) continuation lines.\n"
        txt.append(NSMutableAttributedString(string: str, attributes: attributesMediumFont))
    }
    if swiftSummary.compoundLineCount > 0 {
        let negCompound = -swiftSummary.compoundLineCount
        str = "\(negCompound.rtj(ww)) from compound lines.\n"
        txt.append(NSMutableAttributedString(string: str, attributes: attributesMediumFont))
    }

    // Print Imports
    //swiftSummary.importNames = swiftSummary.imports.map { $0.name }
    tx = showLineItems(name: "Import", items: swiftSummary.imports)
    txt.append(tx)

    let printOrder = [BlockType.Enum.rawValue,
                      BlockType.Struct.rawValue,
                      BlockType.isProtocol.rawValue,
                      BlockType.Class.rawValue,
                      BlockType.Extension.rawValue,
                      BlockType.OverrideFunc.rawValue,
                      BlockType.IBActionFunc.rawValue,
                      BlockType.Func.rawValue,
                      BlockType.None.rawValue]

    if blockTypes.count != printOrder.count {           // Error Check
        print("⛔️ Error formatSwiftSummary #\(#line) - \(blockTypes.count) blockTypes,  but \(printOrder.count) items in printOrder")
    }

    // foreach named blockType, show the list of blocks in printOrder
    for i in 0..<blockTypes.count - 1 {
        let blkType = blockTypes[printOrder[i]]
        if blkType.showNone || blkType.count > 0 {
            tx = showNamedBlock(name: blkType.displayName, blockType: blkType.blockType, list: codeElements)
            if deBug { print(tx.string) }
            txt.append(tx)
        }
    }

    //MARK: Show Issues

    let issuesTitle: String
    let totalIssueCount = swiftSummary.nonCamelVars.count + swiftSummary.forceUnwraps.count +
                        swiftSummary.totalVbCount + swiftSummary.massiveFile + swiftSummary.massiveFuncs.count
    if totalIssueCount == 0 {
        issuesTitle = fileInfo.name + " - No Issues"
    } else {
        issuesTitle = "\(fileInfo.name) - \(totalIssueCount) Possible Issues"
    }

    tx = showDivider(title: issuesTitle)
    txt.append(tx)

    // print File too big
    if swiftSummary.massiveFile > 0 {
        tx = showIssue("\(swiftSummary.fileName) at \(swiftSummary.codeLineCount) code lines, is too big. (>\(CodeRule.maxFileCodeLines))")
        txt.append(tx)
    }

    // print funcs too big
    for massiveFunc in swiftSummary.massiveFuncs {
        tx = showIssue("func \"\(massiveFunc.name)()\" at \(massiveFunc.codeLineCount) code lines, is too big. (>\(CodeRule.maxFuncCodeLines))")
        txt.append(tx)
    }
    // print non-camelCased variables
    if deBug {print("\n\n😡 \(fileInfo.name)\t\t\(fileInfo.modificationDate!.ToString("MM-dd-yyyy hh:mm"))")}
    if swiftSummary.nonCamelVars.count > 0 {
        if deBug {print("\n😡 \(swiftSummary.nonCamelVars.count) non-CamelCased variables")}
        for nonCamel in swiftSummary.nonCamelVars {
            if deBug {print("😡 line \(nonCamel.lineNum): \(nonCamel.name)")}
        }
        if deBug {print()}
        tx = showLineItems(name: "Non-CamelCased Var", items: swiftSummary.nonCamelVars)
        txt.append(tx)
    }

    // print forced unwraps
    if deBug { print("\n\n😡 \(fileInfo.name)\t\t\(fileInfo.modificationDate!.ToString("MM-dd-yyyy hh:mm"))") }
    if swiftSummary.forceUnwraps.count > 0 {
        if deBug {print("\n😡 \(swiftSummary.forceUnwraps.count) non-forceCased variables")}
        for forceUnwrap in swiftSummary.forceUnwraps {
            if deBug {print("😡 line \(forceUnwrap.lineNum): \(forceUnwrap.name)")}
        }
        if deBug {print()}
        tx = showLineItems(name: "Forced Unwrap", items: swiftSummary.forceUnwraps)
        txt.append(tx)
    }

    // print VBCompatability stuff
    if swiftSummary.totalVbCount > 0 {
        tx = showBadCalls(name: "VBCompatability", total: swiftSummary.totalVbCount, calls: swiftSummary.vbCompatCalls)
        txt.append(tx)
    }

    return (txt)
}

//MARK:- Attrubuted Strings

let paragraphStyleA1 = NSMutableParagraphStyle()    //accessed from showLineItems, showNamedBlock, analyseSwiftFile

public func showDivider(title: String) -> NSMutableAttributedString {
    let str = "\n------------------- \(title) -------------------\n"
    let atts = [NSAttributedString.Key.font: NSFont.monospacedDigitSystemFont(ofSize: 15, weight: NSFont.Weight.medium)]
    let nsAttTxt = NSMutableAttributedString(string: str, attributes: atts)
    return nsAttTxt
}

public func showIssue(_ text: String) -> NSMutableAttributedString {
    let str = "\(text)\n"
    let atts =  [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 15)]
    let nsAttTxt = NSMutableAttributedString(string: str, attributes: atts)
    return nsAttTxt
}

// Returns NSMutableAttributedString showing name as a title, followed by list of items (line#, name, extra)
public func showBadCalls(name: String, total: Int, calls: [String: Int]) -> NSMutableAttributedString {
    let paragraphStyleA2 = NSMutableParagraphStyle()
    paragraphStyleA2.tabStops = [
        NSTextTab(textAlignment: .left,  location: 0),
        NSTextTab(textAlignment: .left,  location: 40),     // func name
        NSTextTab(textAlignment: .right, location: 170),    // rt edge of LineNumber
        NSTextTab(textAlignment: .left,  location: 175),    // name
        NSTextTab(textAlignment: .left,  location: 225),    // start of xtra column
        NSTextTab(textAlignment: .left,  location: 275),    // start of xtra column
        NSTextTab(textAlignment: .left,  location: 325)     // start of xtra column
    ]
    let headerAtts = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 17)]

    // 10 VBCompatability funcs called for a total of 24 calls
    let txt1 = showCount(count: calls.count, name: name + " func", ifZero: "No")
    let txt2 = showCount(count: total, name: "call", ifZero: "No")
    let txt = "\n" + txt1 + " called, for a total of " + txt2 + ":\n"
    let nsAttTxt = NSMutableAttributedString(string: txt, attributes: headerAtts)

    for call in calls.sorted(by: {$0.key < $1.key}) {
        let ess = call.value == 1 ? " " : "s"
        let str = "\t\(call.key)\t\(call.value)\ttime\(ess)\n"
        let nsAttTx = NSAttributedString(string: str, attributes: [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 14), NSAttributedString.Key.paragraphStyle: paragraphStyleA2])
        nsAttTxt.append(nsAttTx)
    }
    return nsAttTxt
}

// Returns NSMutableAttributedString showing name as a title, followed by list of items (line#, name, extra)
public func showLineItems(name: String, items: [LineItem]) -> NSMutableAttributedString {
    let paragraphStyleA2 = NSMutableParagraphStyle()
    paragraphStyleA2.tabStops = [
        NSTextTab(textAlignment: .left,  location: 0),
        NSTextTab(textAlignment: .left,  location: 52),     // "@ line #"
        NSTextTab(textAlignment: .right, location: 150),    // rt edge of LineNumber
        NSTextTab(textAlignment: .left,  location: 170),    // name
        NSTextTab(textAlignment: .left,  location: 250),    // start of xtra column
        NSTextTab(textAlignment: .left,  location: 290),    // start of xtra column
        NSTextTab(textAlignment: .left,  location: 330)     // start of xtra column
    ]
    let headerAtts = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 17)]

    let txt = "\n" + showCount(count: items.count, name: name, ifZero: "No") + ":\n"
    let nsAttTxt = NSMutableAttributedString(string: txt, attributes: headerAtts)

    for item in items {
        var str = ""
        if item.lineNum != 0 {
            str = "\t@ line #\t\(formatInt(item.lineNum, wid: 8))\t\(item.name)"
        } else {
            str = "\t\(item.name)"
        }
        if !item.extra.isEmpty {
            str += "\t\(item.extra)"
        }
        str += "\n"
        let nsAttTx = NSAttributedString(string: str, attributes: [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 14), NSAttributedString.Key.paragraphStyle: paragraphStyleA2])
        nsAttTxt.append(nsAttTx)
    }
    return nsAttTxt
}

// Returns NSMutableAttributedString showing name as a title, followed by list of items (codelineCount,line#, name, extra)
public func showNamedBlock(name: String, blockType: BlockType, list: [BlockInfo]) -> NSMutableAttributedString {
    let items = list.filter { $0.blockType == blockType }   // Filter for only this blockType
    let paragraphStyleA2 = NSMutableParagraphStyle()
    paragraphStyleA2.tabStops = [
        NSTextTab(textAlignment: .left,  location: 0),
        NSTextTab(textAlignment: .right, location: 50),     // rt edge of 1st number (# of lines)
        NSTextTab(textAlignment: .left,  location: 52),     // "lines @"
        NSTextTab(textAlignment: .right, location: 150),    // rt edge of 2nd number (LineNum)
        NSTextTab(textAlignment: .left,  location: 170),    // start of last column
    ]

    let headerAtts = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 18),
                      NSAttributedString.Key.paragraphStyle: paragraphStyleA1]
    let txt = "\n" + showCount(count: items.count, name: name, ifZero: "No") + ":\n"
    let nsAttTxt = NSMutableAttributedString(string: txt, attributes: headerAtts)

    let bodyAtts = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 14),
                NSAttributedString.Key.paragraphStyle: paragraphStyleA2]
    for item in items {
        let ess = item.codeLineCount == 1 ? " " : "s"
        var str = "\t\(item.codeLineCount)\t line\(ess) @\t\(item.lineNum) \t\(item.name)"
        if !item.extra.isEmpty { str += "  (\(item.extra) )" }
        str += "\n"
        let nsAttTx = NSAttributedString(string: str, attributes: bodyAtts)
        nsAttTxt.append(nsAttTx)
    }
    return nsAttTxt
}

extension Int {
    // right-justify Int - see showNamedBlock to see how it should be done
    func rtj(_ width: Int, zero: String = "0" ) -> String {
        let str: String
        if self == 0 {
            str = zero
        } else {
            str = String(self)
        }
        return str.PadLeft(width)
    }//end func
}//end extension Int
