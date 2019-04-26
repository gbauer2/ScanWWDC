//
//  AnalyseSwiftCodeUnitTests.swift
//  AnalyseSwiftCodeUnitTests
//
//  Created by George Bauer on 12/9/18.
//  Copyright © 2018,2019 George Bauer. All rights reserved.
//

import XCTest
@testable import AnalyseSwiftCode

var vcTest: ViewController!

class AnalyseSwiftCodeUnitTests: XCTestCase {

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

    //481 ViewController
    func testTruncateURLforDisplay() {
        let str = "/Users/georgebauer/Desktop/Misc/Note.txt"
        let url = URL(fileURLWithPath: str)
        var pathName = ""
        pathName = vcTest.truncateURLforDisplay(url: url, maxLength: 21)
        XCTAssertEqual(pathName, "Desktop/Misc/Note.txt")
        pathName = vcTest.truncateURLforDisplay(url: url, maxLength: 20)
        XCTAssertEqual(pathName, "Desktop/.../Note.txt")
    }

    //203 ViewController
    func testremoveQuotedStuff() {
        var str = ""
        var result = ""
        str = "abcd 1234"
        result = removeQuotedStuff(str)
        XCTAssertEqual(result, str)
        str = "abc\"\"123"
        result = removeQuotedStuff(str)
        XCTAssertEqual(result, str)
        str = "abc\"def\"123"
        result = removeQuotedStuff(str)
        XCTAssertEqual(result, "abc\"~~~\"123")
        str = "abc\"d\\\"ef\"123"
        result = removeQuotedStuff(str)
        XCTAssertEqual(result, "abc\"~~~~~\"123")
    }

    //107 AttributableStrings
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

