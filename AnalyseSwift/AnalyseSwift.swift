//
//  AnalyseSwift.swift
//  AnalyseSwiftCode
//
//  Created by George Bauer on 1/10/18.
//  Copyright © 2018,2019 George Bauer. All rights reserved.
//

import Cocoa

// MARK: - Properties of analyseSwiftFile (globals - change to instance vars)
fileprivate var curlyDepth      = 0                     //accessed from gotOpenCurly, gotCloseCurly, getSelecFileInfo
fileprivate var blockOnDeck     = BlockInfo()           //accessed from gotOpenCurly,                analyseSwiftFile
fileprivate var blockStack      = [BlockInfo]()         //accessed from gotOpenCurly, gotCloseCurly, analyseSwiftFile
public      var codeElements    = [BlockInfo]()         //accessed from               gotCloseCurly, analyseSwiftFile

var blockTypes = [
BlockAggregate(blockType: .None,        subType: .None, codeName: "",             displayName: "unNamed",      showNone: false,count: 0),
BlockAggregate(blockType: .Func,        subType: .Func, codeName: "func",         displayName: "Regular func", showNone: true, count: 0),
BlockAggregate(blockType: .IBActionFunc,subType: .Func, codeName: "IBAction func",displayName: "IBAction func",showNone: false,count: 0),
BlockAggregate(blockType: .OverrideFunc,subType: .Func, codeName: "override func",displayName: "Override func",showNone: false,count: 0),
BlockAggregate(blockType: .Struct,      subType: .Struct,codeName:"struct",       displayName: "Struct",       showNone: false,count: 0),
BlockAggregate(blockType: .Enum,        subType: .Enum, codeName: "enum",         displayName: "Enum",         showNone: false,count: 0),
BlockAggregate(blockType: .Extension,   subType: .Class,codeName: "extension",    displayName: "Extension",    showNone: false,count: 0),
BlockAggregate(blockType: .Class,       subType: .Class,codeName: "class",        displayName: "Class",        showNone: true, count: 0),
BlockAggregate(blockType: .isProtocol,  subType: .isProtocol,codeName: "protocol",displayName: "Protocol",     showNone: false,count: 0)
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
    var codeLineCount   = 0
    var byteCount       = 0
    var totalLineCount  = 0
    var funcs           = [FuncInfo]()
    var ibActionFuncs   = [FuncInfo]()
    var overrideFuncs   = [FuncInfo]()
    var imports         = [LineItem]()
    var classNames      = [String]()
    var structNames     = [String]()
    var protocolNames   = [String]()
    var extensionNames  = [String]()
    var enumNames       = [String]()
    var nCommentLine = 0
    var nBlankLine   = 0
    var nCodeLine    = 0
    var nTrailing    = 0
    var nEmbedded    = 0

    // issues
    var nonCamelVars    = [LineItem]()
    var forceUnwraps    = [LineItem]()
    var massiveFuncs    = [FuncInfo]()
    var massiveFile     = 0
    var vbCompatCalls   = [String]()
    var nVBwords        = 0
    var nUniqueVBWords  = 0

    var url = FileManager.default.homeDirectoryForCurrentUser
}

internal struct FuncInfo {
    var name = ""
    var codeLineCount = 0
}

public enum BlockType: Int {
    case None           = 0
    case Func           = 1
    case IBActionFunc   = 2
    case OverrideFunc   = 3
    case Struct         = 4
    case Enum           = 5
    case Extension      = 6
    case Class          = 7
    case isProtocol     = 8
}

internal enum ProjectType {
    case unknown
    case OSX
    case iOS
}

internal struct BlockAggregate {
    let blockType:  BlockType
    let subType:    BlockType
    let codeName:   String
    let displayName: String
    let showNone:   Bool
    var count       = 0
}

public struct BlockInfo {
    var blockType        = BlockType.None
    var lineNum          = 0
    var codeLinesAtStart = 0
    var name             = ""
    var extra            = ""
    var codeLineCount    = 0
}

public struct LineItem {
    let lineNum: Int
    let name:  String
    let extra: String
}

// MARK: - Helper funcs

//---- gotOpenCurly - push "ondeck" onto stack, clear ondeck,  stackedCounter = nCodeLines
private func gotOpenCurly(lineNum: Int, deBug: Bool = false) {
    //if deBug { print("\(lineNum) got open curly; depth \(curlyDepth) -> \(curlyDepth+1)") }
    blockStack.insert(blockOnDeck, at: 0)
    blockOnDeck = BlockInfo()
    curlyDepth += 1
}

