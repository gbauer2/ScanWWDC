//
//  MenuRulesVC.swift
//  AnalyseSwiftCode
//
//  Created by George Bauer on 4/4/19.
//  Copyright © 2019 George Bauer. All rights reserved.
//

import Cocoa

// MARK: - CodeRule struct
public struct CodeRule {
    // --- Rules ---                                    //Rules
    static var flagProductNameDif   = true                  //1
    static var allowAllCaps         = true                  //2
    static var allowUnderscore      = true                  //3
    static var maxFileCodeLines     = 500                   //4
    static var maxFuncCodeLines     = 130                   //5
    static var minumumSwiftVersion  = 4.0                   //6
    static var allowedOrganizations = "GeorgeBauer,GB"      //7

    // --- keys for UserDefaults ---                            //keys
    static var keyProductName       = "RuleProductName"             //1
    static var keyRuleAllCaps       = "RuleAllCaps"                 //2
    static var keyRuleUnderScore    = "RuleUnderScore"              //3
    static var keyMaxFileCodeline   = "RuleMaxFileCodeline"         //4
    static var keyMaxFuncCodeline   = "RuleMaxFuncCodeline"         //5
    static var keyMinSwiftVersion   = "RuleMinSwiftVersion"         //6
    static var keyOrganizations     = "RuleOrganizations"           //7

    //---- saveUserDefaults - Save the Rules in UserDefaults
    static func saveUserDefaults() {
        let defaults = UserDefaults.standard                    //Save UserDefaults
        defaults.set(flagProductNameDif,  forKey: keyProductName)       //1
        defaults.set(allowAllCaps,        forKey: keyRuleAllCaps)       //2
        defaults.set(allowUnderscore,     forKey: keyRuleUnderScore)    //3
        defaults.set(maxFileCodeLines,    forKey: keyMaxFileCodeline)   //4
        defaults.set(maxFuncCodeLines,    forKey: keyMaxFuncCodeline)   //5
        defaults.set(minumumSwiftVersion, forKey: keyMinSwiftVersion)   //6
        defaults.set(allowedOrganizations,forKey: keyOrganizations)     //7
        //UserDefaults.standard.removeObject(forKey: "name")
    }

    //---- getUserDefaults - Get the Rules from UserDefaults
    static func getUserDefaults() {
        let defaults = UserDefaults.standard

        let fileCodelines = defaults.integer(forKey: keyMaxFileCodeline)
        if fileCodelines > 0 {                                      //Get UserDefaults
            flagProductNameDif = defaults.bool(forKey: keyProductName )     //1
            allowAllCaps       = defaults.bool(forKey: keyRuleAllCaps)      //2
            allowUnderscore    = defaults.bool(forKey: keyRuleUnderScore)   //3

            maxFileCodeLines   = fileCodelines                              //4
            let funcCodelines = defaults.integer(forKey: keyMaxFuncCodeline)
            if funcCodelines > 0 { maxFuncCodeLines = funcCodelines }       //5

            let ver = defaults.double(forKey: keyMinSwiftVersion)
            if ver > 0 { minumumSwiftVersion = ver }                        //6

            if let str = defaults.string(forKey: keyOrganizations) {        //7
                allowedOrganizations = str
            }
        }
    }//end func

}//end struct CodeRules

// MARK: - MenuRulesVC class - UI for changing CodeRules
class MenuRulesVC: NSViewController {

    //MARK:- Instance Variables
    var changeBits: UInt = 0
    var maxFileCode = 0
    var maxFuncCode = 0
    var minSwiftVer = 0.0
    var organizations = ""

    //MARK:- Lifecycle funcs

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.                                          //Load controls
        chkRuleAppVsProduct.state = CodeRule.flagProductNameDif ? .on : .off    //1
        chkRuleAllCaps.state      = CodeRule.allowAllCaps       ? .on : .off    //2
        chkRuleUnderscore.state   = CodeRule.allowUnderscore    ? .on : .off    //3

        maxFileCode = CodeRule.maxFileCodeLines
        txtRuleFileCodelines.stringValue = "\(maxFileCode)"                     //4
        maxFuncCode = CodeRule.maxFuncCodeLines
        txtRuleFuncCodelines.stringValue = "\(maxFuncCode)"                     //5
        minSwiftVer = CodeRule.minumumSwiftVersion
        txtRuleMinSwiftVer.stringValue   = String(format:"%.1f", minSwiftVer)   //6
        organizations = CodeRule.allowedOrganizations.trim
        txtRuleOrganization.stringValue = organizations                         //7