    func testStripCommentAndQuote() {
        var line = ""
        var codeLine = ""
        var hasTrailing = false
        var hasEmbedded = false
        var inBlockComment = false
        var inTripleQuote  = false

        inBlockComment = false
        line = #"print("s\(s)")"#
        (codeLine, hasTrailing, hasEmbedded) = stripCommentAndQuote(fullLine: line, lineNum: 0, inTripleQuote: &inTripleQuote, inBlockComment: &inBlockComment)
        XCTAssertEqual(codeLine, #"print("~~~~~")"#)
        XCTAssertFalse(hasTrailing)
        XCTAssertFalse(hasEmbedded)
        XCTAssertFalse(inBlockComment)

        line = "//"
        (codeLine, hasTrailing, hasEmbedded) = stripCommentAndQuote(fullLine: line, lineNum: 0, inTripleQuote: &inTripleQuote, inBlockComment: &inBlockComment)
        XCTAssertEqual(codeLine, line.trim)
        XCTAssertFalse(hasTrailing)
        XCTAssertFalse(hasEmbedded)

        line = "myVar = false"
        (codeLine, hasTrailing, hasEmbedded) = stripCommentAndQuote(fullLine: line, lineNum: 0, inTripleQuote: &inTripleQuote, inBlockComment: &inBlockComment)
        XCTAssertEqual(codeLine, line.trim)
        XCTAssertFalse(hasTrailing)
        XCTAssertFalse(hasEmbedded)

        line = "myVar = false    // Comment"
        (codeLine, hasTrailing, hasEmbedded) = stripCommentAndQuote(fullLine: line, lineNum: 0, inTripleQuote: &inTripleQuote, inBlockComment: &inBlockComment)
        XCTAssertEqual(codeLine, "myVar = false")
        XCTAssertTrue(hasTrailing)
        XCTAssertFalse(hasEmbedded)

        line = #"myVar = "test""#
        (codeLine, hasTrailing, hasEmbedded) = stripCommentAndQuote(fullLine: line, lineNum: 0, inTripleQuote: &inTripleQuote, inBlockComment: &inBlockComment)
        XCTAssertEqual(codeLine, #"myVar = "~~~~""#)
        XCTAssertFalse(hasTrailing)
        XCTAssertFalse(hasEmbedded)

        line = "myVar = /*embed*/ test"
        (codeLine, hasTrailing, hasEmbedded) = stripCommentAndQuote(fullLine: line, lineNum: 0, inTripleQuote: &inTripleQuote, inBlockComment: &inBlockComment)
        XCTAssertEqual(codeLine, "myVar =  test")
        XCTAssertFalse(hasTrailing)
        XCTAssertTrue(hasEmbedded)

        line = "#\"You can use \" and \"\\\" in a raw string. Interpolating as \\#(var).\"#"
        line = "#\"123\"#"
        (codeLine, hasTrailing, hasEmbedded) = stripCommentAndQuote(fullLine: line, lineNum: 0, inTripleQuote: &inTripleQuote, inBlockComment: &inBlockComment)
        XCTAssertEqual(codeLine, "#\"~~~\"#")

        inBlockComment = true
        line = "myVar = false    // Comment"
        (codeLine, hasTrailing, hasEmbedded) = stripCommentAndQuote(fullLine: line, lineNum: 0, inTripleQuote: &inTripleQuote, inBlockComment: &inBlockComment)
        XCTAssertEqual(codeLine, "")
        XCTAssertFalse(hasTrailing)
        XCTAssertFalse(hasEmbedded)
        XCTAssertTrue(inBlockComment)

        line = "comment*/myVar = false    // Comment"
        (codeLine, hasTrailing, hasEmbedded) = stripCommentAndQuote(fullLine: line, lineNum: 0, inTripleQuote: &inTripleQuote, inBlockComment: &inBlockComment)
        XCTAssertEqual(codeLine, "myVar = false")
        XCTAssertTrue(hasTrailing)
        XCTAssertFalse(hasEmbedded)
        XCTAssertFalse(inBlockComment)
    }

    func testAnalyseSwiftFile() {
        let fileAtt = FileAttributes(url: URL(fileURLWithPath: "/????"), name: "????", creationDate: Date(), modificationDate: Date(), size: 1234, isDir: false)
        let (sw, _) = analyseSwiftFile(contentFromFile: sampleCode, selecFileInfo: fileAtt, deBug: true)
        XCTAssertEqual(sw.byteCount,   1234, "")
        XCTAssertEqual(sw.classNames.count,   1, "")
        XCTAssertEqual(sw.classNames[0], "MySampleClass", "")
        XCTAssertEqual(sw.enumNames.count,   0, "")
        //XCTAssertEqual(sw.enumNames[0], "SortType", "")
        XCTAssertEqual(sw.extensionNames.count,   0, "")
        //XCTAssertEqual(sw.extensionNames[0], "ViewController", "")
        XCTAssertEqual(sw.fileName, "????", "")
        XCTAssertEqual(sw.funcs.count,    5, "")
        XCTAssertEqual(sw.codeLineCount, 89, "")
        XCTAssertEqual(sw.nonCamelCases.count, 13, "")
        XCTAssertEqual(sw.forceUnwraps.count,  15, "")
        XCTAssertEqual(sw.vbCompatCalls.count,  3, "")
        print(sw.codeLineCount)
        //SampleCode.swift                89       13        15        3      -
    }

    func testisKeyword() {
        var result = false
        result = isKeyword(word: "let")
        XCTAssertTrue(result)
        result = isKeyword(word: "super")
        XCTAssertTrue(result)

        result = isKeyword(word: "Let")
        XCTAssertFalse(result)
        result = isKeyword(word: "gwb")
        XCTAssertFalse(result)
    }

    func testCR() {
        //Int
        var cr = CR(tag: 1, idx: 64, name: "Sample # 1 Int", key: "", helpMsg: "This is a test", dfault: "12.33", int: 1234, minV: 1232, maxV: 1235, dp: 2)
        XCTAssertEqual(cr.bitVal,       1)
        XCTAssertEqual(cr.name,         "Sample # 1 Int")
        XCTAssertEqual(cr.type,         .int)
        XCTAssertEqual(cr.keyUsrDefault, "RuleSample1Int")
        XCTAssertEqual(cr.msgError,     "Must be a value beween 12.32 and 12.35")
        XCTAssertEqual(cr.intVal,       1234)
        XCTAssertEqual(cr.textVal,      "12.34")

        //Text
        var cs = CR(tag: 2, idx: 10, name: "Samp # 2", key: "SampNo2", helpMsg: "Test 2", errMsg: "MyBad", dfault: "default", txt: "Samp2Data")
        XCTAssertEqual(cs.bitVal,       1024)
        XCTAssertEqual(cs.name,         "Samp # 2")
        XCTAssertEqual(cs.type,         .text)
        XCTAssertEqual(cs.keyUsrDefault, "RuleSampNo2")
        XCTAssertEqual(cs.msgError,     "MyBad")
        XCTAssertEqual(cs.textVal,      "Samp2Data")

        //bool
        var cb = CR(tag: 3, idx: 63, name: "Samp$ # 3", key: "", helpMsg: "Test 3", dfault: "true", bool: true)
        XCTAssertEqual(cb.bitVal, 9_223_372_036_854_775_808)
        XCTAssertEqual(cb.name,         "Samp$ # 3")
        XCTAssertEqual(cb.type,         .bool)
        XCTAssertEqual(cb.keyUsrDefault, "RuleSamp3")
        XCTAssertEqual(cb.msgError,     "")
        XCTAssertEqual(cb.boolVal,      true)
        XCTAssertEqual(cb.textVal,      "true")

        cr.intVal = 4321
        cb.boolVal = false
        cs.textVal = "New Text"
    }

    // MARK: - Sample Data

    private func camelCase(p1: Int, p2: Int , Param3:String) {
        let n, Bad1:   Int
        var i,j_bad2:  Int      //?????
        var k , Bad3 : Int      //?????
        let Bad4 = ""
        let Bad5=0
        let Bad6:String
        n=0;i=0;k=0; Bad1=0; j_bad2=0; Bad3=0; Bad6=""      // To avoid warnings
        print(n,Bad1,i,j_bad2,k,Bad3,Bad4,Bad5,Bad6)        // To avoid warnings
        if !Param3.contains("//") && !Param3.contains("/*") && !Param3.contains("*/") {} //ok
        print("\"") //ok
    }

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

    let sampleCode = """
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

private func sampleVBCall() {
    let i = CInt("123")
    print(i)
    let str = "12345"
    var a = ""
    a = Mid(str, 2, 3)
    a = VB.Left(str, 2)
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


"""

    //    func testPerformanceExample() {
    //        // This is an example of a performance test case.
    //        self.measure {
    //            // Put the code you want to measure the time of here.
    //        }
    //    }

}
