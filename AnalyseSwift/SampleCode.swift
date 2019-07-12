/*
 eNum RuleType {case flagProductName = 0, allowAllCaps=1, etc
 */
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

//FIXME: This is a test FixMe.
//TODO: This is a test ToDo.

enum Enum1 { case Good, Bad, Ugly }
enum enum2
{   case goodGuy
    case BadBoy
}
enum EnumStatic {
    static let good = 1
    static let Bad = 2
}
enum Building    { case skyscraper(floors: Int) }
enum Planet: Int {
    case mercury = 1
    case venus
}
enum Activity {
    case bored
    case running(destination: String)
    case Singing(Volume: Int)
}

var myGlobalTestVar = 0
private func doNothing() { print("Do Nothing") }

private func interpolate() {
    let myVar = "14"
    print("xxx\(Int(myVar)!)yyy")
    print(#"xxx\#(myVar)yyy"#)
}

private func doForceUnwrap() {
    var dict = [String: String]()
    dict["as!"] = "as!"
    let val = dict["as!"]!
    print(val)

    let content = FileManager.default.contents(atPath: "")
    let contentAsString = String(data: content!, encoding: String.Encoding.utf8)
    print(contentAsString!)

    let attributes = try! FileManager.default.attributesOfItem(atPath: "123")

    let key = FileAttributeKey(rawValue: "NSFileType")
    let str = attributes[key] as! String

    print(str)
}//end func

private func DoCamelCase(p1: Int, p2: Int , Param3:String) {
    let n, Bad1:   Int
    var i,j_bad2:  Int      //?????
    var k2 , Bad3 : Int      //?????
    let Bad4 = ""
    let Bad5=0
    var Bad6:String = "Bad666", Bad7 = "7"
    n=0;i=0;k2=0; Bad1=0; j_bad2=0; Bad3=0; Bad6=""      // To avoid warnings
    print(n,Bad1,i,j_bad2,k2,Bad3,Bad4,Bad5,Bad6,Bad7)        // To avoid warnings
    if !Param3.contains("//") && !Param3.contains("/*") && !Param3.contains("*/") {} //ok
    let comps = "1 22 333 4444".components(separatedBy: " ")
    print(comps.first!)
    print("\"") //ok
}

private func sampleVBCall() {
    var i2 = CInt("123")
    print(i2)
    let str = "12345"
    var a = ""
    a = Mid(str, 2, 3)
    a = Mid(str, 2)
    a = VB.Left(str, 2)
    a = vbCr
    i2 = FreeFile()
    MsgBox(str)
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

    myMuAttString.addAttribute(NSAttributedString.Key.font,
                               value: NSFont(name: "Chalkduster",  size: 24.0)!,
                               range: NSRange(location: 9, length: 5))

    //: Set the background color is attributes text.
    //: which is not the color of the background text.
    let  stringLength = myString.count
    myMuAttString.addAttribute(NSAttributedString.Key.backgroundColor,
                               value: NSColor.magenta,
                               range: NSRange(location: 0, length: stringLength))

    //: Appending the String with !!! and an Attributed String
    let myAddedStringAttributesLong:[NSAttributedString.Key:Any]? = [
        NSAttributedString.Key.font: NSFont(name: "AvenirNext-Heavy", size: 48.0)!,
        NSAttributedString.Key.foregroundColor: NSColor.red,
    ]
    let myAddedString = NSAttributedString(string: "!!!", attributes: myAddedStringAttributesLong)
    myMuAttString.append(myAddedString)
}//end func testNSString

class MySampleClass {
    static public func HW() {
        print("😀Hello World!😀")
    }
}

struct MySampleStruct {
    let i44 = 0
}

