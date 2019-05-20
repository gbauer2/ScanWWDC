//
//  AnalyseSwift.swift
//  AnalyseSwiftCode
//
//  Created by George Bauer on 1/10/18.
//  Copyright © 2018,2019 George Bauer. All rights reserved.
//

import Cocoa

// MARK: - Properties of analyseSwiftFile (globals - change to instance vars)
fileprivate var curlyDepth  = 0                     //accessed from gotOpenCurly, gotCloseCurly, getSelecFileInfo

fileprivate var blockOnDeck = BlockInfo()       //accessed from analyseSwiftFile, gotOpenCurly,
fileprivate var blockStack  = [BlockInfo]()     //accessed from analyseSwiftFile, gotOpenCurly, gotCloseCurly
public      var namedBlocks = [BlockInfo]()     //accessed from analyseSwiftFile, gotCloseCurly,     FormatSwiftSummary

// Holds the aggregate data for each BlockType  //accessed from analyseSwiftFile, needsContinuation, FormatSwiftSummary
var blockTypes = [
BlockAggregate(blockType: .None,       codeName: "",          displayName: "unNamed",       showNone: false, total: 0),
BlockAggregate(blockType: .Func,       codeName: "func",      displayName: "Regular func",  showNone: true,  total: 0),
BlockAggregate(blockType: .IBAction,   codeName: "IBAction",  displayName: "IBAction func", showNone: false, total: 0),
BlockAggregate(blockType: .isOverride, codeName: "override",  displayName: "Override func", showNone: false, total: 0),
BlockAggregate(blockType: .Struct,     codeName: "struct",    displayName: "Struct",        showNone: false, total: 0),
BlockAggregate(blockType: .Enum,       codeName: "enum",      displayName: "Enum",          showNone: false, total: 0),
BlockAggregate(blockType: .Extension,  codeName: "extension", displayName: "Extension",     showNone: false, total: 0),
BlockAggregate(blockType: .Class,      codeName: "class",     displayName: "Class",         showNone: true,  total: 0),
BlockAggregate(blockType: .isProtocol, codeName: "protocol",  displayName: "Protocol",      showNone: false, total: 0)
]


// MARK: - Block Structs & Enums

// Stuff to be returned by AnalyseSwift
public struct SwiftSummary {
    var fileName        = ""
    var copyright       = ""
    var viewController  = ""
    var createdBy       = ""
    var version         = ""
    var projectType     = ProjectType.unknown
    var byteCount       = 0

    var codeLineCount     = 0
    var continueLineCount = 0
    var blankLineCount    = 0
    var commentLineCount  = 0
    var quoteLineCount    = 0
    var markupLineCount   = 0
    var compoundLineCount = 0
    var totalLineCount    = 0

    var imports         = [LineItem]()
    var nTrailing       = 0
    var nEmbedded       = 0

    // issues
    var nonCamelVars    = [LineItem]()          // "@ line #   51   TestTargetID"
    var forceUnwraps    = [LineItem]()          // "@ line #   59   .first!   print(comps.first!)"
    var massiveFuncs    = [FuncInfo]()
    var massiveFile     = 0
    var vbCompatCalls   = [String: LineItem]()  // "VB.Left     3    times"

    var issueCatsCount  = 0         // for display spacing when issuesFirst
    var totalIssues     = 0         // for display spacing when issuesFirst

    var url             = FileManager.default.homeDirectoryForCurrentUser
}//end struct SwiftSummary

internal struct FuncInfo {
    var name          = ""
    var codeLineCount = 0
}

// List of BlockTypes & their index
public enum BlockType: Int {
    case None       = 0
    case Func       = 1
    case IBAction   = 2
    case isOverride = 3
    case Struct     = 4
    case Enum       = 5
    case Extension  = 6
    case Class      = 7
    case isProtocol = 8
}

