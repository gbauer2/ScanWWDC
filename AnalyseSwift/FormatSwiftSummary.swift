//
//  FormatSwiftSummary.swift
//  AnalyseSwiftCode
//
//  Created by George Bauer on 5/3/19.
//  Copyright © 2019 George Bauer. All rights reserved.
//

import Cocoa

struct SwiftSumAttStr {
    var completeAttText = NSMutableAttributedString()
    let fontMonoDigitLarge  = NSFont.monospacedDigitSystemFont(ofSize: 18, weight: NSFont.Weight.medium)
    let fontMonoDigitMedium = NSFont.monospacedDigitSystemFont(ofSize: 15, weight: NSFont.Weight.medium)
    let fontLineTotal       = NSFont.monospacedDigitSystemFont(ofSize: 13, weight: NSFont.Weight.medium)
    let fontNormal          = NSFont.systemFont(ofSize: 14)
    let fontSmall           = NSFont.systemFont(ofSize: 12)

    init(swiftSummary: SwiftSummary, fileInfo: FileAttributes, issuesFirst: Bool) {   // 21-51 = 40-lines
        completeAttText = NSMutableAttributedString(string: "")

        // Display Tab-stop ruler & fonts
        if gDebug != gDebug {
            let txt:NSMutableAttributedString = NSMutableAttributedString(string: "")
            let paragraphStyleTest = NSMutableParagraphStyle()
            let tabStop0 = NSTextTab(textAlignment: .left, location: 0)
            paragraphStyleTest.tabStops = [ tabStop0 ]
            for i in 1...5 {
                let tabStop = NSTextTab(textAlignment: .left, location: CGFloat(i*100))
                paragraphStyleTest.addTabStop(tabStop)
            }
            var str  = "|0\t|100\t|200\t|300\t|400\t|500\n"
            var atts: [NSAttributedString.Key: Any]
            atts = [.font: fontSmall, .paragraphStyle: paragraphStyleTest]
            txt.append(NSMutableAttributedString(string: str, attributes: atts))
            str = "14 Mono\tMed.\t111111\t999999\t111111\t999999\n"
            atts = [.font: NSFont.monospacedDigitSystemFont(ofSize: 14, weight: NSFont.Weight.medium), .paragraphStyle: paragraphStyleTest]
            txt.append(NSMutableAttributedString(string: str, attributes: atts))
            str = "14 Mono\tLight.\t111111\t999999\t111111\t999999\n"
            atts = [.font: NSFont.monospacedDigitSystemFont(ofSize: 14, weight: NSFont.Weight.light), .paragraphStyle: paragraphStyleTest]
            txt.append(NSMutableAttributedString(string: str, attributes: atts))
            str = "14 System\t\t111111\t999999\t111111\t999999\n"
            atts = [.font: fontNormal, .paragraphStyle: paragraphStyleTest]
            txt.append(NSMutableAttributedString(string: str, attributes: atts))
            self.completeAttText.append(txt)
        }
        if issuesFirst {
            self.completeAttText.append(showIssues(swiftSummary: swiftSummary, fileInfo: fileInfo))

            let blankLines = max(0, 25 - swiftSummary.totalIssues -  2 * swiftSummary.issueCatsCount)
            let str = String.init(repeating: "\n", count: blankLines) + "-------------------------------------------------------------------------\n"
            self.completeAttText.append(NSMutableAttributedString(string: str, attributes: [NSAttributedString.Key.font: fontMonoDigitMedium]))

            self.completeAttText.append(showSummary(swiftSummary: swiftSummary, fileInfo: fileInfo))
        } else {
            self.completeAttText.append(showSummary(swiftSummary: swiftSummary, fileInfo: fileInfo))
            self.completeAttText.append(showIssues(swiftSummary: swiftSummary, fileInfo: fileInfo))
        }
    }//end init