        btnOk.isEnabled = false
    }//end func

    //MARK:- @IBOutlets

    @IBOutlet weak var lblError:            NSTextField!
    //                                              //@IBOutlets
    @IBOutlet weak var chkRuleAppVsProduct: NSButton!       //1
    @IBOutlet weak var chkRuleAllCaps:      NSButton!       //2
    @IBOutlet weak var chkRuleUnderscore:   NSButton!       //3

    @IBOutlet weak var txtRuleFileCodelines: NSTextField!   //4
    @IBOutlet weak var txtRuleFuncCodelines: NSTextField!   //5
    @IBOutlet weak var txtRuleMinSwiftVer:   NSTextField!   //6
    @IBOutlet weak var txtRuleOrganization:  NSTextField!   //7

    @IBOutlet weak var chkDefault:          NSButton!
    @IBOutlet weak var btnOk:               NSButton!

    //MARK:- @IBActions

    //---- "Save as Defaults" checkBox change ----
    @IBAction func chkDefaultClicked(_ sender: Any) {
        let isChange =  chkDefault.state == .on
        setOkButton(isChange: isChange, bitVal: 0x1000)
    }//end func

    //---- OK Button Clicked ----
    @IBAction func btnOkClick(_ sender: Any) {
        //                                                      //Validate
        if maxFileCode != (Int(txtRuleFileCodelines.stringValue)) {     //4
            lblError.stringValue = "Max FileCode not \"entered\""
            return
        }
        if maxFuncCode != (Int(txtRuleFuncCodelines.stringValue)) {     //5
            lblError.stringValue = "Max FuncCode not \"entered\""
            return
        }
        if let val = (Double(txtRuleMinSwiftVer.stringValue)) {         //6
            if abs(val - minSwiftVer) > 0.001 {
                lblError.stringValue = "Min SwiftVer not \"entered\""
                return
            }
        } else {
            lblError.stringValue = "MinSwiftVer not valid"
            return
        }
        if organizations != txtRuleOrganization.stringValue {             //7
            lblError.stringValue = "Allowed Organizations not \"entered\""
            return
        }
        //                                                          //Save Changes
        CodeRule.flagProductNameDif = (chkRuleAppVsProduct.state == .on)    //1
        CodeRule.allowAllCaps       = (chkRuleAllCaps.state      == .on)    //2
        CodeRule.allowUnderscore    = (chkRuleUnderscore.state   == .on)    //3

        CodeRule.maxFileCodeLines = maxFileCode                             //4
        CodeRule.maxFuncCodeLines = maxFuncCode                             //5
        CodeRule.minumumSwiftVersion = minSwiftVer                          //6

        CodeRule.allowedOrganizations = organizations                       //7

        print("✅✅ \(txtRuleFileCodelines.stringValue) \(txtRuleFuncCodelines.stringValue) \(txtRuleMinSwiftVer.stringValue)")

        if chkDefault.state == .on {
            CodeRule.saveUserDefaults()
        }

        self.view.window?.close()
    }//end func
    //                                                          //@IBActions
    @IBAction func chkRuleAppVsProductClick(_ sender: Any) {        //1
        lblError.stringValue = ""
        let isChange = CodeRule.flagProductNameDif != (chkRuleAppVsProduct.state == .on)
        setOkButton(isChange: isChange, bitVal: 0x1)
    }

    @IBAction func chkRuleAllCapsClick(_ sender: Any) {             //2
        lblError.stringValue = ""
        let isChange = CodeRule.allowAllCaps != (chkRuleAllCaps.state == .on)
        setOkButton(isChange: isChange, bitVal: 0x2)
    }

    @IBAction func chkRuleUnderscoreClick(_ sender: Any) {          //3
        lblError.stringValue = ""
        let isChange = CodeRule.allowUnderscore != (chkRuleUnderscore.state == .on)
        setOkButton(isChange: isChange, bitVal: 0x4)
    }

    @IBAction func txtRuleCodeLinesInFileChange(_ sender: Any) {    //4
        lblError.stringValue = ""
        let txt = removeNonDigits(txtRuleFileCodelines.stringValue)
        if let val = Int(txt), val >= 200, val <= 1000 {
            let isChange = val != CodeRule.maxFileCodeLines
            setOkButton(isChange: isChange, bitVal: 0x8)
            txtRuleFileCodelines.stringValue = txt
            maxFileCode = val
        } else {
            txtRuleFileCodelines.stringValue = "\(CodeRule.maxFileCodeLines)"
            lblError.stringValue = "File CodeLine limit 200-1000"
        }
    }//end func

    @IBAction func txtRuleCodeLinesInFuncChange(_ sender: Any) {    //5
        lblError.stringValue = ""
        let txt = removeNonDigits(txtRuleFuncCodelines.stringValue)
        if let val = Int(txt), val >= 60, val <= 500 {
            let isChange = val != CodeRule.maxFuncCodeLines
            setOkButton(isChange: isChange,bitVal: 0x10)
            txtRuleFuncCodelines.stringValue = txt
            maxFuncCode = val
        } else {
            txtRuleFuncCodelines.stringValue = "\(CodeRule.maxFuncCodeLines)"
            lblError.stringValue = "Func CodeLine limit 60-500"
        }
    }//end func

    @IBAction func txtRuleMinSwiftVerChange(_ sender: Any) {        //6
        lblError.stringValue = ""
        let txt = processVer(from: txtRuleMinSwiftVer.stringValue)
        if let val = Double(txt), val >= 3.0, val <= 9.0 {
            let isChange = val != CodeRule.minumumSwiftVersion
            setOkButton(isChange: isChange, bitVal: 0x20)
            txtRuleMinSwiftVer.stringValue = String(format:"%.1f", val)
            minSwiftVer = val
        } else {
            txtRuleFuncCodelines.stringValue = "\(CodeRule.maxFuncCodeLines)"
            lblError.stringValue = "Min. Swift Ver. 3.0 or higher"
        }
    }//end func

    @IBAction func txtRuleOrganizationChange(_ sender: Any) {       //7
        lblError.stringValue = ""
        organizations = txtRuleOrganization.stringValue
        let isChange = organizations != CodeRule.allowedOrganizations
        setOkButton(isChange: isChange, bitVal: 0x40)
        organizations = txtRuleOrganization.stringValue.trim
        txtRuleOrganization.stringValue = organizations
        print(organizations, txtRuleOrganization.stringValue)
    }

    //MARK:- Helper funcs

    func setOkButton(isChange: Bool, bitVal: UInt) {
        if isChange {
            changeBits |= bitVal
        } else {
            changeBits &= ~bitVal
        }
        btnOk.isEnabled = changeBits != 0
    }//end func

    func removeNonDigits(_ str: String) -> String {
        var newStr = ""
        for char in str {
            if char.isNumber {
                newStr.append(char)
            }
        }
        return newStr
    }//end func

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
    }//end func

}//end class MenuRulesVC