// Search words, Display directives, Total Count(for display)
internal struct BlockAggregate {
    let blockType:   BlockType
    let codeName:    String
    let displayName: String
    let showNone:    Bool
    var total        = 0
}

// for use in "139 lines@ 104 pbxToXcodeProj xtra"
//Holds Block info for each Block in Stack
public struct BlockInfo {
    var blockType        = BlockType.None
    var lineNum          = 0
    var codeLinesAtStart = 0
    var name             = ""
    var extra            = ""
    var codeLineCount    = 0
}

// for use in "@line# 51 TestTargetID xtra"
public struct LineItem {
    let name:       String
    let lineNum:    Int
    var timesUsed   = 0
    var codeLineCt  = -1
    var extra       = ""
    init(name: String, lineNum: Int) {
        self.name    = name
        self.lineNum = lineNum
    }
    init(name: String, lineNum: Int, extra: String) {
        self.name    = name
        self.lineNum = lineNum
        self.extra   = extra
    }
}

//   |  <codeLineCt>|" line(s) @"|  <lineNum>|  <name>  |  <extra>      // codeLineCt >= 0
//   |            ""|"@ line #"  |  <lineNum>|  <name>  |  <extra>      // codeLineCt <  0, timesUsed == 0
//   |   <timesUsed>|" times"    |         ""|  <name>  |  <extra>      // timesUsed  > 1
//   |             1|" time @"   |  <lineNum>|  <name>  |  <extra>      // timesUsed == 1
//     Mid    2    times

extension LineItem: CustomStringConvertible {
    public var description: String {
        var str = ""
        if timesUsed == 0 {
            str = "\t  \t@ line #\t\(lineNum)\t\(name)"
        } else if timesUsed == 1 {
            str = "\t\(timesUsed)\t time  @\t\(lineNum)\t\(name)"
        } else {
            str = "\t\(timesUsed)\t times\t \t\(name)"
        }

        if !extra.isEmpty {
            str += "\t\(extra)"
        }
        //str += "\n"
        return str
    }
}

internal enum ProjectType {
    case unknown
    case OSX
    case iOS
}

// MARK: - Helper funcs

//---- gotOpenCurly - push "ondeck" onto stack, clear ondeck,  stackedCounter = nCodeLines
private func gotOpenCurly(lineNum: Int) {
    if gTrace == .all { print("\(lineNum) got open curly; depth \(curlyDepth) -> \(curlyDepth+1)") }
    blockStack.insert(blockOnDeck, at: 0)
    blockOnDeck = BlockInfo()
    curlyDepth += 1
}

//---- gotCloseCurly - pop stackedCounter lines4item = nCodeLines - stackedCounter
private func gotCloseCurly(lineNum: Int, nCodeLine: Int) {
    if gTrace == .all {print("\(lineNum) got close curly; depth \(curlyDepth) -> \(curlyDepth-1)")}
    curlyDepth -= 1
    var block = blockStack.remove(at: 0)
    if block.blockType != .None {
        if gDebug == .all {print("#\(#line) \(block.name)")}
        block.codeLineCount = nCodeLine - block.codeLinesAtStart // lineNum - block.lineNum
        namedBlocks.append(block)
    }
}//end func

//---- isCamelCase
// Uses CodeRule
internal func isCamelCase(_ word: String) -> Bool {

    //TODO: Make minimum name length an IssuePreference
    if word == "_"    { return true  }
    if word.count < 2 { return false }

    //Allow AllCaps
    if CodeRule.allowAllCaps {
        var isAllCaps = true
        for char in word {
            if !char.isUppercase {
                if !CodeRule.allowUnderscore || char != "_" {
                    isAllCaps = false
                    break
                }
            }
        }//next
        if isAllCaps { return true }
    }

    // AllCaps not allowed or Not AllCaps
    if  !CodeRule.allowUnderscore && word.contains("_") { return false }

    // AllCaps not allowed and either no underscores or they are allowed
    let firstLetter = word[0]
    if !firstLetter.isLowercase && firstLetter != "_"   { return false }

    return true
}//end func