//---- gotCloseCurly - pop stackedCounter lines4item = nCodeLines - stackedCounter
private func gotCloseCurly(lineNum: Int, nCodeLine: Int, deBug: Bool = false) {
    //if deBug {print("\(lineNum) got close curly; depth \(curlyDepth) -> \(curlyDepth-1)")}
    curlyDepth -= 1
    var block = blockStack.remove(at: 0)
    if block.blockType != .None {
        //if deBug {print("\(block.name)")}
        block.codeLineCount = nCodeLine - block.codeLinesAtStart // lineNum - block.lineNum
        codeElements.append(block)
    }
}//end func

//---- isCamelCase
// Uses CodeRule
internal func isCamelCase(_ word: String) -> Bool {

    //TODO: Change minimum name length to IssuePreference
    if word == "_" { return true }
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

internal func needsContinuation(codeLineDetail: CodeLineDetail, nextLine: String, lineNum: Int = 0) -> Bool {
    if codeLineDetail.codeLine.isEmpty { return false }
    let lastChar = codeLineDetail.codeLine.suffix(1)
    let firstChar = nextLine.prefix(1)

    if lastChar == "=" || firstChar == "=" {return false}

    if codeLineDetail.bracketMismatch > 0 || codeLineDetail.parenMismatch > 0 {
        if ",()[]".contains(lastChar) {
            //print("\(lineNum)⬇️ needsContinuation: \(codeLineDetail.parenMismatch) \(codeLineDetail.bracketMismatch) \(codeLineDetail.codeLine)" )
            return true
        }
        if ",()[]".contains(firstChar) {
            //print("\(lineNum)⬇️ needsContinuation: \(codeLineDetail.parenMismatch) \(codeLineDetail.bracketMismatch) \(codeLineDetail.codeLine)" )
            return true
        }
        print("⛔️ Error AnalyseSwift.swift #\(#line) - from needsContinuation(): OpenClose Mismatch: Paren excess = \(codeLineDetail.parenMismatch) Bracket exess = \(codeLineDetail.bracketMismatch)" )
        print("  \(lineNum) \(codeLineDetail.codeLine)\n  \(lineNum+1) \(nextLine)" )
        print()
    }

    let hangers = "=+-*&|"      // "/" does not work - might be "//" or "/*"
    for hanger in hangers {
        let str = String(hanger)
        if firstChar == str || lastChar == str {
            return true
        }
    }
    if firstChar == "/" && nextLine.count >= 2 {
        let char2 = nextLine[1]
        if char2 != "/" && char2 != "*" {
            return true
        }
    }
    return false
}

// MARK: - the main event 407-lines
// called from analyseContentsButtonClicked         //239-646 = 407-lines
public func analyseSwiftFile(contentFromFile: String, selecFileInfo: FileAttributes, deBug: Bool = true) -> (SwiftSummary) {
    print("🔷 AnalyseSwift.swift #\(#line) Enter AnalyseSwiftFile(\(selecFileInfo.name))")

    let lines = contentFromFile.components(separatedBy: "\n")

    resetVBwords()

    var swiftSummary = SwiftSummary()
    swiftSummary.fileName = selecFileInfo.name
    swiftSummary.url = selecFileInfo.url!

    var blockLookup = [String : Int]()
    for (i, bkTyp) in blockTypes.enumerated() {
        blockTypes[i].count = 0                 // Reset Counter
        blockLookup[bkTyp.codeName] = i         // Set Lookup Name
    }

    curlyDepth   = 0
    blockOnDeck  = BlockInfo()
    blockStack   = []
    codeElements = []

    var containerName = ""
    var index        = 0
    var lineNum      = 0

    var inQuote    = false

    var fromPrevLine    = ""    // if prev line had a ";" (Compund Line), this is the excess after 1st ";"
    var partialLine     = ""    // if this is a Continuation Line
    var iLine           = 0

    func recordNonCamelcase(_ name: String) {
        let lineItem = LineItem(lineNum: lineNum, name: name, extra: "")
        if deBug {print("➡️ \(lineItem.lineNum) Non-CamelCased \(lineItem.name)")}
        swiftSummary.nonCamelVars.append(lineItem)
    }

    var codeLineDetail = CodeLineDetail()

    // MARK: Main Loop 282-616 = 334-lines
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
                swiftSummary.nBlankLine += 1
                continue
            }
        } else {                        // Still working in a compound line
            line = fromPrevLine.trim
            fromPrevLine = ""
            if line.isEmpty { continue }
        }

        // Line Continution
        if !partialLine.isEmpty {
            line = partialLine + " " + line
            partialLine = ""
        }

        var netCurlys = 0

        if line.hasPrefix("/*") {                             // "/*"
            codeLineDetail.inBlockComment = true
        } else if line.hasPrefix("*/") {                      // "*/"
            codeLineDetail.inBlockComment = false
        }
        if codeLineDetail.inBlockComment && line.contains("*/") { codeLineDetail.inBlockComment = false }

        if line.hasPrefix("//") || codeLineDetail.inBlockComment {   // "//"
            swiftSummary.nCommentLine += 1
            if swiftSummary.nCodeLine == 0 {
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
            swiftSummary.nBlankLine += 1 //???
            if line == "{" { gotOpenCurly(lineNum: lineNum) }                                 // single "{" on line
            if line == "}" { gotCloseCurly(lineNum: lineNum, nCodeLine: swiftSummary.nCodeLine) }          // single "}" on line
            continue                                                // bypass further processing
        } else if codeLineDetail.inTripleQuote && !line.contains("\"\"\"") {
            continue                                                // bypass further processing???
        }

        // MARK: Code!  343-616 = 273-lines

        codeLineDetail = CodeLineDetail(fullLine: line, prevCodeLineDetail: codeLineDetail, lineNum: lineNum)

        let codeLineFull = codeLineDetail.codeLine
        if codeLineDetail.hasTrailingComment || codeLineDetail.hasEmbeddedComment {
            if codeLineDetail.hasTrailingComment {
                swiftSummary.nTrailing += 1
            } else {
                swiftSummary.nEmbedded += 1
            }
            if codeLineFull.count <= 1 {
                if codeLineFull == "{" { gotOpenCurly(lineNum: lineNum) }                                       // single "{" on line
                if codeLineFull == "}" { gotCloseCurly(lineNum: lineNum, nCodeLine: swiftSummary.nCodeLine) }   // single "}" on line
                continue                                                // bypass further processing
            }
        }
        if codeLineFull.isEmpty {
            continue
        }

        //Split compound line
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
            continue
        }

        swiftSummary.nCodeLine += 1

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

        // Find Force Unwraps
        for word in words {
            if word.hasSuffix("!") && firstWord != "@IBOutlet" {
                let idx = codeLine.firstIntIndexOf(word)                         // idx is pointer to word
                let isForce = word.count > 1 || idx == 0 || codeLine[idx-1] != " "    // must not have whitespace before "!"
                if isForce {
                    let extra = getExtraForForceUnwrap(codeLineClean: codeLine, word: word, idx: idx)
                    if deBug {
                        print("line \(lineNum): \(word)")
                        print(codeLine)
                    }
                    var xword = word
                    if word.contains(".") {
                        let comps = word.components(separatedBy: ".")
                        xword = "." + (comps.last ?? "")
                    }
                    swiftSummary.forceUnwraps.append(LineItem(lineNum: lineNum, name: xword, extra: extra))
                    //forceUnwraps.append(xword)
                }
            }

            // Find VBCompatability calls
            if let count = gDictVBwords[word] {
                swiftSummary.nVBwords += 1
                if count == 0 {
                    swiftSummary.nUniqueVBWords += 1
                    swiftSummary.vbCompatCalls.append(word)
                }
                gDictVBwords[word] = count + 1
            }
        }//next word

        var codeName = "import"
        if firstWord == codeName {
            let itemName: String
            if words.count > 1 { itemName = words[1] } else { itemName = "?" }
            let lineItem = LineItem(lineNum: lineNum, name: itemName, extra: "")
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

            blockOnDeck = BlockInfo(blockType: .Func, lineNum: lineNum, codeLinesAtStart: swiftSummary.nCodeLine, name: funcName, extra: "", codeLineCount: 0)
            if posFunc > 0 {
                if firstWord == "override" {
                    index = BlockType.OverrideFunc.rawValue                                // OverrideFunc
                    blockOnDeck.blockType = .OverrideFunc
                    blockTypes[index].count += 1
                } else if firstWord == "@IBAction" {
                    index = BlockType.IBActionFunc.rawValue                                // IBActionFunc
                    blockOnDeck.blockType = .IBActionFunc
                    blockTypes[index].count += 1
                } else {                            //private, internal, fileprivate, public
                    index = BlockType.Func.rawValue                                         // Func
                    containerName = ""
                    if blockStack.count > 0 {
                        containerName = (blockStack.last!.name)
                        blockOnDeck.name = "\(containerName).\(blockOnDeck.name)"
                    }
                    blockTypes[index].count += 1
                }
            }
            foundNamedBlock = true
        }//endif func

        //FIXME: THIS IS NUTS
        while true {//for index in 4...8 {        // containers: 4)Struct, 5)Enum, 6)Extension, 7)Class, 8)isProtocol
            if foundNamedBlock { break }
            if words.count < 2 { break }
            let iMax = min(3, words.count)
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
                blockOnDeck = BlockInfo(blockType: blockTypes[index].blockType, lineNum: lineNum, codeLinesAtStart: swiftSummary.nCodeLine, name: itemName, extra: extra, codeLineCount: 0)

                switch index {
                case 4 :  swiftSummary.structNames.append(itemName)
                case 5 :  swiftSummary.enumNames.append(itemName)
                case 6 :  swiftSummary.extensionNames.append(itemName)
                case 7 :  swiftSummary.classNames.append(itemName)
                case 8 :  swiftSummary.protocolNames.append(itemName)
                default: break
                }

                blockTypes[index].count += 1
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
            gotCloseCurly(lineNum: lineNum, nCodeLine: swiftSummary.nCodeLine)
            netCurlys += 1
        }

        while netCurlys != 0 {
            if netCurlys > 0 {
                gotOpenCurly(lineNum: lineNum)
                netCurlys -= 1
            } else if netCurlys < 0 {
                gotCloseCurly(lineNum: lineNum, nCodeLine: swiftSummary.nCodeLine)
                netCurlys += 1
            }
        }

        //if deBug {print("➡️ \(codeLineClean)")}

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
            let assignees = assigneeList.components(separatedBy: ",")
            //if deBug {print(codeLineTrunc, assignees)}
            for assignee in assignees {
                var name = assignee.trim
                if name.hasPrefix("(") {
                    name = String(name.dropFirst()).trim
                }
                if name.hasSuffix(")") {
                    name = String(name.dropLast()).trim
                }
                if !isCamelCase(name) {
                    recordNonCamelcase(name)
                }
            }//next assignee
        } else { // "let " or "var " not at beginning if line ?????
            if codeLine.contains(" let ") || codeLine.contains(" var ") {
                print(codeLine)
                print()
            }
        }
    }//next line
    //MARK: end Main Loop

    if curlyDepth != 0 {                                // Error Check
        print("😡⛔️😡 Error: AnalyseSwift.swift #\(#line): Final Curly-Depth = \(curlyDepth) 😡⛔️😡")
    }

    swiftSummary.byteCount = selecFileInfo.size
    swiftSummary.totalLineCount = lineNum
    swiftSummary.codeLineCount = swiftSummary.nCodeLine
    if swiftSummary.nCodeLine > CodeRule.maxFileCodeLines { swiftSummary.massiveFile = 1 }

    if deBug { print(codeElements.count, " named blocks") }         // Sanity Check
    for c in codeElements {
        let iBT = Int(c.blockType.rawValue)
        let cType = ("\(c.blockType)" + "        ").left(14)
        if deBug {print("# \(c.lineNum),\t\(c.codeLineCount) lines, \t\(cType)\t\(c.name)  \(c.extra)  \(iBT)")}

        switch c.blockType {
        case .Func:
            swiftSummary.funcs.append(FuncInfo(name: c.name, codeLineCount: c.codeLineCount))
            if c.codeLineCount > CodeRule.maxFuncCodeLines {
                swiftSummary.massiveFuncs.append(FuncInfo(name: c.name, codeLineCount: c.codeLineCount))
            }
        case .IBActionFunc: swiftSummary.ibActionFuncs.append(FuncInfo(name: c.name, codeLineCount: c.codeLineCount))
        case .OverrideFunc: swiftSummary.overrideFuncs.append(FuncInfo(name: c.name, codeLineCount: c.codeLineCount))
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

