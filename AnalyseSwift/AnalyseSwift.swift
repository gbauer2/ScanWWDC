//
//  AnalyseSwift.swift
//  AnalyseSwiftCode
//
//  Created by George Bauer on 1/10/18.
//  Copyright © 2018,2019 George Bauer. All rights reserved.
//

import Cocoa

// MARK: - Properties of analyseSwiftFile (instance vars)
var curlyDepth      = 0                     //accessed from gotOpenCurly, gotCloseCurly, getSelecFileInfo
var blockOnDeck     = BlockInfo()           //accessed from gotOpenCurly,                analyseSwiftFile
var blockStack      = [BlockInfo]()         //accessed from gotOpenCurly, gotCloseCurly, analyseSwiftFile
var codeElements    = [BlockInfo]()         //accessed from               gotCloseCurly, analyseSwiftFile

// MARK: - Block Structs & Enums

// Stuff to be returned by AnalyseSwift
public struct SwiftSummary {
    var fileName        = ""
    var codeLineCount   = 0
    var byteCount       = 0
    var totalLineCount  = 0
    var funcs           = [FuncInfo]()
    var ibActionFuncs   = [FuncInfo]()
    var overrideFuncs   = [FuncInfo]()
    var importNames     = [String]()
    var classNames      = [String]()
    var structNames     = [String]()
    var protocolNames   = [String]()
    var extensionNames  = [String]()
    var enumNames       = [String]()
    // issues
    var nonCamelCases   = [String]()
    var forceUnwraps    = [String]()
    var vbCompatCalls   = [String]()
    var massiveFuncs    = [FuncInfo]()
    var massiveFile     = 0
    var url = FileManager.default.homeDirectoryForCurrentUser
}

public struct FuncInfo {
    var name = ""
    var codeLineCount = 0
}

enum BlockType: Int {
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
    var blockType        = BlockType.None
    var lineNum          = 0
    var codeLinesAtStart = 0
    var name             = ""
    var extra            = ""
    var codeLineCount    = 0
}

