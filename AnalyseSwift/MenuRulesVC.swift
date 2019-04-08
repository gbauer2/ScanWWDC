//
//  MenuRulesVC.swift
//  AnalyseSwiftCode
//
//  Created by George Bauer on 4/4/19.
//  Copyright © 2019 Ray Wenderlich. All rights reserved.
//

import Cocoa

public struct CodeRule {
    static var flagProductNameDif   = true
    static var allowAllCaps         = true
    static var allowUnderscore      = true
    static var maxFileCodeLines     = 500
    static var maxFuncCodeLines     = 130
    static var minumumSwiftVersion  = 4.0
    static var allowedOrganizations = ["GeorgeBauer","GB"]

    static var keyProductName       = "RuleProductName"
    static var keyRuleAllCaps       = "RuleAllCaps"
    static var keyRuleUnderScore    = "RuleUnderScore"

    static var keyMaxFileCodeline   = "RuleMaxFileCodeline"
    static var keyMaxFuncCodeline   = "RuleMaxFuncCodeline"
    static var keyMinSwiftVersion   = "RuleMinSwiftVersion"

    static func saveUserDefaults() {
        let defaults = UserDefaults.standard
        defaults.set(flagProductNameDif, forKey: keyProductName)
        defaults.set(allowAllCaps,       forKey: keyRuleAllCaps)
        defaults.set(allowUnderscore,    forKey: keyRuleUnderScore)
    }

    static func getUserDefaults() {
        let defaults = UserDefaults.standard

        let fileCodelines = defaults.integer(forKey: keyMaxFileCodeline)
        if fileCodelines > 0 {
            flagProductNameDif = defaults.bool(forKey: keyProductName )
            allowAllCaps       = defaults.bool(forKey: keyRuleAllCaps)
            allowUnderscore    = defaults.bool(forKey: keyRuleUnderScore)

            maxFileCodeLines   = fileCodelines
            let funcCodelines = defaults.integer(forKey: keyMaxFuncCodeline)
            if funcCodelines > 0 { maxFileCodeLines = funcCodelines }

            let ver = defaults.double(forKey: keyMinSwiftVersion)
            if ver > 0 { minumumSwiftVersion = ver }

        }
    }

}

class MenuRulesVC: NSViewController {

    //MARK:- Instance Variables
    var changeBits: UInt = 0
    var maxFileCode = 0
    var maxFuncCode = 0
    var minSwiftVer = 0.0
    var organizations = [String]()

    //MARK:- Lifecycle funcs

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        chkRuleAppVsProduct.state = CodeRule.flagProductNameDif ? .on : .off
        chkRuleAllCaps.state      = CodeRule.allowAllCaps       ? .on :.off
        chkRuleUnderscore.state   = CodeRule.allowUnderscore    ? .on : .off

        maxFileCode = CodeRule.maxFileCodeLines
        txtRuleFileCodelines.stringValue = "\(maxFileCode)"
        maxFuncCode = CodeRule.maxFuncCodeLines
        txtRuleFuncCodelines.stringValue = "\(maxFuncCode)"
        minSwiftVer = CodeRule.minumumSwiftVersion
        txtRuleMinSwiftVer.stringValue   = String(format:"%.1f", minSwiftVer)

        var orgStr = ""
        for org in CodeRule.allowedOrganizations {
            orgStr.append(org + ",")
        }
        if orgStr.hasSuffix(",") { orgStr.removeLast() }
        txtRuleOrganization.stringValue = orgStr