    func showSummary(swiftSummary: SwiftSummary, fileInfo: FileAttributes) -> NSMutableAttributedString { // 54-163 = 109-lines
        var tx: NSMutableAttributedString = NSMutableAttributedString(string: "")
        let txt:NSMutableAttributedString = NSMutableAttributedString(string: "")
        let attributesSmallFont = [NSAttributedString.Key.font: fontSmall]
        if gTrace != .none {
            print("🔷 formatSwiftSummary #\(#line) \(fileInfo.name)")
        }

        // Set the Fonts

        var str = ""

        // MARK:- --- Show Summary ---

        // MARK: Name & OS
        // Print File Name LargeFont
        str = "\n\(fileInfo.name)   \(swiftSummary.viewController)"
        let attributesLargeFont  = [NSAttributedString.Key.font: fontMonoDigitLarge]
        txt.append(NSMutableAttributedString(string: str, attributes: attributesLargeFont))

        // Print the OS LargeFont
        if swiftSummary.projectType == ProjectType.OSX {
            str = " (Mac OSX)\n"
        } else if swiftSummary.projectType == ProjectType.iOS {
            str = " (iOS)\n"
        } else {
            str = "\n"
        }
        txt.append(NSMutableAttributedString(string: str, attributes: [NSAttributedString.Key.font: fontMonoDigitMedium]))

        //MARK: Dates & Copyright
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
        txt.append(NSMutableAttributedString(string: str, attributes: [NSAttributedString.Key.font: fontMonoDigitMedium]))

        //MARK: Line Totals
        txt.append(showLineCount(count: swiftSummary.totalLineCount,   name: "lines total.\n", font: fontLineTotal))
        txt.append(showLineCount(count: swiftSummary.codeLineCount,    name: "lines of code.", font: fontLineTotal))
        str = "    \(swiftSummary.nTrailing) with trailing comments."
        txt.append(NSMutableAttributedString(string: str, attributes: attributesSmallFont))
        if swiftSummary.nEmbedded > 0 {
            str = "   \(swiftSummary.nEmbedded) with embedded comments.\n"
        } else {
            str = "\n"
        }
        txt.append(NSMutableAttributedString(string: str, attributes: attributesSmallFont))
        txt.append(showLineCount(count: swiftSummary.blankLineCount,   name: "blank lines.\n", font: fontLineTotal))
        txt.append(showLineCount(count: swiftSummary.commentLineCount, name: "comment lines.\n", font: fontLineTotal))
        if swiftSummary.markupLineCount > 0 {
            txt.append(showLineCount(count: swiftSummary.markupLineCount, name: "markup lines.\n", font: fontLineTotal))
        }
        if swiftSummary.continueLineCount > 0 {
            txt.append(showLineCount(count: swiftSummary.continueLineCount, name: "continuation lines.\n",
                                     font: fontLineTotal))
        }
        if swiftSummary.compoundLineCount > 0 {
            txt.append(showLineCount(count: -swiftSummary.compoundLineCount, name: "from compound lines.\n",
                                     font: fontLineTotal))
        }

        // MARK: Imports
        // Print Imports
        //swiftSummary.importNames = swiftSummary.imports.map { $0.name }
        tx = showLineItems(title: "Import", items: swiftSummary.imports)
        txt.append(tx)

        // MARK: Blocks
        let printOrder = [BlockType.Enum.rawValue,
                          BlockType.Struct.rawValue,
                          BlockType.isProtocol.rawValue,
                          BlockType.Class.rawValue,
                          BlockType.Extension.rawValue,
                          BlockType.isOverride.rawValue,
                          BlockType.IBAction.rawValue,
                          BlockType.Func.rawValue,
                          BlockType.None.rawValue]

        if blockTypes.count != printOrder.count {           // Error Check
            print("⛔️ Error formatSwiftSummary #\(#line) - \(blockTypes.count) blockTypes,  but \(printOrder.count) items in printOrder")
        }

        // foreach named blockType, show the list of blocks in printOrder
        for i in 0..<blockTypes.count - 1 {
            let blkType = blockTypes[printOrder[i]]
            if blkType.showNone || blkType.total > 0 {
                tx = showNamedBlock(title: blkType.displayName, blockType: blkType.blockType, list: namedBlocks)
                if gDebug == .all { print(tx.string) }
                txt.append(tx)
            }
        }

        return (txt)
    }

    //MARK:- --- Show Issues ---

