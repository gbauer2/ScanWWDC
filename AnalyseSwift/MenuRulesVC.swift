//
//  MenuRulesVC.swift
//  AnalyseSwiftCode
//
//  Created by George Bauer on 4/4/19.
//  Copyright © 2019 George Bauer. All rights reserved.
//

import Cocoa

//TODO:- TextView Properties (Dictonary? & Default Val):

public enum ValType {
    case bool, int, text
}

// RuleType to change
//      flagProductNameDif   = 1     //1
//      allowAllCaps         = 2     //2
//      allowUnderscore      = 3     //3
//      minumumSwiftVersion  = 6     //6
//      allowedOrganizations = 7     //7

// MARK: - CodeRule struct 29-115 = 86-lines
public struct CodeRule {
    // --- Rules ---                                    //Rules
    static var flagProductNameDif   = true                  //1
    static var minumumSwiftVersion  = 4.0                   //3
    static var allowedOrganizations = "GeorgeBauer,GB"      //4

    static var allowAllCaps         = true                  //2
    static var allowUnderscore      = true                  //3

    // --- keys for UserDefaults ---                            //keys
    static var keyProductName       = "RuleProductName"             //1
    static var keyMinSwiftVersion   = "RuleMinSwiftVersion"         //3
    static var keyOrganizations     = "RuleOrganizations"           //4

    static var keyRuleAllCaps       = "RuleAllCaps"                 //2
    static var keyRuleUnderScore    = "RuleUnderScore"              //3

    //---- CodeRule.saveUserDefaults - Save the Rules in UserDefaults
    static func saveUserDefaults() {
        let defaults = UserDefaults.standard                    //Save UserDefaults

        defaults.set(flagProductNameDif,  forKey: keyProductName)       //1
        defaults.set(minumumSwiftVersion, forKey: keyMinSwiftVersion)   //6
        defaults.set(allowedOrganizations,forKey: keyOrganizations)     //7

        defaults.set(allowAllCaps,        forKey: keyRuleAllCaps)       //2
        defaults.set(allowUnderscore,     forKey: keyRuleUnderScore)    //3

        print("Save Default Rules")
        for issue in Issue.issueArray {
            let key = "Rule_" + issue.identifier
            let value = makeStr(fromBool: issue.enabled) + "," + issue.paramText
            print ("userDefault save  \(key):  \(value)")
            defaults.set(value, forKey: key)
        }

        //UserDefaults.standard.removeObject(forKey: "name")
    }

    static func makeStr(fromBool: Bool ) -> String {
        return fromBool ? "true" : "false"
    }

    //---- getUserDefaults - Get the Rules from UserDefaults
    static func getUserDefaults() {
        let defaults = UserDefaults.standard

            flagProductNameDif = defaults.bool(forKey: keyProductName )     //1
            let ver = defaults.double(forKey: keyMinSwiftVersion)
            if ver > 0 { minumumSwiftVersion = ver }                        //6
            if let str = defaults.string(forKey: keyOrganizations) {        //7
                allowedOrganizations = str
            }


            allowAllCaps       = defaults.bool(forKey: keyRuleAllCaps)      //2
            allowUnderscore    = defaults.bool(forKey: keyRuleUnderScore)   //3

            for (key, index) in Issue.dictIssues {
                let udKey = "Rule_" + key
                if let str = defaults.string(forKey: udKey) {        //7
                    let (enabledText, param) = splitLine(str, atCharacter: ",")
                    if index >= 0 && index < Issue.dictIssues.count {
                        let enabled = (enabledText == "true")
                        print("userDefault get  \(key): enabled=\(enabled),  paramText=\(param)")
                        Issue.issueArray[index].enabled   = enabled
                        Issue.issueArray[index].paramText = param
                    } else {
                        print("Error #\(#line) index out of bounds.")
                    }
                } else {
                    print("Error #\(#line) No UserDefault for \(key)")
                }
            }
    }//end func

}//end struct CodeRules

// MARK: - MenuRulesVC class - UI for changing CodeRules 118-351 = 333-lines
class MenuRulesVC: NSViewController {

    //MARK:- Instance Variables
    var changeBits: UInt = 0
    var maxFileCode = 0
    var maxFuncCode = 0
    var minSwiftVer = 0.0
    var organizations = ""
    static var localIssueArray = [Issue]() // Allow user close window without committing changes

