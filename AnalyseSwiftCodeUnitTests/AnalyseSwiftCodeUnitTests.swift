//
//  AnalyseSwiftCodeUnitTests.swift
//  AnalyseSwiftCodeUnitTests
//
//  Created by George Bauer on 12/9/18.
//  Copyright © 2018 Ray Wenderlich. All rights reserved.
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

    func testTruncateURL() {
        let str = "/Users/georgebauer/Desktop/Misc/Note.txt"
        let url = URL(fileURLWithPath: str)
        var pathName = ""
        pathName = vcTest.truncateURL(url: url, maxLength: 21)
        XCTAssertEqual(pathName, "Desktop/Misc/Note.txt")
        pathName = vcTest.truncateURL(url: url, maxLength: 20)
        XCTAssertEqual(pathName, "Desktop/.../Note.txt")
    }

    func testSplitLineAtIntIndex() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let codeLine = "code//line"
        let (code, comment) = vcTest.splitLineAtIntIndex(codeLine: codeLine, indexInt: 4)
        XCTAssertEqual(code, "code")
        XCTAssertEqual(comment, "//line")
    }

    func testSplitLineAtIndex() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let codeLine = "code//line"
        let index = codeLine.range(of: "//")!.lowerBound
        let (code, comment) = vcTest.splitLineAtIndex(codeLine: codeLine, splitIndex: index)
        XCTAssertEqual(code, "code")
        XCTAssertEqual(comment, "//line")
    }

    private func TestCamelCase(p1: Int, p2 : Int , Param3:String) {
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


    //    func testPerformanceExample() {
    //        // This is an example of a performance test case.
    //        self.measure {
    //            // Put the code you want to measure the time of here.
    //        }
    //    }

}
