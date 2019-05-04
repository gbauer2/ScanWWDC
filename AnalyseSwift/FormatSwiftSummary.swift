//
//  FormatSwiftSummary.swift
//  AnalyseSwiftCode
//
//  Created by George Bauer on 5/3/19.
//  Copyright © 2019 George Bauer. All rights reserved.
//

import Cocoa

public func formatSwiftSummary(swiftSummary: SwiftSummary, selecFileInfo: FileAttributes, deBug: Bool = true) ->  NSAttributedString  {

    var tx: NSMutableAttributedString = NSMutableAttributedString(string: "")
    let txt:NSMutableAttributedString = NSMutableAttributedString(string: "")

    if deBug {print()}

    // Set the Tab-stops
    let tabInterval: CGFloat = 100.0
    var tabStop0 = NSTextTab(textAlignment: .left, location: 0)
    paragraphStyleA1.tabStops = [ tabStop0 ]
    for i in 1...8 {
        tabStop0 = NSTextTab(textAlignment: .left, location: tabInterval * CGFloat(i))
        paragraphStyleA1.addTabStop(tabStop0)
    }

    // Set the Fonts
    let attributesLargeFont  = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 20), NSAttributedString.Key.paragraphStyle: paragraphStyleA1]
    let attributesMediumFont = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 16), NSAttributedString.Key.paragraphStyle: paragraphStyleA1]
    let attributesSmallFont  = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 12), NSAttributedString.Key.paragraphStyle: paragraphStyleA1]

    // Test the Tabs
    tx  = NSMutableAttributedString(string: "\t1\t2\t3\t4\t5\n", attributes: attributesSmallFont)
    txt.append(tx)

    // Print the OS
    if swiftSummary.projectType == ProjectType.OSX {
        tx = NSMutableAttributedString(string: "Mac OSX  ", attributes: attributesLargeFont)
        txt.append(tx)
    } else if swiftSummary.projectType == ProjectType.iOS {
        tx = NSMutableAttributedString(string: "iOS    ", attributes: attributesLargeFont)
        txt.append(tx)
    }

    // Print File Name
    tx  = NSMutableAttributedString(string: "\(selecFileInfo.name)   \(swiftSummary.viewController)\n", attributes: attributesLargeFont)
    txt.append(tx)

    // Print dateCreated, dateModified, createdBy, copyright, version
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    let dateCreated = dateFormatter.string(from: (selecFileInfo.creationDate ?? Date.distantPast))

    dateFormatter.timeStyle = .short
    let dateModified = dateFormatter.string(from: (selecFileInfo.modificationDate ?? Date.distantPast))

    tx  = NSMutableAttributedString(string: "created: \(dateCreated)     modified: \(dateModified)\n", attributes: attributesSmallFont)
    txt.append(tx)
    tx  = NSMutableAttributedString(string: "\(swiftSummary.createdBy)\n\(swiftSummary.copyright)\n\(swiftSummary.version)\n", attributes: attributesSmallFont)
    txt.append(tx)

    // Print FileSize & various line counts.
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    let sizeStr = numberFormatter.string(from: selecFileInfo.size as NSNumber) ?? ""

    tx  = NSMutableAttributedString(string: "\(sizeStr) bytes.\n", attributes: attributesMediumFont)
    txt.append(tx)

    tx  = NSMutableAttributedString(string: "\(swiftSummary.totalLineCount) lines total.  ", attributes: attributesMediumFont)
    txt.append(tx)
    tx  = NSMutableAttributedString(string: "\(swiftSummary.nCommentLine) comment lines.  ", attributes: attributesSmallFont)
    txt.append(tx)
    tx  = NSMutableAttributedString(string: "\(swiftSummary.nBlankLine) blank lines.\n", attributes: attributesSmallFont)
    txt.append(tx)
    tx  = NSMutableAttributedString(string: "\(swiftSummary.nCodeLine) lines of code.  ", attributes: attributesMediumFont)
    txt.append(tx)
    tx  = NSMutableAttributedString(string: "\(swiftSummary.nTrailing) with trailing comments.  ", attributes: attributesSmallFont)
    txt.append(tx)
    tx  = NSMutableAttributedString(string: "\(swiftSummary.nEmbedded) with embedded comments.\n", attributes: attributesSmallFont)
    txt.append(tx)
    //if deBug {print()}

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
        print("⛔️ Error AnalyseSwift.swift #\(#line) - \(blockTypes.count) blockTypes,  but \(printOrder.count) items in printOrder")
    }

    // foreach named blockType, show the list of blocks in printOrder
    for i in 0..<blockTypes.count - 1 {
        let blkType = blockTypes[printOrder[i]]
        tx = showNamedBlock(name: blkType.displayName, blockType: blkType.blockType, list: codeElements)
        if deBug {print(tx.string)}
        if blkType.showNone || blkType.count > 0 {txt.append(tx)}
    }

    //MARK: Show Issues

    let issuesTitle: String
    let totalIssueCount = swiftSummary.nonCamelVars.count + swiftSummary.forceUnwraps.count +
        swiftSummary.nVBwords + swiftSummary.massiveFile + swiftSummary.massiveFuncs.count
    if totalIssueCount == 0 {
        issuesTitle = selecFileInfo.name + " - No Issues"
    } else {
        issuesTitle = "\(selecFileInfo.name) - \(totalIssueCount) Possible Issues"
    }
    tx = showDivider(title: issuesTitle)
    txt.append(tx)

    if swiftSummary.massiveFile > 0 {
        tx = showIssue("\(swiftSummary.fileName) at \(swiftSummary.codeLineCount) code lines, is too big. (>\(CodeRule.maxFileCodeLines))")
        txt.append(tx)
    }

    for massiveFunc in swiftSummary.massiveFuncs {
        tx = showIssue("func \"\(massiveFunc.name)()\" at \(massiveFunc.codeLineCount) code lines, is too big. (>\(CodeRule.maxFuncCodeLines))")
        txt.append(tx)
    }
    // print non-camelCased variables
    if deBug {print("\n\n😡 \(selecFileInfo.name)\t\t\(selecFileInfo.modificationDate!.ToString("MM-dd-yyyy hh:mm"))")}
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
    if deBug {print("\n\n😡 \(selecFileInfo.name)\t\t\(selecFileInfo.modificationDate!.ToString("MM-dd-yyyy hh:mm"))")}
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
    if swiftSummary.nVBwords > 0 {
        var vbLineItems = [LineItem]()
        if deBug {print("😡 \(swiftSummary.nUniqueVBWords) unique VBCompatability calls, for a total of \(swiftSummary.nVBwords).")}
        for (key,value) in gDictVBwords.sorted(by: {$0.key < $1.key}) {
            if value > 0 {
                let extra = "\(showCount(count: value, name: "time"))"
                if deBug {print("😡   \(key.PadRight(12)) \(extra)")}
                vbLineItems.append(LineItem(lineNum: 0, name: key, extra: extra))
            }
        }
        if deBug {print("\n")}
        tx = showLineItems(name: "VBCompatability call", items: vbLineItems)
        txt.append(tx)
    }


    return (txt)
}