    func showIssues(swiftSummary: SwiftSummary, fileInfo: FileAttributes) -> NSMutableAttributedString  { //167-225 = 58-lines
        var tx: NSMutableAttributedString = NSMutableAttributedString(string: "")
        let txt:NSMutableAttributedString = NSMutableAttributedString(string: "")
        let issuesTitle: String
        if swiftSummary.totalIssues == 0 {
            issuesTitle = fileInfo.name + " - No Issues"
        } else {
            issuesTitle = "\(fileInfo.name) - \(swiftSummary.totalIssues) Possible Issues"
        }

        tx = showDivider(title: issuesTitle, font: fontMonoDigitMedium)
        txt.append(tx)

        // MARK: File too big.
        if swiftSummary.massiveFile > 0 {
            tx = showIssue("\(swiftSummary.fileName) at \(swiftSummary.codeLineCount) code lines, is too big. (>\(CodeRule.maxFileCodeLines))")
            txt.append(tx)
        }

        // MARK: Funcs too big.
        if !swiftSummary.massiveFuncs.isEmpty {
            let title = "Massive funcs"
            //tx = showNamedBlock(title: title, blockType: blkType.blockType, list: namedBlocks)
            if gDebug == .all { print(tx.string) }
            //txt.append(tx)
        }

        for massiveFunc in swiftSummary.massiveFuncs {
            tx = showIssue("func \"\(massiveFunc.name)()\" at \(massiveFunc.codeLineCount) code lines, is too big. (>\(CodeRule.maxFuncCodeLines))")
            txt.append(tx)
        }

        // MARK: non-camelCased variables
        if gDebug == .all { print("\n\n😡 \(fileInfo.name)\t\t\(fileInfo.modificationDate!.ToString("MM-dd-yyyy hh:mm"))")}
        if !swiftSummary.nonCamelVars.isEmpty {
            if gDebug == .all { print("\n😡 \(swiftSummary.nonCamelVars.count) non-CamelCased variables")}
            for nonCamel in swiftSummary.nonCamelVars {
                if gDebug == .all { print("😡 line \(nonCamel.lineNum): \(nonCamel.name)")}
            }
            if gDebug == .all {print()}
            tx = showLineItems(title: "Non-CamelCased Var", items: swiftSummary.nonCamelVars)
            txt.append(tx)
        }

        // MARK: forced unwraps
        if gDebug == .all { print("\n\n😡 \(fileInfo.name)\t\t\(fileInfo.modificationDate!.ToString("MM-dd-yyyy hh:mm"))") }
        if !swiftSummary.forceUnwraps.isEmpty {
            if gDebug == .all {print("\n😡 \(swiftSummary.forceUnwraps.count) non-forceCased variables")}
            for forceUnwrap in swiftSummary.forceUnwraps {
                if gDebug == .all {print("😡 line \(forceUnwrap.lineNum): \(forceUnwrap.name)")}
            }
            if gDebug == .all {print()}
            tx = showLineItems(title: "Forced Unwrap", items: swiftSummary.forceUnwraps)
            txt.append(tx)
        }

        // MARK: VBCompatability calls
        if !swiftSummary.vbCompatCalls.isEmpty {
            tx = showBadCalls(title: "VBCompatability", calls: swiftSummary.vbCompatCalls)
            txt.append(tx)
        }

        return (txt)
    }

    //MARK:- --- Attrubuted String funcs ---

    public func showDivider(title: String, font: NSFont) -> NSMutableAttributedString {
        let str = "\n------------------- \(title) -------------------\n"
        let atts = [NSAttributedString.Key.font: font]
        let nsAttTxt = NSMutableAttributedString(string: str, attributes: atts)
        return nsAttTxt
    }

    func showLineCount(count: Int, name: String, font: NSFont) -> NSMutableAttributedString {
        let paragraphStyleA2 = NSMutableParagraphStyle()
        paragraphStyleA2.tabStops = [
            NSTextTab(textAlignment: .left,  location: 0),
            NSTextTab(textAlignment: .right, location: 42),    // rt edge of Count
            NSTextTab(textAlignment: .left,  location: 46),    // name
        ]
        let str = "\t\(count)\t\(name)"
        let atts = [NSAttributedString.Key.font: font, NSAttributedString.Key.paragraphStyle: paragraphStyleA2]
        let nsAttTxt = NSMutableAttributedString(string: str, attributes: atts)
        return nsAttTxt
    }