internal func getParamNames(line: String) -> [String] {
    let open = line.firstIntIndexOf("(")
    if open < 0 {
        print("⛔️ AnalyseSwift.swift #\(#line) Probable line-continuation ('func' with no '(')")
        return []
    }
    let close = line.firstIntIndexOf(")")
    if close < open+1 {
        print("⛔️ AnalyseSwift.swift #\(#line) Probable line-continuation ('func' with no ')')")
        return []
    }
    let paramStr = line.substring(begin: open+1, end: close-1)
    //print("🔹 paramStr for \(line) = \"\(paramStr)\"")
    let paramsWithTypes = paramStr.components(separatedBy: ",").filter { !$0.isEmpty }.map { $0.trim }
    if paramsWithTypes.isEmpty { return [] }

    //print(paramsWithTypes)
    var paramNames = [String]()

    for paramWithType in paramsWithTypes {
        let paramPair = paramWithType.components(separatedBy: ":")[0].trim
        let names = paramPair.components(separatedBy: " ").filter { !$0.isEmpty }.map { $0.trim }
        for name in names {
            paramNames.append(name)
        }//next name
    }//next paramWithType
    return paramNames
}

// Returns true if we need to append the next line onto this line
internal func needsContinuation(codeLineDetail: CodeLineDetail, nextLine: String, lineNum: Int = 0) -> Bool {
    let codeLine = codeLineDetail.codeLine
    if codeLine.isEmpty { return false }
    let lastChar = codeLine.suffix(1)
    let firstCharNextLine = nextLine.prefix(1)

    // Lines ending (or nextline starting) with certain punctuation
    let hangers = ",=+-*&|"      // "/" does not work - might be "//" or "/*"
    if  hangers.contains(lastChar)          { return true }
    if  hangers.contains(firstCharNextLine) { return true }

    if firstCharNextLine == "/" && nextLine.count >= 2 {
        let char2 = nextLine[1]
        if char2 != "/" && char2 != "*" {
            return true
        }
    }

    // Lines with bracketMismatch or parenMismatch
    if codeLineDetail.bracketMismatch > 0 || codeLineDetail.parenMismatch > 0 {
        if "()[]".contains(lastChar) {
            //print("\(lineNum)⬇️ needsContinuation: \(codeLineDetail.parenMismatch) \(codeLineDetail.bracketMismatch) \(codeLine)" )
            return true
        }
        if "()[]".contains(firstCharNextLine) {
            //print("\(lineNum)⬇️ needsContinuation: \(codeLineDetail.parenMismatch) \(codeLineDetail.bracketMismatch) \(codeLine)" )
            return true
        }
        print("⛔️ Error AnalyseSwift.swift #\(#line) - from needsContinuation(): OpenClose Mismatch: Paren excess = \(codeLineDetail.parenMismatch) Bracket exess = \(codeLineDetail.bracketMismatch)" )
        print("  \(lineNum) \(codeLine)\n  \(lineNum+1) \(nextLine)" )
        print()
    }//endif mismatch

    // Lines ending in certain keywords
    for bt in blockTypes {
        let name = bt.codeName
        if name.isEmpty { continue } // ignore "none"
        if name.suffix(4) == codeLine.suffix(4) {
            if codeLine == name || codeLine.hasSuffix(" " + name) {
                print("#\(#line) needsContinuation, source line \(lineNum) \n\(name) \(codeLine) \n\(nextLine)")
                return true
            }
        }
    }
//    if !"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789{}[]()!\"?:;".contains(lastChar) {
//        print("\(codeLine)")
//    }
    return false
}

