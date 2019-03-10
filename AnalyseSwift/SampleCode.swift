//
//  SampleCode.swift
//  AnalyseSwiftCode
//
//  Created by George Bauer on 1/10/18.
//  Copyright © 2018 George Bauer. All rights reserved.
//

import Cocoa    /* ????? partial-line Block Comment does not work.*/
/* single-line Block Comment does work. */

/* To generate compiler warnings:
 #warning("This code is incomplete.")
 */

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
    let comps = "1 22 333 4444".components(separatedBy: " ")
    print(comps.first!)
    print(comps.last! )
    print("\"") //ok
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

class xxx {
    static public func HW() {
        print("😀Hello World!😀")
    }
}

