//
//  AnalyseSwiftCodeTests.swift
//  AnalyseSwiftCodeTests
//
//  Created by George Bauer on 12/8/18.
//  Copyright © 2018 Ray Wenderlich. All rights reserved.
//

import XCTest
@testable import AnalyseSwiftCode

class AnalyseSwiftCodeTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSplitLineAtIntIndex() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let codeLine = "code//line"
        let (code, comment) = splitLineAtIntIndex(codeLine: codeLine, indexInt: 4)
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