        btnOk.isEnabled = false
    }

    //MARK:- @IBOutlets

    @IBOutlet weak var lblError:            NSTextField!

    @IBOutlet weak var chkRuleAppVsProduct: NSButton!
    @IBOutlet weak var chkRuleAllCaps:      NSButton!
    @IBOutlet weak var chkRuleUnderscore:   NSButton!

    @IBOutlet weak var txtRuleFileCodelines: NSTextField!
    @IBOutlet weak var txtRuleFuncCodelines: NSTextField!
    @IBOutlet weak var txtRuleMinSwiftVer:  NSTextField!
    @IBOutlet weak var txtRuleOrganization: NSTextField!

    @IBOutlet weak var chkDefault:          NSButton!
    @IBOutlet weak var btnOk:               NSButton!

    //MARK:- @IBActions

    //---- "Save as Defaults" checkBox change ----
    @IBAction func chkDefaultClicked(_ sender: Any) {
        if chkDefault.state == .on {
            btnOk.isEnabled = true
        } else {
            btnOk.isEnabled = changeBits != 0
        }
    }

    //---- OK Button Clicked ----
    @IBAction func btnOkClick(_ sender: Any) {
        CodeRule.flagProductNameDif = (chkRuleAppVsProduct.state == .on)
        CodeRule.allowAllCaps       = (chkRuleAllCaps.state      == .on)
        CodeRule.allowUnderscore    = (chkRuleUnderscore.state   == .on)

        CodeRule.maxFileCodeLines = maxFileCode
        CodeRule.maxFuncCodeLines = maxFuncCode
        CodeRule.minumumSwiftVersion = minSwiftVer

        CodeRule.allowedOrganizations = organizations

        if chkDefault.state == .on {
            CodeRule.saveUserDefaults()
        } else {

        }

        self.view.window?.close()
    }

    @IBAction func chkRuleAppVsProductClick(_ sender: Any) {
        lblError.stringValue = ""
        let isChange = CodeRule.flagProductNameDif != (chkRuleAppVsProduct.state == .on)
        setOkButton(isChange: isChange, bitVal: 1)
    }

    @IBAction func chkRuleAllCapsClick(_ sender: Any) {
        lblError.stringValue = ""
        let isChange = CodeRule.allowAllCaps != (chkRuleAllCaps.state == .on)
        setOkButton(isChange: isChange, bitVal: 2)
    }

    @IBAction func chkRuleUnderscoreClick(_ sender: Any) {
        lblError.stringValue = ""
        let isChange = CodeRule.allowUnderscore != (chkRuleUnderscore.state == .on)
        setOkButton(isChange: isChange, bitVal: 8)
    }

    @IBAction func txtRuleCodeLinesInFileChange(_ sender: Any) {
        lblError.stringValue = ""
        let txt = removeNonDigits(txtRuleFileCodelines.stringValue)
        if let val = Int(txt), val >= 200, val <= 1000 {
            maxFileCode = val
            txtRuleFileCodelines.stringValue = txt
            let isChange = maxFileCode != CodeRule.maxFileCodeLines
            setOkButton(isChange: isChange, bitVal: 16)
        } else {
            txtRuleFileCodelines.stringValue = "\(CodeRule.maxFileCodeLines)"
            lblError.stringValue = "File CodeLine limit 200-1000"
        }
    }

    @IBAction func txtRuleCodeLinesInFuncChange(_ sender: Any) {
        lblError.stringValue = ""
        let txt = removeNonDigits(txtRuleFuncCodelines.stringValue)
        if let val = Int(txt), val >= 60, val <= 500 {
            maxFuncCode = val
            txtRuleFuncCodelines.stringValue = txt
            let isChange = maxFuncCode != CodeRule.maxFuncCodeLines
            setOkButton(isChange: isChange,bitVal: 32)
        } else {
            txtRuleFuncCodelines.stringValue = "\(CodeRule.maxFuncCodeLines)"
            lblError.stringValue = "Func CodeLine limit 60-500"
        }
    }

    @IBAction func txtRuleMinSwiftVerChange(_ sender: Any) {
        lblError.stringValue = ""
        let txt = processVer(from: txtRuleMinSwiftVer.stringValue)
        if let val = Double(txt), val >= 3.0, val <= 9.0 {
            minSwiftVer = val
            txtRuleMinSwiftVer.stringValue = String(format:"%.1f", minSwiftVer)
            let isChange = minSwiftVer != CodeRule.minumumSwiftVersion
            setOkButton(isChange: isChange, bitVal: 64)
        } else {
            txtRuleFuncCodelines.stringValue = "\(CodeRule.maxFuncCodeLines)"
            lblError.stringValue = "Min. Swift Ver. 3.0 or higher"
        }
    }

    @IBAction func txtRuleOrganizationChange(_ sender: Any) {
        lblError.stringValue = ""
        organizations = parseOrgs(from: txtRuleOrganization.stringValue)
        let isChange = organizations != CodeRule.allowedOrganizations
        setOkButton(isChange: isChange, bitVal: 128)
    }

    //MARK:- Helper funcs
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

    func processVer(from str: String) -> String {
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

    func parseOrgs(from str: String) -> [String] {
        var orgs = [String]()
        if str.trim.isEmpty { return orgs }
        let orgStrings = str.components(separatedBy: ",")
        orgs = orgStrings.map {$0.trim}
        return orgs
    }

}//end class