// MARK: - the main event 444-lines
// called from analyseContentsButtonClicked         //260-704 = 444-lines
public func analyseSwiftFile(contentFromFile: String, selecFileInfo: FileAttributes, deBug: Bool) -> (SwiftSummary) {
    let lines = contentFromFile.components(separatedBy: "\n")
    if gTrace != .none {
        print("🔷 AnalyseSwift.swift #\(#line) Enter AnalyseSwiftFile (\(selecFileInfo.name) \(lines.count) lines)")
    }

    resetVBwords()

    var swiftSummary = SwiftSummary()
    swiftSummary.fileName = selecFileInfo.name
    swiftSummary.url = selecFileInfo.url!

    var blockLookup = [String : Int]()
    for (i, bkTyp) in blockTypes.enumerated() {
        blockTypes[i].total = 0                 // Reset Counter
        blockLookup[bkTyp.codeName] = i         // Set Lookup Name
    }

    curlyDepth   = 0
    blockOnDeck  = BlockInfo()
    blockStack   = []
    namedBlocks = []

    var containerName = ""
    var index        = 0
    var lineNum      = 0

    var inQuote    = false

    var fromPrevLine    = ""    // if prev line had a ";" (Compund Line), this is the excess after 1st ";"
    var partialLine     = ""    // if this is a Continuation Line
    var iLine           = 0

    func recordNonCamelcase(_ name: String) {
        let lineItem = LineItem(name: name, lineNum: lineNum)
        if deBug && gDebug == .all {print("➡️ \(lineItem.lineNum) Non-CamelCased \(lineItem.name)")}
        if swiftSummary.nonCamelVars.isEmpty { swiftSummary.issueCatsCount += 1 }
        swiftSummary.totalIssues += 1
        swiftSummary.nonCamelVars.append(lineItem)
    }

    var codeLineDetail = CodeLineDetail()

    // MARK: Main Loop 300-671 = 371-lines
    while iLine < lines.count {
        //        // Multitasking Check
        //        if selecFileInfo.url != ViewController.latestUrl {
        //            if let latestUrl = ViewController.latestUrl {
        //                //print("😎Working on \(selecFileInfo.url!),\n but \(latestUrl) is now current😎")
        //                //let tx  = NSMutableAttributedString(string: "Abort!")
        //                //return (swiftSummary, tx)
        //            }
        //        }
        var line: String
        if fromPrevLine.isEmpty {       // Read a new line from source
            line = lines[iLine].trim
            iLine += 1
            lineNum += 1
            if line.isEmpty {
                swiftSummary.blankLineCount += 1
                continue
            }
        } else {                        // Still working in a compound line
            line = fromPrevLine.trim
            fromPrevLine = ""
            if line.isEmpty { continue }
            swiftSummary.compoundLineCount += 1
        }

        // Line Continution
        if !partialLine.isEmpty {
            line = partialLine + " " + line
            partialLine = ""
        }

        //------- Sanity Check ------
        let sum = swiftSummary.blankLineCount + swiftSummary.continueLineCount - swiftSummary.compoundLineCount + swiftSummary.commentLineCount + swiftSummary.markupLineCount + swiftSummary.quoteLineCount + swiftSummary.codeLineCount + 1
        if sum != lineNum || iLine != lineNum {
            print("⛔️", lineNum, sum, swiftSummary.blankLineCount, swiftSummary.continueLineCount, -swiftSummary.compoundLineCount, swiftSummary.commentLineCount, swiftSummary.markupLineCount, swiftSummary.quoteLineCount, swiftSummary.codeLineCount )
        }
        //---------------------------

        var netCurlys = 0

        if line.hasPrefix("/*") {                             // "/*"
            if line.hasPrefix("/**") {
                codeLineDetail.inMultiLine = .blockMarkup
            } else {
                codeLineDetail.inMultiLine = .blockComment
            }
        } else if line.hasPrefix("*/") {                      // "*/"
            if codeLineDetail.inMultiLine != .tripleQuote {
                codeLineDetail.inMultiLine = .none
            }
        }
        if codeLineDetail.inMultiLine == .blockComment && line.contains("*/") {
            codeLineDetail.inMultiLine = .blockComment
        }
        if line.hasPrefix("///") || codeLineDetail.inMultiLine == .blockMarkup {   // "///"
            swiftSummary.markupLineCount += 1
        } else if line.hasPrefix("//") || codeLineDetail.inMultiLine == .blockComment {   // "//"
            swiftSummary.commentLineCount += 1
            if swiftSummary.codeLineCount == 0 {
                if line.contains("Copyright") {
                    swiftSummary.copyright = line
                } else if line.contains("Created by ") {
                    swiftSummary.createdBy = line
                } else if line.contains("Ver") {
                    swiftSummary.version = line
                }
            }
            continue
        } else if line.count == 1 {
            swiftSummary.blankLineCount += 1 //???
            if line == "{" { gotOpenCurly(lineNum: lineNum) }                                       // single "{" on line
            if line == "}" { gotCloseCurly(lineNum: lineNum, nCodeLine: swiftSummary.codeLineCount) }   // single "}" on line
            continue                                                // bypass further processing
        } else if codeLineDetail.inMultiLine == .tripleQuote && !line.contains("\"\"\"") {
            swiftSummary.quoteLineCount += 1    //5/10/2019
            continue                                                // bypass further processing???
        }

        // MARK: Code!  387-671 = 284-lines

        // Call CodeLineDetail.init
        codeLineDetail = CodeLineDetail(fullLine: line, prevCodeLineDetail: codeLineDetail, lineNum: lineNum)

        let codeLineFull = codeLineDetail.codeLine
        if codeLineDetail.hasTrailingComment || codeLineDetail.hasEmbeddedComment {
            if codeLineDetail.hasTrailingComment {
                swiftSummary.nTrailing += 1
            } else {
                swiftSummary.nEmbedded += 1
            }
            if codeLineFull.count <= 1 {
                if codeLineFull == "{" {                                    // single "{" plus comment
                    gotOpenCurly(lineNum: lineNum)
                    swiftSummary.commentLineCount += 1
                }   // single "{" plus comment on line
                if codeLineFull == "}" {                                    // single "}" plus comment
                    gotCloseCurly(lineNum: lineNum, nCodeLine: swiftSummary.codeLineCount)
                    swiftSummary.commentLineCount += 1
                }   // single "}" on line
                continue                                                    // bypass further processing
            }
        }
        if codeLineFull.isEmpty {
            if !codeLineDetail.isMarkup {
                if deBug {
                    print("⛔️ Empty CodeLine \(codeLineDetail.lineNum): \"\(codeLineDetail.trimLine)\"")
                }
            }
            continue                                                    // bypass further processing
        }

        // Split compound line
        let codeLine: String
        if  codeLineFull.contains(";") {
            //print("Compound line \"\(codeLineFull)\"")
            let ptr = codeLineFull.firstIntIndexOf(";")
            fromPrevLine = codeLineFull.substring(begin: ptr+1).trim
            codeLine = codeLineFull.left(ptr)
        } else {
            codeLine = codeLineFull
        }

        // Handle unmatched [(
        var nextLine = ""
        if iLine<lines.count { nextLine = lines[iLine].trim }
        if needsContinuation(codeLineDetail: codeLineDetail, nextLine: nextLine, lineNum: lineNum) {
            //print("\(lineNum) Partial line? \"\(line)\" -> \"\(codeLine)\" from #\(#line)")
            partialLine = codeLine
            swiftSummary.continueLineCount += 1
            continue
        }

        swiftSummary.codeLineCount += 1

        var pOpenCurlyF  = codeLine.firstIntIndexOf("{")
        var pOpenCurlyR  = codeLine.lastIntIndexOf("{")
        var pCloseCurlyF = codeLine.firstIntIndexOf("}")
        var pCloseCurlyR = codeLine.lastIntIndexOf("}")

        inQuote = false
        var isEscaped = false
        for p in 0..<codeLine.count {                        // Read line char by char ?????
            let char = codeLine.substring(begin: p, length: 1)
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
        }//next p

        // Create a CharacterSet of delimiters.
        let separators = CharacterSet(charactersIn: "\t ([{:}]),;")     //tab, space, open*, colon, close*, comma, semi
        let wordsWithEmpty = codeLine.components(separatedBy: separators)   // Split based on characters.
        let words = wordsWithEmpty.filter { !$0.isEmpty }                   // Use filter to eliminate empty strings.
        let firstWord = words.first ?? ""

        // Check each word
        for word in words {

            // Find Force Unwraps
            if (word.hasSuffix("!") && firstWord != "@IBOutlet") || word.contains("!.") {
                let idx = codeLine.firstIntIndexOf(word)                         // idx is pointer to word
                let isForce = word.count > 1 || idx == 0 || codeLine[idx-1] != " "    // must not have whitespace before "!"
                if isForce {
                    let extra = getExtraForForceUnwrap(codeLineClean: codeLine, word: word, idx: idx)
                    if deBug && gDebug == .all {
                        print("line \(lineNum): \(word)")
                        print(codeLine)
                    }
                    var xword = word
                    if word.contains(".") {
                        let comps = word.components(separatedBy: ".")
                        for comp in comps {
                            if comp.hasSuffix("!") {
                                xword = comp
                                break
                            }
                        }
                        //xword = "." + (comps.last ?? "")
                    }
                    if swiftSummary.forceUnwraps.isEmpty { swiftSummary.issueCatsCount += 1 }
                    swiftSummary.totalIssues += 1
                    swiftSummary.forceUnwraps.append(LineItem(name: xword, lineNum: lineNum, extra: extra))
                }
            } else if !word.hasPrefix("!") && word.contains("!") {
                print()
            }

            // Find VBCompatability calls
            if gDictVBwords[word] != nil {
                if swiftSummary.vbCompatCalls.isEmpty       { swiftSummary.issueCatsCount += 1 }
                if swiftSummary.vbCompatCalls[word] == nil  { swiftSummary.totalIssues    += 1 }
                swiftSummary.vbCompatCalls[word, default: LineItem(name: word, lineNum: lineNum)].timesUsed += 1
            }

        }//next word

        var codeName = "import"
        if firstWord == codeName {
            let itemName: String
            if words.count > 1 { itemName = words[1] } else { itemName = "?" }
            let lineItem = LineItem(name: itemName, lineNum: lineNum)
            swiftSummary.imports.append(lineItem)
            if itemName == "Cocoa" {
                swiftSummary.projectType = ProjectType.OSX
            } else if itemName == "UIKit"  {
                swiftSummary.projectType = ProjectType.iOS
            } else {

            }
            //if deBug {print("\(lineNum) \(codeName) = \(itemName)")}
            continue                                        // isImport
        }

        //MARK: Blocks -> func, struc, enum, class, extension
        var foundNamedBlock = false

        //---------------------------------------------------------------   // func
        codeName = "func"
        if let posFunc = words.firstIndex(of: codeName) {
            //codeType = BlockType.isFunc
            var funcName = "????"
            if posFunc < words.count {
                funcName = words[posFunc + 1]   // get the word that follows "func"
                if !isCamelCase(funcName) {
                    recordNonCamelcase(funcName)
                }
                let paramNames = getParamNames(line: codeLine)
                for name in paramNames {
                    if !isCamelCase(name) { recordNonCamelcase(name) }
                }
            } else {
                print("⛔️ AnalyseSwift.swift #\(#line) Probable line-continuation (end with 'func')")
            }

            blockOnDeck = BlockInfo(blockType: .Func, lineNum: lineNum, codeLinesAtStart: swiftSummary.codeLineCount, name: funcName, extra: "", codeLineCount: 0)
            if posFunc > 0 {
                if firstWord == "override" {
                    index = BlockType.isOverride.rawValue                               // isOverride
                    blockOnDeck.blockType = .isOverride
                    blockTypes[index].total += 1
                } else if firstWord == "@IBAction" {
                    index = BlockType.IBAction.rawValue                                 // IBAction
                    blockOnDeck.blockType = .IBAction
                    blockTypes[index].total += 1
                } else {                // private, internal, fileprivate, public
                    index = BlockType.Func.rawValue                                     // Func
                    containerName = ""
                    if blockStack.count > 0 {
                        containerName = (blockStack.last!.name)
                        blockOnDeck.name = "\(containerName).\(blockOnDeck.name)"
                    } else {
                        print("⚠️ Free func: \(blockOnDeck.name)")
                    }
                    blockTypes[index].total += 1
                }
            }
            foundNamedBlock = true
        }//endif func

        //FIXME: THIS IS NUTS
        while !foundNamedBlock {    //for index in 4...8  containers: 4)Struct, 5)Enum, 6)Extension, 7)Class, 8)Protocol
            if words.count < 2 { break }
            let iMax = min(4, words.count)
            var index = -1
            for i in 0..<iMax {     // see if Block-Type appeaer in 1st 4 words
                if let idx = blockLookup[words[i]] {
                    index = idx
                    foundNamedBlock = true
                    break
                }
            }
            if index < 0 { break }

            codeName = blockTypes[index].codeName
            //print("\(index) \(iLine) \(line) \(words)")
            if let posItem = words.firstIndex(of: codeName) {
                let itemName = words[posItem + 1]
                var extra = ""
                for i in (posItem + 2)..<words.count {
                    if words[i].count > 1 {
                        extra += " " + words[i]
                    }
                }
                if codeName == "class" && words.count >= 3 && words[2].contains("ViewController") {
                    swiftSummary.viewController = words[2]
                }
                blockOnDeck = BlockInfo(blockType: blockTypes[index].blockType, lineNum: lineNum, codeLinesAtStart: swiftSummary.codeLineCount, name: itemName, extra: extra, codeLineCount: 0)

                blockTypes[index].total += 1
                foundNamedBlock = true
                break
            }//endif codeLine.contains
        }//end while

        //---------------------------------------------------------------   //end Named Blocks

        if pOpenCurlyF >= 0 && (pCloseCurlyF < 0 || pCloseCurlyF > pOpenCurlyF) {       // starts with {
            gotOpenCurly(lineNum: lineNum)
            pOpenCurlyF = -1
            netCurlys -= 1
        }
        if pCloseCurlyF >= 0 && (pOpenCurlyF < 0 || pCloseCurlyF < pOpenCurlyF) {       // starts with }
            gotCloseCurly(lineNum: lineNum, nCodeLine: swiftSummary.codeLineCount)
            netCurlys += 1
        }

        while netCurlys != 0 {
            if netCurlys > 0 {
                gotOpenCurly(lineNum: lineNum)
                netCurlys -= 1
            } else if netCurlys < 0 {
                gotCloseCurly(lineNum: lineNum, nCodeLine: swiftSummary.codeLineCount)
                netCurlys += 1
            }
        }

        //if deBug && gDebug == .all {print("➡️ \(codeLineClean)")}

        // problems
        // let ee,ff:Int
        // var ee:Int=0,ff = 0,gg:Int

        if words.isEmpty { continue }
        var isDeclaration = false
        var pLet = 4
        if words[0] == "let" || words[0] == "var" {
            isDeclaration = true
        } else if words.count >= 2 && (words.firstIndex(of: "let") != nil ||  words.firstIndex(of: "var") != nil ) {
            isDeclaration = true
            pLet = max(codeLine.firstIntIndexOf(" let "), codeLine.firstIntIndexOf(" var ")) + 5
        }
        if isDeclaration {
            let codeLineTrunc = codeLine.substring(begin: pLet).trim
            let comps1 = codeLineTrunc.components(separatedBy: "=")
            var assigneeList = comps1[0]                                // Strip off right side of "="
            let comps2 = assigneeList.components(separatedBy: ":")
            assigneeList = comps2[0]                                    // Strip off right side of ":"
            let assignees = assigneeList.components(separatedBy: ",").map { $0.trim }
            //if deBug {print(codeLineTrunc, assignees)}
            let isGlobal = blockStack.isEmpty ? true : false

            for assignee in assignees {
                var name = assignee.trim
                if name.hasPrefix("(") {
                    name = String(name.dropFirst()).trim
                }
                if name.hasSuffix(")") {
                    name = String(name.dropLast()).trim
                }
                if isGlobal {
                    print("⚠️ global: \(assignees)")
                }
                if !isCamelCase(name) {
                    recordNonCamelcase(name)
                }
            }//next assignee
        } else { // "let " or "var " not at beginning if line ?????
            if codeLine.contains(" let ") || codeLine.contains(" var ") {
                print("⛔️ #\(#line) Missed a declaration in \"\(codeLine)\"")
            }
        }
    }//next line
    //MARK: end Main Loop

    if curlyDepth != 0 {                                // Error Check
        print("😡⛔️😡 Error: AnalyseSwift.swift #\(#line): Final Curly-Depth = \(curlyDepth) 😡⛔️😡")
    }

    swiftSummary.byteCount = selecFileInfo.size
    swiftSummary.totalLineCount = lineNum
    if swiftSummary.codeLineCount > CodeRule.maxFileCodeLines {
        if swiftSummary.massiveFile == 0 { swiftSummary.issueCatsCount += 1 }
        swiftSummary.totalIssues += 1
        swiftSummary.massiveFile = 1
    }

    if deBug && gDebug == .all { print("\n\(namedBlocks.count) named blocks") }         // Sanity Check
    for c in namedBlocks {

        if deBug && gDebug == .all {
            let iBT = Int(c.blockType.rawValue)
            let cType = "\(c.blockType)".PadRight(14)
            print("# \(c.lineNum),\t\(c.codeLineCount) lines, \t\(cType)\t\(c.name)  \(c.extra)  \(iBT)")
        }

        switch c.blockType {
        case .Func:
            if c.codeLineCount > CodeRule.maxFuncCodeLines {
                if swiftSummary.massiveFuncs.isEmpty { swiftSummary.issueCatsCount += 1 }
                swiftSummary.totalIssues += 1
                swiftSummary.massiveFuncs.append(FuncInfo(name: c.name, codeLineCount: c.codeLineCount))
            }
        default: break
        }
    }
    return swiftSummary
}//end func analyseSwiftFile

private func getExtraForForceUnwrap(codeLineClean: String, word: String, idx: Int) -> String {
    let maxPrefixLen = 44
    let maxSuffixLen = 22
    var prefix = codeLineClean.substring(begin: 0, length: idx)   // prefix is stuff before word

    prefix = prefix.replacingOccurrences(of: "~~~~", with: "~") // remove excess garbage
    prefix = prefix.replacingOccurrences(of: "~~~~", with: "~")
    if prefix.contains(" = ") {                                 // cut off all before "="
        let comps = prefix.components(separatedBy: " = ")
        prefix = "...= " + (comps.last ?? "")
    }
    if prefix.count > maxPrefixLen {    // still too long
        prefix = "..." + prefix.suffix(maxPrefixLen)
    }

    let pTrail = idx + word.count
    var suffix = codeLineClean.substring(begin: pTrail)
    if suffix.count > maxSuffixLen {
        suffix = suffix.prefix(maxSuffixLen - 3) + "..."
    }
    if prefix.count + word.count + suffix.count > 60 && suffix.count > 3 {
        suffix = "..."
    }
    return prefix + word + suffix
}//end func