    //MARK:- Lifecycle funcs

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.                                          //Load controls
        chkRuleAppVsProduct.state = CodeRule.flagProductNameDif ? .on : .off    //1
        minSwiftVer = CodeRule.minumumSwiftVersion
        txtRuleMinSwiftVer.stringValue   = String(format:"%.1f", minSwiftVer)   //6
        organizations = CodeRule.allowedOrganizations.trim
        txtRuleOrganization.stringValue = organizations                         //7


        chkRuleAllCaps.state      = CodeRule.allowAllCaps       ? .on : .off    //2
        chkRuleUnderscore.state   = CodeRule.allowUnderscore    ? .on : .off    //3

        // Fill in Current TextField Values

        // Set TextField delegates
        txtRuleMinSwiftVer.delegate   = self    // 201
        txtRuleOrganization.delegate  = self    // 301 as NSTextFieldDelegate

        MenuRulesVC.localIssueArray = Issue.issueArray
        //btnOk.isEnabled = false
        tableView.delegate   = self
        tableView.dataSource = self

        self.tableView.reloadData()

    }//end func

    override func viewWillAppear() {
        print("MenuRulesVC:", #line, MenuRulesVC.localIssueArray[0])
    }

    //MARK:- @IBOutlets

    @IBOutlet weak var lblError:            NSTextField!
    //                                              //@IBOutlets
    @IBOutlet weak var chkRuleAppVsProduct: NSButton!       //1
    @IBOutlet weak var chkRuleAllCaps:      NSButton!       //2
    @IBOutlet weak var chkRuleUnderscore:   NSButton!       //3

    @IBOutlet weak var txtRuleFileCodelines: NSTextField!   //4 101
    @IBOutlet weak var txtRuleMinSwiftVer:   NSTextField!   //6 201
    @IBOutlet weak var txtRuleOrganization:  NSTextField!   //7 301

    @IBOutlet weak var chkDefault:          NSButton!
    @IBOutlet weak var btnOk:               NSButton!

    @IBOutlet weak var menuView: NSView!

    @IBOutlet weak var tableView:    NSTableView!
    @IBOutlet weak var tableCheckEnabled: NSButton!
    

    //MARK:- @IBActions

    //---- "Save as Defaults" checkBox change ----
    @IBAction func chkDefaultClicked(_ sender: Any) {
        let isChange =  chkDefault.state == .on
        setOkButton(isChange: isChange, bitVal: 0x1000)
    }//end func

    //---- OK Button Clicked ----
    @IBAction func btnOkClick(_ sender: Any) {
        //                                                      //Validate
//        if maxFileCode != (Int(txtRuleFileCodelines.stringValue)) {     //4
//            lblError.stringValue = "Max FileCode not \"entered\""
//            return
//        }
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

        CodeRule.minumumSwiftVersion = minSwiftVer                          //6

        CodeRule.allowedOrganizations = organizations                       //7

        Issue.issueArray = MenuRulesVC.localIssueArray

        print("✅✅ \(txtRuleMinSwiftVer.stringValue)")

        if chkDefault.state == .on {
            CodeRule.saveUserDefaults()
        }

        self.view.window?.close()
    }//end func btnOkClick

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

    //MARK: textField IBActions
    @IBAction func txtRuleCodeLinesInFileChange(_ sender: Any) {    //4 101
//        lblError.stringValue = ""
//        let txt = removeNonDigits(txtRuleFileCodelines.stringValue)
//        if let val = Int(txt), val >= 200, val <= 1000 {
//            let isChange = val != CodeRule.maxFileCodeLines
//            setOkButton(isChange: isChange, bitVal: 0x8)
//            txtRuleFileCodelines.stringValue = txt
//            maxFileCode = val
//        } else {
//            let maxFileCodeLines = getIntParam(of: RuleID.bigFile) ?? 9999
//            txtRuleFileCodelines.stringValue = "\(maxFileCodeLines)"
//            lblError.stringValue = "File CodeLine limit 200-1000"
//        }
    }//end func

    @IBAction func txtRuleMinSwiftVerChange(_ sender: Any) {        //6 201
        lblError.stringValue = ""
        let txt = processVer(from: txtRuleMinSwiftVer.stringValue)
        if let val = Double(txt), val >= 3.0, val <= 9.0 {
            let isChange = val != CodeRule.minumumSwiftVersion
            setOkButton(isChange: isChange, bitVal: 0x20)
            txtRuleMinSwiftVer.stringValue = String(format:"%.1f", val)
            minSwiftVer = val
        } else {
            txtRuleMinSwiftVer.stringValue = "\(CodeRule.minumumSwiftVersion)"
            lblError.stringValue = "Min. Swift Ver. 3.0 to 9.0"
        }
    }//end func

    @IBAction func txtRuleOrganizationChange(_ sender: Any) {       //7 301
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
        //btnOk.isEnabled = changeBits != 0
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
        }//next char
        return newStr
    }//end func

}//end class MenuRulesVC