private struct LineItem {
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

//---- checkCurlys - Check that there is no "}" and no more the 1 "{" and only AFTER class,extension,func,struc,enum declaration
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

// Strip comment & neuter quotes from line, returning trimmed code portion, hasTrailingComment, hasEmbeddedComment
/// Strip comments & neutralize quotes from trimmed sourcecode line
///
/// - Parameters:
///   - fullLine: Swift source code - already TRIMMED
///   - lineNum: Swift source line number
///   - inTripleQuote: inout. Are we inside a multi-line string literal
///   - inBlockComment: inout. Are we inside a block comment (/*.../*)
/// - Returns: tuple (CleanLine, hastrailingComment, hasEmbeddedComment)
func stripCommentAndQuote(fullLine: String, lineNum: Int, inTripleQuote: inout Bool, inBlockComment: inout Bool)
    -> (codeLine: String, hasTrailing: Bool, hasEmbedded: Bool) {   //137-258 = 121-lines
        //TODO: Raw-string delimiters with more than 1 asterisk **"..."**
        //TODO: Raw-triple-quote    *"""
        //TODO: Interpolation       \(var)
        //TODO: Mark-up detection   ///     /**.../*
        //TODO: Add inout inBlockMarkup
        //TODO: Add return isMarkup (struct?)
        if inBlockComment && !fullLine.contains("*/") {
            return ("", false, false)                       // Whole line is in BlockComment
        }
        if !fullLine.contains("//") && !fullLine.contains("\"") && !fullLine.contains("/*")  && !fullLine.contains("*/") {
            return (fullLine, false, false)                 // No comment or quote
        }
        if fullLine.hasPrefix("\"\"\"") || fullLine.hasSuffix("\"\"\"") {
            inTripleQuote = !inTripleQuote
        }
        if !inBlockComment && fullLine.hasPrefix("//") {
            return (fullLine, false, false)
        }

        let blockCommentStr  = "⌇"
        let blockCommentChar = Character(blockCommentStr)
        var hasTrailing = false
        var hasEmbedded = false
        // Block comment ignores all but "\" and "*/"
        // Raw String ignores all but \# and "#
        //#”You can use “ and “\” in a raw string. Interpolating as \#(var).”#
        //  #"  "#    //    /*  */    \    \#
        var pComment    = -1
        var blockPrev   = false
        var preserveQuote = false
        var inQuote     = false     // in String literal OR Raw String
        var inRawQuote  = false     // in Raw String
        var isEscaped   = false
        var prevChar    = Character(" ")
        var chars = Array(fullLine)
        for (p,char) in chars.enumerated() {
            //if char == "(" { isEscaped = false }
            if !isEscaped && !inBlockComment {
                // Quote "
                if char == "\"" {
                    if inQuote {
                        if !inRawQuote {
                            inQuote = false
                        }
                    } else {
                        inQuote = true              // in Quotes
                        preserveQuote = true
                        if prevChar == "#" {        // #" as in #"xxx"#
                            inRawQuote = true
                        }
                    }

                    // Hashtag "#"
                } else if char == "#" {
                    if prevChar == "\"" {           // "# as in #"xxx"#
                        if inRawQuote {
                            chars[p-1] = prevChar
                            inQuote = false
                            inRawQuote = false
                        }
                    }

                    // Asterisk "*"
                } else if char == "*" {
                    if !inQuote && prevChar == "/" {           // "/*"
                        blockPrev = true
                        hasEmbedded = true
                        inBlockComment = true
                    }

                    // BackSlash "\"
                } else if char == "\\" {
                    isEscaped = inQuote && !inRawQuote

                    // Slash "/"
                } else if char == "/" {
                    if !inQuote && prevChar == "/" {
                        pComment = p
                        hasTrailing = true
                        break
                    }
                }
            } else {
                isEscaped = false
            }//endif Not escaped and Not blockComment

            if inBlockComment {
                if char == "/" && prevChar == "*" {         // "*/"
                    inBlockComment = false
                    chars[p] = blockCommentChar
                }
            }

            if inBlockComment {
                chars[p] = blockCommentChar
                if blockPrev {
                    chars[p-1] = blockCommentChar
                    blockPrev = false
                }
            }

            if inQuote {
                if preserveQuote {
                    preserveQuote = false
                } else {
                    chars[p] = "~"
                }
            }

            prevChar = char
        }//next p
        let codeLine: String
        if pComment >= 0 {
            let sliceChars = chars.prefix(pComment - 1)
            codeLine = String(sliceChars).replacingOccurrences(of: blockCommentStr, with: "").trim
        } else {
            codeLine = String(chars).replacingOccurrences(of: blockCommentStr, with: "").trim
        }
        return (codeLine, hasTrailing, hasEmbedded)
}//end func stripCommentAndQuote

//---- isCamelCase
func isCamelCase(_ word: String) -> Bool {

    //TODO: Change minimum name length to IssuePreference
    if word == "_" { return true }
    if word.count < 2 { return false }

    //Allow AllCaps
    if CodeRule.allowAllCaps {
        var isAllCaps = true
        for char in word {
            if !char.isUppercase {
                if !CodeRule.allowUnderscore ||  char != "_" {
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

func checkParams(line: String) {
    let open = line.firstIntIndexOf("(")
    if open < 0 {
        print("⛔️ Probable line-continuation ('func' with no '(')")
        return
    }
    let close = line.firstIntIndexOf(")")
    if close < open+1 {
        print("⛔️ Probable line-continuation ('func' with no ')')")
        return
    }
    let paramStr = line.substring(begin: open+1, end: close-1)
    print("🔹 paramStr for \(line) = \"\(paramStr)\"")
    let paramsWithTypes = paramStr.components(separatedBy: ",").filter { !$0.isEmpty }.map { $0.trim }
    if paramsWithTypes.isEmpty { return }

    print(paramsWithTypes)

    for paramWithType in paramsWithTypes {
        let paramPair = paramWithType.components(separatedBy: ":")[0].trim
    }
}

// MARK: - the main event 562-lines
// called from analyseContentsButtonClicked         //315-877 = 562-lines
func analyseSwiftFile(contentFromFile: String, selecFileInfo: FileAttributes, deBug: Bool = true) -> (SwiftSummary, NSAttributedString) {
    let lines = contentFromFile.components(separatedBy: "\n")

    resetVBwords()
    var nVBwords = 0
    var nUniqueVBWords = 0
    var swiftSummary = SwiftSummary()
    swiftSummary.fileName = selecFileInfo.name
    swiftSummary.url = selecFileInfo.url!

    var blockTypes = [BlockAggregate]()
    blockTypes.append(BlockAggregate(blockType: .None,        subType: .None, codeName: "",             displayName: "unNamed",      showNone: false,count: 0))
    blockTypes.append(BlockAggregate(blockType: .Func,        subType: .Func, codeName: "func",         displayName: "Regular func", showNone: true, count: 0))
    blockTypes.append(BlockAggregate(blockType: .IBActionFunc,subType: .Func, codeName: "IBAction func",displayName: "IBAction func",showNone: false,count: 0))
    blockTypes.append(BlockAggregate(blockType: .OverrideFunc,subType: .Func, codeName: "override func",displayName: "Override func",showNone: false,count: 0))
    blockTypes.append(BlockAggregate(blockType: .Struct,      subType: .Struct,codeName:"struct",       displayName: "Struct",       showNone: false,count: 0))
    blockTypes.append(BlockAggregate(blockType: .Enum,        subType: .Enum, codeName: "enum",         displayName: "Enum",         showNone: false,count: 0))
    blockTypes.append(BlockAggregate(blockType: .Extension,   subType: .Class,codeName: "extension",    displayName: "Extension",    showNone: false,count: 0))
    blockTypes.append(BlockAggregate(blockType: .Class,       subType: .Class,codeName: "class",        displayName: "Class",        showNone: true, count: 0))
    blockTypes.append(BlockAggregate(blockType: .isProtocol,  subType: .isProtocol,codeName: "protocol",displayName: "Protocol",     showNone: false,count: 0))

    for i in 0..<blockTypes.count {         // Error check location in array vs. enum - not needed
        let ty = blockTypes[i]
        if i != ty.blockType.rawValue {
            print("⛔️ Error \(ty.blockType) \(i) <> \(ty.blockType.rawValue)")
        }
    }//next i

    curlyDepth   = 0
    blockOnDeck  = BlockInfo()
    blockStack   = []
    codeElements = []

    var whatViewController = ""
    var copyright       = ""
    var createdBy       = ""
    var version         = ""
    var containerName   = ""
    var projectType     = ProjectType.unknown
    var index        = 0
    var lineNum      = 0
    var nCommentLine = 0
    var nBlankLine   = 0
    var nCodeLine    = 0
    var nTrailing    = 0

    var inMultiLineComment = false
    var inBlockComment  = false
    var inTripleQuote = false
    var inQuote    = false

    var imports             = [LineItem]()
    var nonCamelVars        = [LineItem]()
    var forceUnwraps        = [LineItem]()

    //var enums             = [LineItem]()
    //var classes           = [LineItem]()
    //var extensions        = [LineItem]()

    //infoTextView.string = "Analysing..."

    var fromPrevLine    = ""    // if prev line had a ";", this is the excess after 1st ";"
    var skipLineCount   = 0     // Number of lines to skipdue to line continuation
    var iLine           = 0

    // MARK: Main Loop 435-769 = 334-lines
    while iLine < lines.count {
        //        // Multitasking Check
        //        if selecFileInfo.url != ViewController.latestUrl {
        //            if let latestUrl = ViewController.latestUrl {
        //                //print("😎Working on \(selecFileInfo.url!),\n but \(latestUrl) is now current😎")
        //                //let tx  = NSMutableAttributedString(string: "Abort!")
        //                //return (swiftSummary, tx)
        //            }
        //        }
        if skipLineCount > 0 {          // Skip this line, it was already used as a line continuation
            skipLineCount -= 1
            continue
        }
        let line: String
        if fromPrevLine.isEmpty {       // Read a new line from source
            line = lines[iLine].trim
            iLine += 1
            lineNum += 1
            if line.isEmpty {
                nBlankLine += 1
                continue
            }
        } else {                        // Still working in a compound line
            line = fromPrevLine.trim
            fromPrevLine = ""
            if line.isEmpty { continue }
        }
        var netCurlys = 0

        if line.hasPrefix("/*") {                             // "/*"
            inMultiLineComment = true
        } else if line.hasPrefix("*/") {                      // "*/"
            inMultiLineComment = false
        }
        if inMultiLineComment && line.contains("*/") { inMultiLineComment = false }

        if line.hasPrefix("//") || inMultiLineComment {   // "//"
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
            continue
        } else if line.count == 1 {
            nBlankLine += 1
            if line == "{" { gotOpenCurly(lineNum: lineNum) }                                 // single "{" on line
            if line == "}" { gotCloseCurly(lineNum: lineNum, nCodeLine: nCodeLine) }          // single "}" on line
            continue
        } else if inTripleQuote && !line.contains("\"\"\"") {
            continue
        }

        // MARK: Code!  495-769 = 274-lines
        nCodeLine += 1
        let (codeLineFull, hasTrailing, hasEmbedded) = stripCommentAndQuote(fullLine: line, lineNum: lineNum, inTripleQuote: &inTripleQuote, inBlockComment: &inBlockComment)
        if hasTrailing { nTrailing += 1 }

        //FIXME: Split compound line - remove "false &&"
        let codeLine: String
        if  codeLineFull.contains(";") {
            print("Compound line \"\(codeLineFull)\"")
            let ptr = codeLineFull.firstIntIndexOf(";")
            fromPrevLine = codeLineFull.substring(begin: ptr+1).trim
            codeLine = codeLineFull.left(ptr)
        } else {
            codeLine = codeLineFull
        }

        let pQuoteFirst  = codeLine.firstIntIndexOf("\"")
        let pQuoteLast   = codeLine.lastIntIndexOf("\"")

        var pOpenCurlyF  = codeLine.firstIntIndexOf("{")
        var pOpenCurlyR  = codeLine.lastIntIndexOf("{")
        var pCloseCurlyF = codeLine.firstIntIndexOf("}")
        var pCloseCurlyR = codeLine.lastIntIndexOf("}")

        inQuote = false
        var isEscaped = false
        for p in 0..<codeLine.count {                        // Read line char by char
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

        if inQuote {
            print("⚠️\(lineNum) Odd number of Quotes - \(line)")
        }
        if (pQuoteFirst == pQuoteLast) && (pQuoteFirst >= 0) {
            print("⚠️\(lineNum) Unmatched Quote - \(line)")
        }
        if pOpenCurlyF >= 0 && (pOpenCurlyF != pOpenCurlyR) {
            print("⚠️\(lineNum) multiple open curlys.   \"\(line)\"")
        }
        if pCloseCurlyF >= 0 && (pCloseCurlyF != pCloseCurlyR) {
            print("⚠️\(lineNum) multiple close curlys.  \"\(line)\"")
        }


        // Create a CharacterSet of delimiters.
        let separators = CharacterSet(charactersIn: "\t ([{:}]),;")     //tab, space, open*, colon, close*, comma, semi
        let wordsWithEmpty = codeLine.components(separatedBy: separators)   // Split based on characters.
        let words = wordsWithEmpty.filter { !$0.isEmpty }                   // Use filter to eliminate empty strings.
        let firstWord = words.first ?? ""

        for word in words {
            // Find Forced Unwraps
            if word.hasSuffix("!") && firstWord != "@IBOutlet" {
                let p = codeLine.firstIntIndexOf(word)                         // p is pointer to word
                let isForce = word.count > 1 || p == 0 || codeLine[p-1] != " "    // must not have whitespace before "!"
                if isForce {
                    let extra = getExtraForForceUnwrap(codeLineClean: codeLine, word: word, p: p)
                    if deBug {
                        print("line \(lineNum): \(word)")
                        print(codeLine)
                    }
                    var xword = word
                    if word.contains(".") {
                        let comps = word.components(separatedBy: ".")
                        xword = "." + (comps.last ?? "")
                    }
                    forceUnwraps.append(LineItem(lineNum: lineNum, name: xword, extra: extra))
                    swiftSummary.forceUnwraps.append(xword)
                }
            }

            // Find VBCompatability calls
            if let count = gDictVBwords[word] {
                nVBwords += 1
                if count == 0 {
                    nUniqueVBWords += 1
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
            imports.append(lineItem)
            if itemName == "Cocoa" {
                projectType = ProjectType.OSX
            } else if itemName == "UIKit"  {
                projectType = ProjectType.iOS
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
                    let lineItem = LineItem(lineNum: lineNum, name: funcName, extra: "")
                    if deBug {print("➡️ \(lineItem.lineNum) Non-CamelCased \(lineItem.name)")}
                    nonCamelVars.append(lineItem)
                    swiftSummary.nonCamelCases.append(lineItem.name)
                }
                checkParams(line: codeLine)
            } else {
                print("⛔️ Probable line-continuation (end with 'func')")
            }

            checkCurlys(codeName: codeName, itemName: funcName, posItem: posFunc, pOpenCurlyF: pOpenCurlyF, pOpenCurlyR: pOpenCurlyR, pCloseCurlyF: pCloseCurlyF, pCloseCurlyR: pCloseCurlyR)
            blockOnDeck = BlockInfo(blockType: .Func, lineNum: lineNum, codeLinesAtStart: nCodeLine, name: funcName, extra: "", codeLineCount: 0)
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

        for index in 4...8 {        // containers: 4)Struct, 5)Enum, 6)Extension, 7)Class, 8)isProtocol
            if foundNamedBlock { break }
            codeName = blockTypes[index].codeName
            if let posItem = words.firstIndex(of: codeName) {
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
                blockOnDeck = BlockInfo(blockType: blockTypes[index].blockType, lineNum: lineNum, codeLinesAtStart: nCodeLine, name: itemName, extra: extra, codeLineCount: 0)

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
            }//endif codeLine.contains
        }//next index

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

        //if deBug {print("➡️ \(codeLineClean)")}

        // problems
        // let ee,ff:Int
        // var ee:Int=0,ff = 0,gg:Int

        if codeLine.hasPrefix("let ") || codeLine.hasPrefix("var ") {
            let codeLineTrunc = String(codeLine.dropFirst(4))
            let comps1 = codeLineTrunc.components(separatedBy: "=")
            var assigneeList = comps1[0]                                // Strip off right side of "="
            let comps2 = assigneeList.components(separatedBy: ":")
            assigneeList = comps2[0]                                    // Strip off right side of ":"
            let assignees = assigneeList.components(separatedBy: ",")
            //assignees = assignees.map { $0.trim }
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
                    let lineItem = LineItem(lineNum: lineNum, name: name, extra: "")
                    if deBug {print("➡️ \(lineItem.lineNum) Non-CamelCased \(lineItem.name)")}
                    nonCamelVars.append(lineItem)
                    swiftSummary.nonCamelCases.append(lineItem.name)
                    if nonCamelVars.count != swiftSummary.nonCamelCases.count {
                        print("⛔️ analyseSwift #\(#line) \(nonCamelVars.count) != \(swiftSummary.nonCamelCases.count)")
                    }
                }
            }//next assignee
        } else { // "let " or "var " not at beginning if line ?????
            if codeLine.contains(" let ") || codeLine.contains(" var ") {
                print(codeLine)
                // @IBOutlet weak var tableView:    NSTableView!
                // if let selectedFolderUrl = selectedFolderUrl {
                // static var latestUrl: URL?
                // guard let selectedUrl = selectedItemUrl else { return }
                // catch let error as NSError {
                // } catch let error as NSError {
                // } catch let error {
                // } else if let db = value as? Double {
                // private var pbxObjects = [String: PBX]()
                // public var debugDescription: String {
                // static let flagProductNameDif   = 1
                // private var vowels: [String] {
                print()
            }
        }
    }//next line
    //MARK: end Main Loop

    //MARK: Analysis display: NSMutableAttributedString

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
    if projectType == ProjectType.OSX {
        tx = NSMutableAttributedString(string: "Mac OSX  ", attributes: attributesLargeFont)
        txt.append(tx)
    } else if projectType == ProjectType.iOS {
        tx = NSMutableAttributedString(string: "iOS    ", attributes: attributesLargeFont)
        txt.append(tx)
    }

    // Print File Name
    tx  = NSMutableAttributedString(string: "\(selecFileInfo.name) \(whatViewController)\n", attributes: attributesLargeFont)
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
    tx  = NSMutableAttributedString(string: "\(createdBy)\n\(copyright)\n\(version)\n", attributes: attributesSmallFont)
    txt.append(tx)

    // Print FileSize & various line counts.
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    //numberFormatter.locale = unitedStatesLocale
    let sizeStr = numberFormatter.string(from: selecFileInfo.size as NSNumber) ?? ""

    swiftSummary.byteCount = Int(sizeStr.replacingOccurrences(of: ",", with: "")) ?? -1
    tx  = NSMutableAttributedString(string: "\(sizeStr) bytes.\n", attributes: attributesMediumFont)
    txt.append(tx)

    swiftSummary.totalLineCount = lineNum
    tx  = NSMutableAttributedString(string: "\(lineNum) lines total.  ", attributes: attributesMediumFont)
    txt.append(tx)
    tx  = NSMutableAttributedString(string: "\(nCommentLine) comment lines.  ", attributes: attributesSmallFont)
    txt.append(tx)
    tx  = NSMutableAttributedString(string: "\(nBlankLine) blank lines.\n", attributes: attributesSmallFont)
    txt.append(tx)
    swiftSummary.codeLineCount = nCodeLine
    if nCodeLine > CodeRule.maxFileCodeLines { swiftSummary.massiveFile = 1 }
    tx  = NSMutableAttributedString(string: "\(nCodeLine) lines of code.  ", attributes: attributesMediumFont)
    txt.append(tx)
    tx  = NSMutableAttributedString(string: "\(nTrailing) with trailing comments.\n", attributes: attributesSmallFont)
    txt.append(tx)
    //if deBug {print()}

    // Print Imports
    swiftSummary.importNames = imports.map { $0.name }
    tx = showLineItems(name: "Import", items: imports)
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
        print("⛔️ Error - \(blockTypes.count) blockTypes,  but \(printOrder.count) items in printOrder")
    }

    // foreach named blockType, show the list of blocks in printOrder
    for i in 0..<blockTypes.count - 1 {
        let blkType = blockTypes[printOrder[i]]
        tx = showNamedBlock(name: blkType.displayName, blockType: blkType.blockType, list: codeElements)
        if deBug {print(tx.string)}
        if blkType.showNone || blkType.count > 0 {txt.append(tx)}
    }

    if curlyDepth != 0 {                                // Error Check
        print("😡⛔️😡 Error: Final Curly-Depth = \(curlyDepth) 😡⛔️😡")
    }

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

    //MARK: Show Issues

    let issuesTitle: String
    let totalIssueCount = nonCamelVars.count + forceUnwraps.count + nVBwords + swiftSummary.massiveFile + swiftSummary.massiveFuncs.count
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
    if nonCamelVars.count > 0 {
        if deBug {print("\n😡 \(nonCamelVars.count) non-CamelCased variables")}
        for nonCamel in nonCamelVars {
            if deBug {print("😡 line \(nonCamel.lineNum): \(nonCamel.name)")}
        }
        if deBug {print()}
        tx = showLineItems(name: "Non-CamelCased Var", items: nonCamelVars)
        txt.append(tx)
    }

    // print forced unwraps
    if deBug {print("\n\n😡 \(selecFileInfo.name)\t\t\(selecFileInfo.modificationDate!.ToString("MM-dd-yyyy hh:mm"))")}
    if forceUnwraps.count > 0 {
        if deBug {print("\n😡 \(forceUnwraps.count) non-forceCased variables")}
        for forceUnwrap in forceUnwraps {
            if deBug {print("😡 line \(forceUnwrap.lineNum): \(forceUnwrap.name)")}
        }
        if deBug {print()}
        tx = showLineItems(name: "Forced Unwrap", items: forceUnwraps)
        txt.append(tx)
    }

    // print VBCompatability stuff
    if nVBwords > 0 {
        var vbLineItems = [LineItem]()
        if deBug {print("😡 \(nUniqueVBWords) unique VBCompatability calls, for a total of \(nVBwords).")}
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
    return (swiftSummary, txt)
}//end func analyseSwiftFile

private func getExtraForForceUnwrap(codeLineClean: String, word: String, p: Int) -> String {
    let maxPrefixLen = 44
    let maxSuffixLen = 22
    var prefix = codeLineClean.substring(begin: 0, length: p)         // prefix is stuff before word

    prefix = prefix.replacingOccurrences(of: "~~~~", with: "~") // remove excess garbage
    prefix = prefix.replacingOccurrences(of: "~~~~", with: "~")
    if prefix.contains(" = ") {                             // cut off all before "="
        let comps = prefix.components(separatedBy: " = ")
        prefix = "...= " + (comps.last ?? "")
    }
    if prefix.count > maxPrefixLen {    // still too long
        prefix = "..." + prefix.suffix(maxPrefixLen)
    }

    let pTrail = p + word.count
    var suffix = codeLineClean.substring(begin: pTrail)
    if suffix.count > maxSuffixLen {
        suffix = suffix.prefix(maxSuffixLen - 3) + "..."
    }
    if prefix.count + word.count + suffix.count > 60 && suffix.count > 3 {
        suffix = "..."
    }
    return prefix + word + suffix
}

//MARK:- Attrubuted Strings

let paragraphStyleA1 = NSMutableParagraphStyle()    //accessed from showLineItems, showNamedBlock, analyseSwiftFile

private func showDivider(title: String) -> NSMutableAttributedString {
    let txt = "\n------------------- \(title) -------------------\n"
    let nsAttTxt = NSMutableAttributedString(string: txt, attributes: [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 15), NSAttributedString.Key.paragraphStyle: paragraphStyleA1])
    return nsAttTxt
}

private func showIssue(_ text: String) -> NSMutableAttributedString {
    let txt = "\(text)\n"
    let nsAttTxt = NSMutableAttributedString(string: txt, attributes: [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 15), NSAttributedString.Key.paragraphStyle: paragraphStyleA1])
    return nsAttTxt
}

// Returns NSMutableAttributedString showing name as a title, followed by list of items (line#, name, extra)
private func showLineItems(name: String, items: [LineItem]) -> NSMutableAttributedString {

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
private func showNamedBlock(name: String, blockType: BlockType, list: [BlockInfo]) -> NSMutableAttributedString {
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
