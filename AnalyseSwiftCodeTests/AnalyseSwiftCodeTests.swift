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

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let codeLine = "code//line"
        let (code, comment) = splitLineAtIntIndex(codeLine: codeLine, indexInt: 4)
        XCTAssertEqual(code, "code")
        XCTAssertEqual(comment, "//line")
    }

//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
