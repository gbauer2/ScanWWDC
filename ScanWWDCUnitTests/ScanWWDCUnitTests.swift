//
//  ScanWWDCUnitTests.swift
//  ScanWWDCUnitTests
//
//  Created by George Bauer on 12/9/18.
//  Copyright © 2018,2022 George Bauer. All rights reserved.
//

import XCTest
@testable import ScanWWDC

var vcTest: ViewController!

class ScanWWDCUnitTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        vcTest = ViewController()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        vcTest = nil
        super.tearDown()
    }

    //482 ViewController
    func testTruncateURLforDisplay() {
        let str = "/Users/georgebauer/Desktop/Misc/Note.txt"
        let url = URL(fileURLWithPath: str)
        var pathName = ""
        pathName = vcTest.truncateURLforDisplay(url: url, maxLength: 21)
        XCTAssertEqual(pathName, "Desktop/Misc/Note.txt")
        pathName = vcTest.truncateURLforDisplay(url: url, maxLength: 20)
        XCTAssertEqual(pathName, "Desktop/.../Note.txt")
    }

    //107 AttributableStrings (ViewController Extension)
    func testMarkCodeLine() {
        let codeColor     = NSColor.black
        let commentColor  = NSColor(calibratedRed: 0, green: 0.6, blue: 0.15, alpha: 1)  //Green
        let quoteColor    = NSColor.red

        var newLine       = ""
        var inTripleQuote = false

        var codeLine = "//123"
        var inBlockComment  = false
        var marks = vcTest.markCodeLine(codeLine: codeLine, inTripleQuote:  &inTripleQuote, inBlockComment:  &inBlockComment)
        XCTAssertEqual(inBlockComment, false)
        XCTAssertEqual(marks.count, 1)
        XCTAssertEqual(marks[0].index, 0)
        XCTAssertEqual(marks[0].color, commentColor)  //(0, 0.6, 0.15, 1)
        newLine = vcTest.constructLine(codeLine: codeLine, marks: marks)
        XCTAssertEqual(newLine, "<green>//123")

        codeLine = "/*123*/"
        inBlockComment = false
        inTripleQuote  = false
        marks = vcTest.markCodeLine(codeLine: codeLine, inTripleQuote:  &inTripleQuote, inBlockComment:  &inBlockComment)
        XCTAssertEqual(inBlockComment, false)
        XCTAssertEqual(marks.count, 1)
        XCTAssertEqual(marks[0].index, 0)
        XCTAssertEqual(marks[0].color, commentColor)
        newLine = vcTest.constructLine(codeLine: codeLine, marks: marks)
        XCTAssertEqual(newLine, "<green>/*123*/")

        codeLine = "12345"
        inBlockComment = true
        inTripleQuote  = false
        marks = vcTest.markCodeLine(codeLine: codeLine, inTripleQuote:  &inTripleQuote, inBlockComment:  &inBlockComment)
        XCTAssertEqual(inBlockComment, true)
        XCTAssertEqual(marks.count, 1)
        XCTAssertEqual(marks[0].index, 0)
        XCTAssertEqual(marks[0].color, commentColor)
        newLine = vcTest.constructLine(codeLine: codeLine, marks: marks)
        XCTAssertEqual(newLine, "<green>12345")

        codeLine = "1234//8"
        inBlockComment = false
        inTripleQuote  = false
        marks = vcTest.markCodeLine(codeLine: codeLine, inTripleQuote:  &inTripleQuote, inBlockComment:  &inBlockComment)
        XCTAssertEqual(inBlockComment, false)
        XCTAssertEqual(marks.count, 2)
        XCTAssertEqual(marks[0].index, 0)
        XCTAssertEqual(marks[0].color, codeColor)
        XCTAssertEqual(marks[1].index, 4)
        XCTAssertEqual(marks[1].color, commentColor)
        newLine = vcTest.constructLine(codeLine: codeLine, marks: marks)
        XCTAssertEqual(newLine, "<black>1234<green>//8")
        
        codeLine = "/*234*/7"
        inBlockComment = false
        inTripleQuote  = false
        marks = vcTest.markCodeLine(codeLine: codeLine, inTripleQuote:  &inTripleQuote, inBlockComment:  &inBlockComment)
        XCTAssertEqual(inBlockComment, false)
        XCTAssertEqual(marks.count, 2)
        XCTAssertEqual(marks[0].index, 0)
        XCTAssertEqual(marks[0].color, commentColor)
        XCTAssertEqual(marks[1].index, 7)
        XCTAssertEqual(marks[1].color, codeColor)
        newLine = vcTest.constructLine(codeLine: codeLine, marks: marks)
        XCTAssertEqual(newLine, "<green>/*234*/<black>7")

        codeLine = "01\"34\""
        inBlockComment = false
        inTripleQuote  = false
        marks = vcTest.markCodeLine(codeLine: codeLine, inTripleQuote:  &inTripleQuote, inBlockComment:  &inBlockComment)
        XCTAssertEqual(inBlockComment, false)
        XCTAssertEqual(marks.count, 3)
        XCTAssertEqual(marks[0].index, 0)
        XCTAssertEqual(marks[0].color, codeColor)
        XCTAssertEqual(marks[1].index, 2)
        XCTAssertEqual(marks[1].color, quoteColor)
        XCTAssertEqual(marks[2].index, 6)
        XCTAssertEqual(marks[2].color, codeColor)
        newLine = vcTest.constructLine(codeLine: codeLine, marks: marks)
        XCTAssertEqual(newLine, "<black>01<red>\"34\"<black>")

        codeLine = "01\"/*\""
        inBlockComment = false
        inTripleQuote  = false
        marks = vcTest.markCodeLine(codeLine: codeLine, inTripleQuote:  &inTripleQuote, inBlockComment:  &inBlockComment)
        XCTAssertEqual(inBlockComment, false)
        XCTAssertEqual(marks.count, 3)
        XCTAssertEqual(marks[0].index, 0)
        XCTAssertEqual(marks[0].color, codeColor)
        XCTAssertEqual(marks[1].index, 2)
        XCTAssertEqual(marks[1].color, quoteColor)
        XCTAssertEqual(marks[2].index, 6)
        XCTAssertEqual(marks[2].color, codeColor)
        newLine = vcTest.constructLine(codeLine: codeLine, marks: marks)
        XCTAssertEqual(newLine, "<black>01<red>\"/*\"<black>")
    }

    func test_LineItem() {
        let lineItem = LineItem(name: "Name", lineNum: 123, extra: "Extra")
        let desc = lineItem.description
        XCTAssertEqual(desc.count, 27)
        XCTAssertEqual(desc, "\t  \t@ line #\t123\tName\tExtra")
        let lineItem2 = LineItem(name: "Name", lineNum: 123, codeLineCt: 12)
        let desc2 = lineItem2.description
        XCTAssertEqual(desc2.count, 21)
        XCTAssertEqual(desc2, "\t12\t lines @\t123\tName")
    }

    //TODO: test TripleQuote xxx = """
    //11 CodeLineDetails.swift
    func testCodeLineDetailInit() {
        var line = ""
        var codeLineDetail           = CodeLineDetail()
        var inMultiLine: InMultiLine = .none
        line = ##" i = #"xxx\#"## + ##"(myVar)yyy"#"##
        codeLineDetail = CodeLineDetail(fullLine: line, inMultiLine: inMultiLine, lineNum: 0)
        //stripCommentAndQuote(fullLine: line, lineNum: 0, inTripleQuote: &inTripleQuote, inBlockComment: &inBlockComment, inBlockMarkup: &inBlockMarkup)
        XCTAssertEqual(codeLineDetail.codeLine, ##"i = #"~~~~~ myVar ~~~"#"##)

        inMultiLine = .none
        line = ##" i = "xxx\(myVar)yyy""##
        codeLineDetail = CodeLineDetail(fullLine: line, inMultiLine: inMultiLine, lineNum: 0)
        //stripCommentAndQuote(fullLine: line, lineNum: 0, inTripleQuote: &inTripleQuote, inBlockComment: &inBlockComment, inBlockMarkup: &inBlockMarkup)
        XCTAssertEqual(codeLineDetail.codeLine, #"i = "~~~~ myVar ~~~""#)

        inMultiLine = .none
        line = #"""
        print("\"") //ok
        """#
        codeLineDetail = CodeLineDetail(fullLine: line, inMultiLine: inMultiLine, lineNum: 0)
        XCTAssertEqual(codeLineDetail.codeLine, #"print("~~")"#)

        inMultiLine = .none
        line = ##"a=#"1\"2"#"##
        codeLineDetail = CodeLineDetail(fullLine: line, inMultiLine: inMultiLine, lineNum: 0)
        XCTAssertEqual(codeLineDetail.codeLine,##"a=#"~~~~"#"##)

        line = ##"a="1\"2""##
        codeLineDetail = CodeLineDetail(fullLine: line, inMultiLine: inMultiLine, lineNum: 0)
        XCTAssertEqual(codeLineDetail.codeLine,##"a="~~~~""##)

        line = #"print("s\(s)")"#
        codeLineDetail = CodeLineDetail(fullLine: line, inMultiLine: inMultiLine, lineNum: 0)
        XCTAssertEqual(codeLineDetail.codeLine, #"print("~~ s ")"#)
        XCTAssertFalse(codeLineDetail.hasTrailingComment)
        XCTAssertFalse(codeLineDetail.hasEmbeddedComment)
        XCTAssertEqual(codeLineDetail.inMultiLine, InMultiLine.none)    //(codeLineDetail.inBlockComment)

        line = #"a="\n""#
        codeLineDetail = CodeLineDetail(fullLine: line, inMultiLine: inMultiLine, lineNum: 0)
        XCTAssertEqual(codeLineDetail.codeLine, #"a="~~""#)

        line = "//"
        codeLineDetail = CodeLineDetail(fullLine: line, inMultiLine: inMultiLine, lineNum: 0)
        XCTAssertEqual(codeLineDetail.codeLine, "")
        XCTAssertFalse(codeLineDetail.hasTrailingComment)
        XCTAssertFalse(codeLineDetail.hasEmbeddedComment)

        line = "// My Comments"
        codeLineDetail = CodeLineDetail(fullLine: line, inMultiLine: inMultiLine, lineNum: 0)
        XCTAssertEqual(codeLineDetail.codeLine, "")
        XCTAssertFalse(codeLineDetail.hasTrailingComment)
        XCTAssertFalse(codeLineDetail.hasEmbeddedComment)
        
        line = "myVar = false"
        codeLineDetail = CodeLineDetail(fullLine: line, inMultiLine: inMultiLine, lineNum: 0)
        XCTAssertEqual(codeLineDetail.codeLine, line.trim)
        XCTAssertFalse(codeLineDetail.hasTrailingComment)
        XCTAssertFalse(codeLineDetail.hasEmbeddedComment)

        line = "myVar = false    // Comment"
        codeLineDetail = CodeLineDetail(fullLine: line, inMultiLine: inMultiLine, lineNum: 0)
        XCTAssertEqual(codeLineDetail.codeLine, "myVar = false")
        XCTAssertTrue(codeLineDetail.hasTrailingComment)
        XCTAssertFalse(codeLineDetail.hasEmbeddedComment)

        line = #"myVar = "test""#
        codeLineDetail = CodeLineDetail(fullLine: line, inMultiLine: inMultiLine, lineNum: 0)
        XCTAssertEqual(codeLineDetail.codeLine, #"myVar = "~~~~""#)
        XCTAssertFalse(codeLineDetail.hasTrailingComment)
        XCTAssertFalse(codeLineDetail.hasEmbeddedComment)

        line = "myVar = /*embed*/ test"
        codeLineDetail = CodeLineDetail(fullLine: line, inMultiLine: inMultiLine, lineNum: 0)
        XCTAssertEqual(codeLineDetail.codeLine, "myVar =  test")
        XCTAssertFalse(codeLineDetail.hasTrailingComment)
        XCTAssertTrue(codeLineDetail.hasEmbeddedComment)

        line = "#\"You can use \" and \"\\\" in a raw string. Interpolating as \\#(var).\"#"
        line = "#\"123\"#"
        codeLineDetail = CodeLineDetail(fullLine: line, inMultiLine: inMultiLine, lineNum: 0)
        XCTAssertEqual(codeLineDetail.codeLine, "#\"~~~\"#")

        inMultiLine = .blockComment
        line = "myVar = false    // Comment"
        codeLineDetail = CodeLineDetail(fullLine: line, inMultiLine: inMultiLine, lineNum: 0)
        XCTAssertEqual(codeLineDetail.codeLine, "")
        XCTAssertFalse(codeLineDetail.hasTrailingComment)
        XCTAssertFalse(codeLineDetail.hasEmbeddedComment)
        XCTAssertEqual(codeLineDetail.inMultiLine, InMultiLine.blockComment)
        //XCTAssertTrue(codeLineDetail.inBlockComment)

        inMultiLine = .blockComment
        line = "comment*/myVar = false    // Comment"
        codeLineDetail = CodeLineDetail(fullLine: line, inMultiLine: inMultiLine, lineNum: 0)
        XCTAssertEqual(codeLineDetail.codeLine, "myVar = false")
        XCTAssertTrue(codeLineDetail.hasTrailingComment)
        XCTAssertFalse(codeLineDetail.hasEmbeddedComment)
        XCTAssertEqual(codeLineDetail.inMultiLine, InMultiLine.none)
    }

    //186 AnalyseSwift.swift
    /**
     tests for needsContinuation()

     line 2
     line 3

     line 5
 */
    func test_needsContinuation() {
        //let lineNum = 0
        var codeLineDetail = CodeLineDetail()
        var codeLine = ""
        var nextLine = ""
        var result = false

        codeLineDetail.bracketMismatch = 0

        codeLine = "test"
        nextLine = ",next"
        codeLineDetail.codeLine = codeLine
        result = needsContinuation(codeLineDetail: codeLineDetail, nextLine: nextLine, lineNum: 1001)
        XCTAssertTrue(result)

        codeLineDetail.bracketMismatch = 1

        codeLine = "[test"
        nextLine = "next"
        codeLineDetail.codeLine = codeLine
        result = needsContinuation(codeLineDetail: codeLineDetail, nextLine: nextLine, lineNum: 3001)
        XCTAssertFalse(result)

        codeLine = "[test,"
        nextLine = "next"
        codeLineDetail.codeLine = codeLine
        result = needsContinuation(codeLineDetail: codeLineDetail, nextLine: nextLine, lineNum: 4001)
        XCTAssertTrue(result)

        codeLine = "[test"
        nextLine = ",next"
        codeLineDetail.codeLine = codeLine
        result = needsContinuation(codeLineDetail: codeLineDetail, nextLine: nextLine, lineNum: 5001)
        XCTAssertTrue(result)

        codeLine = "test["
        nextLine = "next"
        codeLineDetail.codeLine = codeLine
        result = needsContinuation(codeLineDetail: codeLineDetail, nextLine: nextLine, lineNum: 6001)
        XCTAssertTrue(result)

        codeLine = "func"
        nextLine = "myFunc() {}"
        codeLineDetail.codeLine = codeLine
        result = needsContinuation(codeLineDetail: codeLineDetail, nextLine: nextLine, lineNum: 7001)
        XCTAssertTrue(result)

        codeLine = "class"
        nextLine = "ViewController {}"
        codeLineDetail.codeLine = codeLine
        result = needsContinuation(codeLineDetail: codeLineDetail, nextLine: nextLine, lineNum: 7001)
        XCTAssertTrue(result)
    }

    //157 AnalyseSwift.swift
    func test_getParamNames() {
        //var codeLine = ""
        var result = [String]()

        result = getParamNames(line: "func f(extern intern: Int)", lineNum: -1)
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0], "extern")
        XCTAssertEqual(result[1], "intern")

        result = getParamNames(line: "func f(extern intern: Int, var1: String)", lineNum: -2)
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0], "extern")
        XCTAssertEqual(result[2], "var1")
    }

    func test_extractString() {
        var str = ""
        var result = (remainderLhs: "", extracted: "", remainderRhs: "")

        str = "part1(part2)part3"
        result = extractString(from: str, between: "(", and: ")")
        XCTAssertEqual(result.remainderLhs, "part1")
        XCTAssertEqual(result.extracted,    "part2")
        XCTAssertEqual(result.remainderRhs, "part3")

        str = "part1part2)part3"
        result = extractString(from: str, between: "(", and: ")")
        XCTAssertEqual(result.remainderLhs, str)
        XCTAssertEqual(result.extracted,    "")
        XCTAssertEqual(result.remainderRhs, "")

        str = "part1(part2part3"
        result = extractString(from: str, between: "(", and: ")")
        XCTAssertEqual(result.remainderLhs, "part1")
        XCTAssertEqual(result.extracted,    "part2part3")
        XCTAssertEqual(result.remainderRhs, "")
    }

    func test_SplitLineAtChar() {
        var tuple = ("","")
        tuple = splitLine("0123435", atFirst: "3")
        XCTAssertEqual(tuple.0, "012")
        XCTAssertEqual(tuple.1, "435")
    }

    func test_SplitLineAtInt() {
        var tuple = ("","")
        tuple = splitLine("0123435", atInt: 3)
        XCTAssertEqual(tuple.0, "012")
        XCTAssertEqual(tuple.1, "3435")
    }

    func test_analyseSwiftSample() {

        guard let samplePath = Bundle.main.path(forResource: "SampleCode", ofType: "txt") else {
            XCTAssertTrue(false)
            return
        }
        let fileAtt = FileAttributes.getFileInfo(samplePath)
        let contentOpt =  try? String(contentsOfFile: samplePath)
        guard let content = contentOpt else {
            XCTAssertTrue(false)
            return
        }
        let swSumry = analyseSwiftFile(contentFromFile: content, selecFileInfo: fileAtt, deBug: true)
        XCTAssertEqual(swSumry.fileName, "SampleCode.txt")
        XCTAssertEqual(swSumry.copyright.hasPrefix("Copyright"), true)
        XCTAssertEqual(swSumry.copyright.hasSuffix("reserved."), true)
        XCTAssertEqual(swSumry.createdBy.contains("George Bauer"), true)

        XCTAssertEqual(swSumry.codeLineCount, 85)
        XCTAssertEqual(swSumry.continueLineCount, 8)
        XCTAssertEqual(swSumry.blankLineCount, 37)
        XCTAssertEqual(swSumry.commentLineCount, 22)
        XCTAssertEqual(swSumry.totalLineCount, 143)

        XCTAssertEqual(swSumry.imports.count, 1)
        XCTAssertEqual(swSumry.imports[0].name, "Cocoa")

        XCTAssertEqual(swSumry.nTrailing, 4)
        XCTAssertEqual(swSumry.nEmbedded, 2)

        XCTAssertEqual(swSumry.dictIssues.count, 7)
        if let fuIssue = swSumry.dictIssues["ForceUnwrap"] {
            XCTAssertEqual(fuIssue.identifier, "ForceUnwrap")
            XCTAssertEqual(fuIssue.items.count, 10)
            XCTAssertEqual(fuIssue.items[2].name, "content!")

        } else {
            XCTAssertTrue(false, "dictIssues[\"ForceUnwrap\"] is nil")
        }

    }


    //284 AnalyseSwift.swift
    func test_analyseSwiftFile_Long() {
        let fileAtt = FileAttributes(url: URL(fileURLWithPath: "/????"), name: "sampleCodeLong", creationDate: Date(), modificationDate: Date(), size: 1234, isDir: false)
        let swSumry = analyseSwiftFile(contentFromFile: sampleCodeLong, selecFileInfo: fileAtt, deBug: true)
        XCTAssertEqual(swSumry.byteCount,   1234, "")
        //XCTAssertEqual(swSumry.classNames.count,   1, "")
        //if !swSumry.classNames.isEmpty { XCTAssertEqual(swSumry.classNames[0], "MySampleClass", "")}
        //XCTAssertEqual(swSumry.enumNames.count,   0, "")
        //XCTAssertEqual(swSumry.enumNames[0], "SortType", "")
        //XCTAssertEqual(swSumry.extensionNames.count,   0, "")
        //XCTAssertEqual(swSumry.extensionNames[0], "ViewController", "")
        XCTAssertEqual(swSumry.fileName, "sampleCodeLong", "")
        //XCTAssertEqual(swSumry.funcs.count,    5, "")
        XCTAssertEqual(swSumry.codeLineCount, 72, "")
        let vnCt = swSumry.dictIssues[RuleID.varNaming]?.items.count ?? 0
        XCTAssertEqual(vnCt, 14, "")    //Varies with NameLenMaxV
        let fuCt = swSumry.dictIssues[RuleID.forceUnwrap]?.items.count ?? 0
        XCTAssertEqual(fuCt,  15, "")
        XCTAssertEqual(swSumry.vbCompatCalls.count,  2, "")
        XCTAssertEqual(swSumry.vbCompatFileCalls.count,  1, "")
        XCTAssertEqual(swSumry.vbCompatStringCalls.count,  1, "")
        print(swSumry.codeLineCount)
        //SampleCode.swift                89       13        15        3      -
    }

    //284 AnalyseSwift.swift
    func test_analyseSwiftFile_Short() {
        let fileAtt = FileAttributes(url: URL(fileURLWithPath: "/????"), name: "sampleCodeShort", creationDate: Date(), modificationDate: Date(), size: 1234, isDir: false)
        let swSumry = analyseSwiftFile(contentFromFile: sampleCodeShort, selecFileInfo: fileAtt, deBug: true)
        XCTAssertEqual(swSumry.byteCount,   1234, "")

//        XCTAssertEqual(swSumry.classNames.count,     1, "")
//        if !swSumry.classNames.isEmpty { XCTAssertEqual(swSumry.classNames[0], "ViewController", "")}
//
//        XCTAssertEqual(swSumry.enumNames.count,      1, "")
//        if !swSumry.enumNames.isEmpty { XCTAssertEqual(swSumry.enumNames[0], "Enum1", "")}
//
//        XCTAssertEqual(swSumry.extensionNames.count, 1, "")
//        if !swSumry.extensionNames.isEmpty { XCTAssertEqual(swSumry.extensionNames[0], "ViewController", "") }
//
//        //funcs
//        //XCTAssertEqual(swSumry.funcs.count,          2, "")
//        if !swSumry.funcs.isEmpty   { XCTAssertEqual(swSumry.funcs[0].name, "ViewController.MyFuncVC", "")}
//        if swSumry.funcs.count >= 2 { XCTAssertEqual(swSumry.funcs[1].name, "MyFreeFunc", "")}

        // ibActionFuncs
//        XCTAssertEqual(swSumry.ibActionFuncs.count,          1, "")
//        if !swSumry.ibActionFuncs.isEmpty   { XCTAssertEqual(swSumry.ibActionFuncs[0].name, "saveInfoClicked", "")}
/*
         var codeLineCount     = 0   // includes compound line & "if x {code}"   384 -> 400
         var continueLineCount = 0
         var blankLineCount    = 0   // empty line or a single curly on line     162 -> 165
         var commentLineCount  = 0   // entire line is a comment or part of block comment
         var quoteLineCount    = 0
         var markupLineCount   = 0
         var compoundLineCount = 0
         var totalLineCount    = 0
 */
        // codeLine
        XCTAssertEqual(swSumry.codeLineCount,      25, "codeLineCount != 25") //was 21

        // continueLineCount
        XCTAssertEqual(swSumry.continueLineCount,   5, "continueLineCount != 5") // was 2

        // blankLineCount
        XCTAssertEqual(swSumry.blankLineCount,     13, "blankLineCount != 13") // was 11

        // commentLineCount
        XCTAssertEqual(swSumry.commentLineCount,    3, "commentLineCount != 3")

        // quoteLineCount
        XCTAssertEqual(swSumry.quoteLineCount,      3, "quoteLineCount != 3")

        // markupLineCount
        XCTAssertEqual(swSumry.markupLineCount,     3, "markupLineCount != 3")

        // compoundLineCount
        XCTAssertEqual(swSumry.compoundLineCount,   2, "compoundLineCount != 2")

        // totalLineCount
        let total = swSumry.codeLineCount + swSumry.continueLineCount +
            swSumry.blankLineCount + swSumry.commentLineCount + swSumry.quoteLineCount +
            swSumry.markupLineCount - swSumry.compoundLineCount
        //FIXME: Sums off by 1
        //XCTAssertEqual(swSumry.totalLineCount,      total, "totalLineCount != \(total)")

        // nonCamelCases
        //XCTAssertEqual(swSumry.nonCamelVars.count,  9, "")
        let vnCt = swSumry.dictIssues[RuleID.varNaming]?.items.count ?? 0
        XCTAssertEqual(vnCt, 9, "")

        // forceUnwraps.count
        let forceUnwrapCount = swSumry.getIssueCount(identifier: RuleID.forceUnwrap)
        XCTAssertEqual(forceUnwrapCount,  4, "")

        // vbCompatCalls.count
        XCTAssertEqual(swSumry.vbCompatCalls.count, 1, "")
    }

/* Still needed in sampleCodeShort
      OverrideFunc   = 3-
      isProtocol     = 8-
Markup
tripleQuote
RawString
 */

    // 31 Keywords.swift
    func testisKeyword() {
        var result = false
        result = WordLookup.isKeyword(word: "let")
        XCTAssertTrue(result)
        result = WordLookup.isKeyword(word: "super")
        XCTAssertTrue(result)

        result = WordLookup.isKeyword(word: "Let")
        XCTAssertFalse(result)
        result = WordLookup.isKeyword(word: "gwb")
        XCTAssertFalse(result)
    }

    // MenuRulesVC.swift

    // MARK: - Sample Data

        let sampleCodeShort = ###"""
    // Comment Line #1
    enum Expect1: String {
    case short, soShort,
    finalShort
    }
    enum Expect2: String { case short, soShort,
    veryShort, prettyShort,
    finalShort }

    class ViewController: NSViewController, NSWindowDelegate {  //1
        private enum Enum1 {                                    //2 enum
            case: case1, case2, case3                           //3
        }
    /// Markup for MyFuncVC
        private func MyFuncVC(Extern Intern: Int,
                            a: String,
                            bb: Double) {    //4  4-Camel
            guard let Bb = bb else { return }                   //5,6  1-Camel ???
            if let a = bb {                                     //7  1-Camel ???
                let Bc = bb!                                    //8  1-Camel 1-UnWrap
                let cc = CInt("12")                             //9  1-VB
            }
        }
    }
    /*
    Block Comment Line #2
    */
    /*Block Comment Line #3*/
    public struct SwiftSummary {                                //10
        var Camel = 0                                           //11  1-Camel
    }
    /**
    Markup for MyFreeFunc
    */
    func MyFreeFunc() -> Int {                                  //12  1-Camel
        let aa = fake(a1: bb!, a2: dd!, ff! )                   //13  3-Unwrap
        aa=0; bb=1; cc=2                                        //14,15,16
        return 0                                                //17
    }

    extension ViewController: NSTableViewDelegate {             //18
        @IBOutlet weak var tableView:    NSTableView!           //19
        @IBAction func saveInfoClicked(_ sender: Any) {         //20
        }
    }//not a codeLine
    let myQuote = """
    quoteLine #1
    quoteLine #2
    """
    """###

    let sampleWWDC =
    """
    help
    WWDC 2017 Videos
    App Frameworks Design Developer Tools Distribution Featured Graphics and Games Media System Frameworks
    Featured Videos
    Platforms State of the Union
    Platforms State of the Union
    iOS, macOS, tvOS, watchOS
    WWDC 2017 Platforms State of the Union
    Introducing Core ML
    Introducing Core ML
    iOS, macOS, tvOS, watchOS
    Machine learning opens up opportunities for creating new and engaging experiences. Core ML is a...
    Introducing ARKit: Augmented Reality for iOS
    Introducing ARKit: Augmented Reality for iOS
    iOS
    ARKit provides a cutting-edge platform for developing augmented reality (AR) apps for iPhone and...
    """

    let sampleCodeLong = #"""
//
//  SampleCode.swift
//  AnalyseSwiftCode
//
//  Created by George Bauer on 1/10/18.
//  Copyright © 2018,2019 George Bauer. All rights reserved.
//

import Cocoa    /* ????? partial-line Block Comment does not work.*/
/* single-line Block Comment does work. */

/* To generate compiler warnings:
 #warning("This code is incomplete.")
 */

let raw = *"12"3"*
private func DoForceUnwrap() {
    var dict = [String: String]()
    dict["as!"] = "as!"
    let val = dict["as!"]!
    print(val)

    let content = FileManager.default.contents(atPath: "")
    let contentAsString = String(data: content!, encoding: String.Encoding.utf8)
    print(contentAsString!)

    let attributes = try! FileManager.default.attributesOfItem(atPath: "123")

    var key = FileAttributeKey(rawValue: "NSFileType")
    let str = attributes[key] as! String

    key = FileAttributeKey(rawValue: "NSFileModificationDate")
    let date = attributes[key] as! Date

    key = FileAttributeKey(rawValue: "NSFileSize")
    let int = attributes[key] as! Int

    print(str, date, int)
}

/// This is a single-line Mark-up
private func DoCamelCase(p1: Int, p2: Int , Param3:String) {
    let n, Bad1:   Int
    var i,j_bad2:  Int      //?????
    var k , Bad3 : Int      //?????
    let Bad4 = ""
    let Bad5=0
    let Bad6:String
    n=0;i=0;k=0; Bad1=0; j_bad2=0; Bad3=0; Bad6=""      // To avoid warnings
    print(n,Bad1,i,j_bad2,k,Bad3,Bad4,Bad5,Bad6)        // To avoid warnings
    if !Param3.contains("//") && !Param3.contains("/*") && !Param3.contains("*/") {} //ok
    let comps = "1 22 333 4444".components(separatedBy: " ")
    print(comps.first!)
    print(comps.last! )
    print("\"") //ok
}

/**
This is a Block Mark-up
*/
private func sampleVBCall() {
    var i = CInt("123")
    print(i)
    let str = "12345"
    var a = ""
    a = Mid(str, 2, 3)
    a = VB.Left(str, 2)
    i = FreeFile()
    print(a)
}

//not used
private func testNSString() {
    //  Created by Steven Lipton on 10/18/14.
    //  Revised Swift 3.0 7/1/16
    //  Copyright (c) 2014,2016 MakeAppPie.Com. All rights reserved.

    let myString = "P is Pizza and Pizza is me"

    //: Initialize the Mutable Attributed String
    let myMuAttString = NSMutableAttributedString( string: myString,
                                                   attributes: [NSAttributedString.Key.font: NSFont(name: "Georgia", size: 18.0)!])

    //: Add more attributes here: Make the first Pizza in chalkduster 24 point
    myMuAttString.addAttribute(NSAttributedString.Key.font,
                               value: NSFont(name: "Chalkduster",  size: 24.0)!,
                               range: NSRange(location: 9, length: 5))

    //: Make a big blue P
    myMuAttString.addAttribute(NSAttributedString.Key.font,
                               value: NSFont(name: "AmericanTypewriter-Bold", size: 36.0)!,
                               range: NSRange(location:0, length:1))
    myMuAttString.addAttribute(NSAttributedString.Key.foregroundColor,
                               value: NSColor.blue,
                               range: NSRange(location:0, length:1))

    //: Make the second pizza red and outlined in Helvetica Neue
    myMuAttString.addAttribute(NSAttributedString.Key.font,
                               value: NSFont(name: "Helvetica Neue", size: 36.0)!,
                               range: NSRange(location: 19, length: 5))

    myMuAttString.addAttribute(NSAttributedString.Key.strokeColor,
                               value: NSColor.red,
                               range:  NSRange(location: 19, length: 5))

    myMuAttString.addAttribute(NSAttributedString.Key.strokeWidth,
                               value: 4,
                               range: NSRange(location: 19, length: 5))

    //: Set the background color is attributes text.
    //: which is not the color of the background text.
    let  stringLength = myString.count
    myMuAttString.addAttribute(NSAttributedString.Key.backgroundColor,
                               value: NSColor.magenta,
                               range: NSRange(location: 0, length: stringLength))

    //: Add a Drop Shadow

    //: Make the Drop Shadow
    let shadow = NSShadow()
    shadow.shadowOffset = CGSize(width: 5, height: 5)
    shadow.shadowBlurRadius = 5
    shadow.shadowColor = NSColor.gray

    //: Add a drop shadow to the text
    myMuAttString.addAttribute(NSAttributedString.Key.shadow,
                               value: shadow,
                               range: NSRange(location: 27, length: 7))

    //:Change to 48 point Menlo
    myMuAttString.addAttribute(NSAttributedString.Key.font,
                               value: NSFont(name: "Menlo", size: 48.0)!,
                               range: NSRange(location: 27, length: 7))

    //: Appending the String with !!! and an Attributed String
    let myAddedStringAttributes:[NSAttributedString.Key:Any]? = [
        NSAttributedString.Key.font: NSFont(name: "AvenirNext-Heavy", size: 48.0)!,
        NSAttributedString.Key.foregroundColor: NSColor.red,
        NSAttributedString.Key.shadow: shadow
    ]
    let myAddedString = NSAttributedString(string: "!!!", attributes: myAddedStringAttributes)
    myMuAttString.append(myAddedString)
}//end func testNSString

class MySampleClass {
    static public func HW() {
        print("😀Hello World!😀")
    }
}

struct MySampleStruct {
    let i = 0
}


"""#


//---------------------------------------

    //    func testPerformanceExample() {
    //        // This is an example of a performance test case.
    //        self.measure {
    //            // Put the code you want to measure the time of here.
    //        }
    //    }

}