    public func showIssue(_ text: String) -> NSMutableAttributedString {
        let str = "\(text)\n"
        let atts =  [NSAttributedString.Key.font: fontNormal]
        let nsAttTxt = NSMutableAttributedString(string: str, attributes: atts)
        return nsAttTxt
    }

    func setLineItemTabs() -> [NSTextTab]{
        return [
            NSTextTab(textAlignment: .left,  location: 0),
            NSTextTab(textAlignment: .right, location: 50),     // rt edge of 1st number (# of lines)
            NSTextTab(textAlignment: .left,  location: 52),     // "@ line #"
            NSTextTab(textAlignment: .right, location: 150),    // rt edge of LineNumber
            NSTextTab(textAlignment: .left,  location: 170),    // name
            NSTextTab(textAlignment: .left,  location: 250),    // start of xtra column
            NSTextTab(textAlignment: .left,  location: 290),    // start of xtra column
            NSTextTab(textAlignment: .left,  location: 330)     // start of xtra column
        ]
    }

    // Returns NSMutableAttributedString showing title, followed by list of items (line#, name, extra)
    public func showBadCalls(title: String, calls: [String: LineItem]) -> NSMutableAttributedString {
        let paragraphStyleA2 = NSMutableParagraphStyle()
        paragraphStyleA2.tabStops = setLineItemTabs()
        let headerAtts = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 17)]

        var total = 0
        for call in calls {
            total += call.value.timesUsed
        }//next call

        // 10 VBCompatability funcs called for a total of 24 calls
        let txt1 = showCount(count: calls.count, name: title + " func", ifZero: "No")
        let txt2 = showCount(count: total, name: "call", ifZero: "No")
        let txt = "\n" + txt1 + " called, for a total of " + txt2 + ":\n"
        let nsAttTxt = NSMutableAttributedString(string: txt, attributes: headerAtts)

        for call in calls.sorted(by: {$0.key < $1.key}) {
            let str = call.value.description + "\n"
            let nsAttTx = NSAttributedString(string: str, attributes: [NSAttributedString.Key.font: fontNormal, NSAttributedString.Key.paragraphStyle: paragraphStyleA2])
            nsAttTxt.append(nsAttTx)
        }//next call
        return nsAttTxt
    }//end func

    // Returns NSMutableAttributedString showing title, followed by list ("@ line #", line#, name, extra)
    public func showLineItems(title: String, items: [LineItem]) -> NSMutableAttributedString {
        let paragraphStyleA2 = NSMutableParagraphStyle()
        paragraphStyleA2.tabStops = setLineItemTabs()
        let headerAtts = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 17)]

        let txt = "\n" + showCount(count: items.count, name: title, ifZero: "No") + ":\n"
        let nsAttTxt = NSMutableAttributedString(string: txt, attributes: headerAtts)

        for item in items {
            let str = item.description + "\n"
            let nsAttTx = NSAttributedString(string: str, attributes: [
                NSAttributedString.Key.font: fontNormal,
                NSAttributedString.Key.paragraphStyle: paragraphStyleA2])
            nsAttTxt.append(nsAttTx)
        }
        return nsAttTxt
    }//end func

    // Returns NSMutableAttributedString showing a title, followed by list of items (codelineCount,line#, name, extra)
    public func showNamedBlock(title: String, blockType: BlockType, list: [BlockInfo]) -> NSMutableAttributedString {
        let items = list.filter { $0.blockType == blockType }   // Filter for only this blockType
        let paragraphStyleA2 = NSMutableParagraphStyle()
        paragraphStyleA2.tabStops = setLineItemTabs()

        let headerAtts = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 18)]
        let txt = "\n" + showCount(count: items.count, name: title, ifZero: "No") + ":\n"
        let nsAttTxt = NSMutableAttributedString(string: txt, attributes: headerAtts)

        let bodyAtts = [NSAttributedString.Key.font: fontNormal,
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
    }//end func
}//end struct SwiftSumAttStr