//MARK:- MenuRulesVC: NSTextFieldDelegate
extension MenuRulesVC: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        if let txtFld = obj.object as? NSTextField {
            print("🔷 \(txtFld.tag) \(txtFld.stringValue)")
            switch txtFld.tag {
            case 101:
                //self.txtRuleOrganization.stringValue = txtFld.stringValue
                break
            case 102:
                //self.txtRuleFileCodelines.stringValue = txtFld.stringValue
                break
            case 201:
                break
            case 301:
                break
            default:
                break
            }
        }
    }//end func

    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        return true
    }

/*
     func controlTextDidBeginEditing(_ obj: Notification)
     func controlTextDidEndEditing(_ obj: Notification)
     func controlTextDidChange(_ obj: Notification)

     func control(_ control: NSControl, textShouldBeginEditing fieldEditor: NSText) -> Bool
     func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool
     func control(_ control: NSControl, didFailToFormatString string: String, errorDescription error: String?) -> Bool
     func control(_ control: NSControl, didFailToValidatePartialString string: String, errorDescription error: String?)
     func control(_ control: NSControl, isValidObject obj: Any?) -> Bool

     func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool
     func control(_ control: NSControl, textView: NSTextView, completions words: [String], forPartialWordRange charRange: NSRange, indexOfSelectedItem index: UnsafeMutablePointer<Int>) -> [String]
 */

}//end extension

//Sample Data
let sample = [0,1,2]

// MARK: - MenuRulesVC: NSTableViewDataSource
extension MenuRulesVC: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return MenuRulesVC.localIssueArray.count
    }//end func

}//end extension


// MARK: - MenuRulesVC: NSTableViewDelegate
extension MenuRulesVC: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView,
                   viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        let issue = MenuRulesVC.localIssueArray[row]
        let desc = issue.desc

        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "RuleCell"), owner: nil) as? viewIssue {
            cell.row = row
            cell.lblRuleName.stringValue = desc
            cell.chkEnabled.state = issue.enabled ? .on : .off
            //cell.textField?.stringValue = "Label#1: "
            cell.lblParam.stringValue = issue.paramLabel
            if issue.paramLabel.isEmpty {
                cell.txtParam.isHidden = true
            } else {
                cell.txtParam.isHidden = false
                cell.txtParam.stringValue = issue.paramText
            }
            return cell
        }
        return nil
    }//end func

    func tableViewSelectionDidChange(_ notification: Notification) {
        if tableView.selectedRow < 0 {
            print("Error MenuRulesVC #(#line)")
            return
        }
        print(tableView?.selectedRow ?? -1)
    }//end func

}//end extension

    //MARK:- class viewIssue: NSTableCellView
    class viewIssue: NSTableCellView {
        var row = -1
        @IBOutlet weak var chkEnabled: NSButton!
        @IBOutlet weak var lblParam: NSTextField!
        @IBOutlet weak var txtParam: NSTextField!
        @IBOutlet weak var lblRuleName: NSTextField!


        @IBAction func chkEnabledClick(_ sender: NSButton) {
            //print("chkEnabled = \(chkEnabled.state)")
            MenuRulesVC.localIssueArray[row].enabled = (chkEnabled.state == .on)
        }

        // Triggered by "Enter", or Loss-of-focus
        @IBAction func paramTextChange(_ sender: Any) {
            print("paramText = \(txtParam.stringValue)")
            MenuRulesVC.localIssueArray[row].paramText = txtParam.stringValue

        }
    }//end class