//MARK:- Attrubuted Strings

let paragraphStyleA1 = NSMutableParagraphStyle()    //accessed from showLineItems, showNamedBlock, analyseSwiftFile

public func showDivider(title: String) -> NSMutableAttributedString {
    let txt = "\n------------------- \(title) -------------------\n"
    let nsAttTxt = NSMutableAttributedString(string: txt, attributes: [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 15), NSAttributedString.Key.paragraphStyle: paragraphStyleA1])
    return nsAttTxt
}

public func showIssue(_ text: String) -> NSMutableAttributedString {
    let txt = "\(text)\n"
    let nsAttTxt = NSMutableAttributedString(string: txt, attributes: [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 15), NSAttributedString.Key.paragraphStyle: paragraphStyleA1])
    return nsAttTxt
}

// Returns NSMutableAttributedString showing name as a title, followed by list of items (line#, name, extra)
public func showLineItems(name: String, items: [LineItem]) -> NSMutableAttributedString {

    let txt = "\n" + showCount(count: items.count, name: name, ifZero: "No") + ":\n"
    let nsAttTxt = NSMutableAttributedString(string: txt, attributes: [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 18), NSAttributedString.Key.paragraphStyle: paragraphStyleA1])
    for item in items {
        var tx = ""
        if item.lineNum != 0 {
            tx = "         @ line #\t\(formatInt(item.lineNum, wid: 8))    \t\(item.name)"
        } else {
            tx = "                 \t        \t\(item.name)"
        }
        if !item.extra.isEmpty {
            let nSpaces = max(12 - item.name.count, 0) + 2
            let spaces: String = String(repeating: " ", count: nSpaces)
            tx += "\(spaces)\t\(item.extra)"
        }
        tx += "\n"
        let nsAttTx = NSAttributedString(string: tx, attributes: [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 14), NSAttributedString.Key.paragraphStyle: paragraphStyleA1])
        nsAttTxt.append(nsAttTx)
    }
    return nsAttTxt
}

// Returns NSMutableAttributedString showing name as a title, followed by list of items (line#, name, extra)
public func showNamedBlock(name: String, blockType: BlockType, list: [BlockInfo]) -> NSMutableAttributedString {
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
    let nsAttTxt = NSMutableAttributedString(string: txt, attributes: [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 18), NSAttributedString.Key.paragraphStyle: paragraphStyleA1])
    for item in items {
        var tx = "\t\(formatInt(item.codeLineCount, wid: 5))\t lines @\t\(item.lineNum) \t\(item.name)"
        if !item.extra.isEmpty {tx += "  (\(item.extra) )"}
        tx += "\n"
        let nsAttTx = NSAttributedString(string: tx, attributes: [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 14), NSAttributedString.Key.paragraphStyle: paragraphStyleA2])
        nsAttTxt.append(nsAttTx)
    }
    return nsAttTxt
}
