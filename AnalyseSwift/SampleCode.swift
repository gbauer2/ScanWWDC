//
//  SampleCode.swift
//  AnalyseSwiftCode
//
//  Created by George Bauer on 1/10/18.
//  Copyright © 2018 George Bauer. All rights reserved.
//

import Cocoa

//not used
private func testNSString() {
    //  Created by Steven Lipton on 10/18/14.
    //  Revised Swift 3.0 7/1/16
    //  Copyright (c) 2014,2016 MakeAppPie.Com. All rights reserved.

    let myString = "P is for Pizza and Pizza is for me"

    //: Initialize the Mutable Attributed String
    let myMuAttString = NSMutableAttributedString( string: myString,
                                                   attributes: [NSAttributedStringKey.font: NSFont(name: "Georgia", size: 18.0)!])

    //: Add more attributes here: Make the first Pizza in chalkduster 24 point
    myMuAttString.addAttribute(NSAttributedStringKey.font,
                               value: NSFont(name: "Chalkduster",  size: 24.0)!,
                               range: NSRange(location: 9, length: 5))

    //: Make a big blue P
    myMuAttString.addAttribute(NSAttributedStringKey.font,
                               value: NSFont(name: "AmericanTypewriter-Bold", size: 36.0)!,
                               range: NSRange(location:0, length:1))
    myMuAttString.addAttribute(NSAttributedStringKey.foregroundColor,
                               value: NSColor.blue,
                               range: NSRange(location:0, length:1))

    //: Make the second pizza red and outlined in Helvetica Neue
    myMuAttString.addAttribute(NSAttributedStringKey.font,
                               value: NSFont(name: "Helvetica Neue", size: 36.0)!,
                               range: NSRange(location: 19, length: 5))

    myMuAttString.addAttribute(NSAttributedStringKey.strokeColor,
                               value: NSColor.red,
                               range:  NSRange(location: 19, length: 5))

    myMuAttString.addAttribute(NSAttributedStringKey.strokeWidth,
                               value: 4,
                               range: NSRange(location: 19, length: 5))

    //: Set the background color is attributes text.
    //: which is not the color of the background text.
    let  stringLength = myString.count
    myMuAttString.addAttribute(NSAttributedStringKey.backgroundColor,
                               value: NSColor.magenta,
                               range: NSRange(location: 0, length: stringLength))

    //: Add a Drop Shadow

    //: Make the Drop Shadow
    let shadow = NSShadow()
    shadow.shadowOffset = CGSize(width: 5, height: 5)
    shadow.shadowBlurRadius = 5
    shadow.shadowColor = NSColor.gray

    //: Add a drop shadow to the text
    myMuAttString.addAttribute(NSAttributedStringKey.shadow,
                               value: shadow,
                               range: NSRange(location: 27, length: 7))

    //:Change to 48 point Menlo
    myMuAttString.addAttribute(NSAttributedStringKey.font,
                               value: NSFont(name: "Menlo", size: 48.0)!,
                               range: NSRange(location: 27, length: 7))

    //: Appending the String with !!! and an Attributed String
    let myAddedStringAttributes:[NSAttributedStringKey:Any]? = [
        NSAttributedStringKey.font: NSFont(name: "AvenirNext-Heavy", size: 48.0)!,
        NSAttributedStringKey.foregroundColor: NSColor.red,
        NSAttributedStringKey.shadow: shadow
    ]
    let myAddedString = NSAttributedString(string: "!!!", attributes: myAddedStringAttributes)
    myMuAttString.append(myAddedString)
}//end func testNSString

class xxx {
    static public func HW() {
        print("😀Hello World!😀")
    }
}

