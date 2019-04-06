//
//  MenuRulesVC.swift
//  AnalyseSwiftCode
//
//  Created by George Bauer on 4/4/19.
//  Copyright © 2019 Ray Wenderlich. All rights reserved.
//

import Cocoa

public struct IssuePreferences {
    static var differentProductNameDisallow = true
    static var allCapsDisallow              = true
    static var underscoreDisallow           = true
    static var minumumSwiftVersion  = 4.0
    static var allowedOrganizations = ["GeorgeBauer"]
    static var maxFileCodeLines     = 500
    static var maxFuncCodeLines     = 130
}

class MenuRulesVC: NSViewController {

    var changeBits: UInt = 0
    var maxFileCode = 0
    var maxFuncCode = 0
    var minSwiftVer = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        chkRuleAppVsProduct.state = IssuePreferences.differentProductNameDisallow ? .on : .off
        chkRuleAllCaps.state    = IssuePreferences.allCapsDisallow ? .on :.off
        chkRuleUnderscore.state = IssuePreferences.underscoreDisallow ? .on : .off

        maxFileCode = IssuePreferences.maxFileCodeLines
        txtRuleFileCodelines.stringValue = "\(maxFileCode)"
        maxFuncCode = IssuePreferences.maxFuncCodeLines
        txtRuleFuncCodelines.stringValue = "\(maxFuncCode)"
        minSwiftVer = IssuePreferences.minumumSwiftVersion
        txtRuleMinSwiftVer.stringValue   = String(format:"%.1f", minSwiftVer)

        btnOk.isEnabled = false
    }

    @IBOutlet weak var chkRuleAppVsProduct: NSButton!
    @IBOutlet weak var chkRuleAllCaps:      NSButton!
    @IBOutlet weak var chkRuleUnderscore:   NSButton!

    @IBOutlet weak var txtRuleFileCodelines: NSTextField!
    @IBOutlet weak var txtRuleFuncCodelines: NSTextField!
    @IBOutlet weak var txtRuleMinSwiftVer:  NSTextField!
    @IBOutlet weak var txtRuleOrganization: NSTextField!

    @IBOutlet weak var lblError:            NSTextField!
    @IBOutlet weak var btnOk:               NSButton!
    
    
    @IBAction func btnOkClick(_ sender: Any) {
        IssuePreferences.differentProductNameDisallow = (chkRuleAppVsProduct.state == .on)
        IssuePreferences.allCapsDisallow            = (chkRuleAllCaps.state == .on)
        IssuePreferences.underscoreDisallow         = (chkRuleUnderscore.state == .on)

        IssuePreferences.maxFileCodeLines = maxFileCode
        IssuePreferences.maxFuncCodeLines = maxFuncCode
        IssuePreferences.minumumSwiftVersion = minSwiftVer

        self.view.window?.close()
    }

    @IBAction func chkRuleAppVsProductClick(_ sender: Any) {
        let isChange = IssuePreferences.differentProductNameDisallow != (chkRuleAppVsProduct.state == .on)
        setOkButton(isChange: isChange, bitVal: 1)
    }

    @IBAction func chkRuleAllCapsClick(_ sender: Any) {
        let isChange = IssuePreferences.allCapsDisallow != (chkRuleAllCaps.state == .on)
        setOkButton(isChange: isChange, bitVal: 2)
    }

    @IBAction func chkRuleUnderscoreClick(_ sender: Any) {
        let isChange = IssuePreferences.underscoreDisallow != (chkRuleUnderscore.state == .on)
        setOkButton(isChange: isChange, bitVal: 8)
    }

    @IBAction func txtRuleCodeLinesInFileChange(_ sender: Any) {
        let txt = removeNonDigits(txtRuleFileCodelines.stringValue)
        if let val = Int(txt), val >= 200, val <= 1000 {
            maxFileCode = val
            txtRuleFileCodelines.stringValue = txt
            let isChange = maxFileCode != IssuePreferences.maxFileCodeLines
            setOkButton(isChange: isChange, bitVal: 16)
        }
    }

    @IBAction func txtRuleCodeLinesInFuncChange(_ sender: Any) {
        let txt = removeNonDigits(txtRuleFuncCodelines.stringValue)
        if let val = Int(txt), val >= 50, val <= 500 {
            maxFuncCode = val
            txtRuleFuncCodelines.stringValue = txt
            let isChange = maxFuncCode != IssuePreferences.maxFuncCodeLines
            setOkButton(isChange: isChange,bitVal: 32)
        }
    }

    @IBAction func txtRuleMinSwiftVerChange(_ sender: Any) {
        let txt = processVer(txtRuleMinSwiftVer.stringValue)
        if let val = Double(txt), val >= 0, val <= 9 {
            minSwiftVer = val
            txtRuleMinSwiftVer.stringValue = String(format:"%.1f", minSwiftVer)
            let isChange = minSwiftVer != IssuePreferences.minumumSwiftVersion
            setOkButton(isChange: isChange, bitVal: 64)
        }
    }

    @IBAction func txtRuleOrganizationChange(_ sender: Any) {
        print()    }

    func setOkButton(isChange: Bool, bitVal: UInt) {
        if isChange {
            changeBits |= bitVal
        } else {
            changeBits &= ~bitVal
        }
        btnOk.isEnabled = changeBits != 0
    }

    func removeNonDigits(_ str: String) -> String {
        var newStr = ""
        for char in str {
            if char.isNumber {
                newStr.append(char)
            }
        }
        return newStr
    }

    func processVer(_ str: String) -> String {
        var newStr = ""
        var gotDot = false
        for char in str {
            if char.isNumber {
                newStr.append(char)
            } else if char == "." {
                if gotDot { break }
                gotDot = true
                newStr.append(char)
            }

        }
        return newStr
    }

}//end class
