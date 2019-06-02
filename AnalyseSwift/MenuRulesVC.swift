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

//MARK: - CR struct - 18-162 = 144-lines - Not yet used
public struct CR {
    var controlTag    = -1      // 1 (Change to TableView Section/Row?)   101
    var name          = ""      // 2 Display Name                         "Max CodeLines in File"
    var bitVal: UInt64 = 0      // 3 Change-Bit to activate "Save"        0x8
    var keyUsrDefault = ""      // 4 User Defaults Key (Change to array?) "RuleMaxFileCodeline"
    var msgHelp       = ""      // 5 msg displayed when editing           "Max CodeLines allowed in func (200-1000)"
    var msgError      = ""      // 6 msg displayed in not valid           "Enter Number beween 200 and 1000"
    var type:ValType  = .text   // 7 .text, .int, .bool                   .int
    var defaultStr    = ""      // 8 textVal before any user changes      1000
    var textVal       = "" {    // 9 Value as Text                        "1000"
        didSet {
            print("🍎 didSet textVal = \(textVal)")
            print()
        }
    }
    var boolVal       = false {  //10 Value if bool
        didSet {
            print("🍎 didSet boolVal = \(boolVal)")
            print()
        }
    }
    var intVal        = 0 {      //11 Value if Int                         1000
        didSet {
            print("🍎 didSet intVal = \(intVal)")
            print()
        }
    }
    var minVal        = 0       //12 Minimum Value if numerical           200
    var maxVal        = 0       //13 Maximum Value if numerical           1000
    var decimalPos    = 0       //14 Decimal point position if numerical  0

    //MARK: initializers
    // FIXME: - Section/Row instead of tag.
    // also make dictionary where key = Section/Row for TableView

    // init String
    public init(tag: Int, idx: Int, name: String, key: String, helpMsg: String, errMsg: String, dfault: String, txt: String) {
        initHelper(tag: tag, idx: idx, name: name, key: key, helpMsg: helpMsg, dfault: dfault)
        if errMsg.isEmpty { msgError = helpMsg }        // 6
        else { msgError = errMsg }
        type        = .text                             // 7
        textVal     = txt                               // 9 final
    }

    // init Bool
    public init(tag: Int, idx: Int, name: String, key: String, helpMsg: String, dfault: String, bool: Bool) {
        initHelper(tag: tag, idx: idx, name: name, key: key, helpMsg: helpMsg, dfault: dfault)
        //msgError    = ""                              // 6
        type        = .bool                             // 7
        textVal     = bool ? "true" : "false"           // 9
        boolVal     = bool                              //10 final
    }

    // init Int
    public init(tag: Int, idx: Int, name: String, key: String, helpMsg: String, dfault: String, int: Int, minV: Int, maxV: Int, dp: Int) {
        initHelper(tag: tag, idx: idx, name: name, key: key, helpMsg: helpMsg, dfault: dfault)
        msgError = makeErrMsg(minV: minV, maxV: maxV, dp: dp)   // 6
        type            = .int                                  // 7
        textVal         = formatFauxInt(int, dp: dp)            // 9
        //boolVal       = false                                 //10
        intVal          = int                                   //11
        minVal          = minV                                  //12
        maxVal          = maxV                                  //13
        decimalPos      = dp                                    //14 final
    }

    //MARK: Helper funcs

    mutating func initHelper(tag: Int, idx: Int, name: String, key: String, helpMsg: String, dfault: String) {
        controlTag    = tag                                     // 1 =
        self.name     = name                                    // 2 =
        let idxMod64  = idx % 64    // 64 bits available
        bitVal        = UInt64(pow(2.0, Double(idxMod64))+0.5)  // 3 =
        keyUsrDefault = makeKey(name: name, key: key)           // 4 =
        msgHelp       = helpMsg                                 // 5 =*
        defaultStr    = dfault                                  // 8 =
    }

    internal func makeKey(name: String, key: String) -> String {
        if !key.isEmpty {
            if key.hasPrefix("Rule") { return key }
            return "Rule" + key
        }
        //        let pattern = "[^A-Za-z0-9]+"
        //        let cleanNameRE = name.replacingOccurrences(of: pattern, with: "", options: [.regularExpression])
        let cleanName = name.components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
        return "Rule" + cleanName
    }//end func

    internal func makeErrMsg(minV: Int, maxV: Int, dp: Int) -> String {
        let minStr = formatFauxInt(minV, dp: dp)
        let maxStr = formatFauxInt(maxV, dp: dp)
        return "Must be a value beween \(minStr) and \(maxStr)"
    }

    func formatFauxInt(_ int: Int, dp: Int) -> String {
        var str = "\(int)"
        if dp <= 0 { return str }
        if str.count <= dp {
            str = String(("0000" + str).suffix(dp+1))
        }
        str = String(str.prefix(str.count-dp) + "." + str.suffix(dp))
        return str
    }

    static func saveUserDefaults(rules: [CR]){
        let defaults = UserDefaults.standard
        for rule in rules {
            var valStr: String
            if rule.type == .int {
                valStr = "\(rule.intVal)"
                let dp = rule.decimalPos
                if dp > 0 && dp < valStr.count {
                    valStr.insert(".", at: valStr.index(valStr.endIndex, offsetBy: -dp))
                }
            } else if rule.type == .bool {
                valStr = rule.boolVal ? "true" : "false"
            } else {
                valStr = rule.textVal
            }
            defaults.set(valStr,  forKey: rule.keyUsrDefault)
        }//next rule
    }//end func

    static func getUserDefaults(rules: inout [CR]) {
        let defaults = UserDefaults.standard
        for (i, rule) in rules.enumerated() {
            if let str = defaults.string(forKey: rule.keyUsrDefault) {        //7
                rules[i].textVal = str
                if rule.type == .int {
                    let intStr = str.replacingOccurrences(of: ".", with: "")
                    rules[i].intVal = Int(intStr) ?? 0
                } else if rule.type == .bool {
                    let strB = str.trim.lowercased()
                    if strB == "yes" || str == "true" {
                        rules[i].boolVal = true
                    } else {
                        rules[i].boolVal = false
                    }
                }
            }
        }//next rule
    }//end func

}//end struct CR

enum ruleType {
    static let none                 = 0     //0
    static let flagProductNameDif   = 1     //1
    static let allowAllCaps         = 2     //2
    static let allowUnderscore      = 3     //3
    static let maxFileCodeLines     = 4     //4
    static let maxFuncCodeLines     = 5     //5
    static let minumumSwiftVersion  = 6     //6
    static let allowedOrganizations = 7     //7
}

/*
 eNum RuleType {case flagProductNameDif = 0, allowAllCaps=1, etc
 Instead of "if CodeRule.allowAllCaps...", use "if rule[ruleType.allowAllCaps].boolVal..."
 */

// MARK: - CodeRule struct
public struct CodeRule {
    // --- Rules ---                                    //Rules
    static var flagProductNameDif   = true                  //1
    static var maxFileCodeLines     = 500                   //2
    static var minumumSwiftVersion  = 4.0                   //3
    static var allowedOrganizations = "GeorgeBauer,GB"      //4

    static var allowAllCaps         = true                  //2
    static var allowUnderscore      = true                  //3
    static var maxFuncCodeLines     = 130                   //5

    // --- keys for UserDefaults ---                            //keys
    static var keyProductName       = "RuleProductName"             //1
    static var keyMaxFileCodeline   = "RuleMaxFileCodeline"         //2
    static var keyMinSwiftVersion   = "RuleMinSwiftVersion"         //3
    static var keyOrganizations     = "RuleOrganizations"           //4

    static var keyRuleAllCaps       = "RuleAllCaps"                 //2
    static var keyRuleUnderScore    = "RuleUnderScore"              //3
    static var keyMaxFuncCodeline   = "RuleMaxFuncCodeline"         //5

    //---- CodeRule.saveUserDefaults - Save the Rules in UserDefaults
    static func saveUserDefaults() {
        let defaults = UserDefaults.standard                    //Save UserDefaults

        defaults.set(flagProductNameDif,  forKey: keyProductName)       //1
        defaults.set(maxFileCodeLines,    forKey: keyMaxFileCodeline)   //4
        defaults.set(minumumSwiftVersion, forKey: keyMinSwiftVersion)   //6
        defaults.set(allowedOrganizations,forKey: keyOrganizations)     //7

        defaults.set(allowAllCaps,        forKey: keyRuleAllCaps)       //2
        defaults.set(allowUnderscore,     forKey: keyRuleUnderScore)    //3
        defaults.set(maxFuncCodeLines,    forKey: keyMaxFuncCodeline)   //5

        print("Save Default Rules")
        for issue in Issue.issueArray {
            let key = "Rule_" + issue.identifier
            let value = makeStr(fromBool: issue.enabled) + "," + issue.paramText
            print ("userDefault save  \(key):  \(value)")
        }

        //UserDefaults.standard.removeObject(forKey: "name")
    }

    static func makeStr(fromBool: Bool ) -> String {
        return fromBool ? "true" : "false"
    }

    //---- getUserDefaults - Get the Rules from UserDefaults
    static func getUserDefaults() {
        let defaults = UserDefaults.standard

        let fileCodelines = defaults.integer(forKey: keyMaxFileCodeline)
        if fileCodelines > 0 {                                      //Get UserDefaults
            flagProductNameDif = defaults.bool(forKey: keyProductName )     //1
            maxFileCodeLines   = fileCodelines                              //4
            let ver = defaults.double(forKey: keyMinSwiftVersion)
            if ver > 0 { minumumSwiftVersion = ver }                        //6
            if let str = defaults.string(forKey: keyOrganizations) {        //7
                allowedOrganizations = str
            }


            allowAllCaps       = defaults.bool(forKey: keyRuleAllCaps)      //2
            allowUnderscore    = defaults.bool(forKey: keyRuleUnderScore)   //3
            let funcCodelines = defaults.integer(forKey: keyMaxFuncCodeline)
            if funcCodelines > 0 { maxFuncCodeLines = funcCodelines }       //5
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
        maxFileCode = CodeRule.maxFileCodeLines
        txtRuleFileCodelines.stringValue = "\(maxFileCode)"                     //4
        minSwiftVer = CodeRule.minumumSwiftVersion
        txtRuleMinSwiftVer.stringValue   = String(format:"%.1f", minSwiftVer)   //6
        organizations = CodeRule.allowedOrganizations.trim
        txtRuleOrganization.stringValue = organizations                         //7


        chkRuleAllCaps.state      = CodeRule.allowAllCaps       ? .on : .off    //2
        chkRuleUnderscore.state   = CodeRule.allowUnderscore    ? .on : .off    //3

        // Fill in Current TextField Values
        maxFuncCode = CodeRule.maxFuncCodeLines
        txtRuleFuncCodelines.stringValue = "\(maxFuncCode)"                     //5

        // Set TextField delegates
        txtRuleFileCodelines.delegate = self    // 101
        txtRuleFuncCodelines.delegate = self    // 102
        txtRuleMinSwiftVer.delegate   = self    // 201
        txtRuleOrganization.delegate  = self    // 301 as NSTextFieldDelegate

        btnOk.isEnabled = false
        tableView.delegate   = self
        tableView.dataSource = self

        self.tableView.reloadData()

    }//end func

    override func viewWillAppear() {
        print("MenuRulesVC:", #line, Issue.issueArray[0])
    }
    //MARK:- @IBOutlets

    @IBOutlet weak var lblError:            NSTextField!
    //                                              //@IBOutlets
    @IBOutlet weak var chkRuleAppVsProduct: NSButton!       //1
    @IBOutlet weak var chkRuleAllCaps:      NSButton!       //2
    @IBOutlet weak var chkRuleUnderscore:   NSButton!       //3

    @IBOutlet weak var txtRuleFileCodelines: NSTextField!   //4 101
    @IBOutlet weak var txtRuleFuncCodelines: NSTextField!   //5 102
    @IBOutlet weak var txtRuleMinSwiftVer:   NSTextField!   //6 201
    @IBOutlet weak var txtRuleOrganization:  NSTextField!   //7 301

    @IBOutlet weak var chkDefault:          NSButton!
    @IBOutlet weak var btnOk:               NSButton!

    @IBOutlet weak var menuView: NSView!

    @IBOutlet weak var tableView:    NSTableView!
    @IBOutlet weak var tableCheckEnabled: NSButton!
    

    //MARK:- @IBActions

    @IBAction func tableCheck1(_ sender: NSButtonCell) {

    }

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

    @IBAction func txtRuleCodeLinesInFuncChange(_ sender: Any) {    //5 102
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

    @IBAction func txtRuleMinSwiftVerChange(_ sender: Any) {        //6 201
        lblError.stringValue = ""
        let txt = processVer(from: txtRuleMinSwiftVer.stringValue)
        if let val = Double(txt), val >= 3.0, val <= 9.0 {
            let isChange = val != CodeRule.minumumSwiftVersion
            setOkButton(isChange: isChange, bitVal: 0x20)
            txtRuleMinSwiftVer.stringValue = String(format:"%.1f", val)
            minSwiftVer = val
        } else {
            txtRuleFuncCodelines.stringValue = "\(CodeRule.maxFuncCodeLines)"
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
        }//next char
        return newStr
    }//end func

}//end class MenuRulesVC

//MARK:- extension MenuRulesVC: NSTextFieldDelegate
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

// MARK: - NSTableViewDataSource
extension MenuRulesVC: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return Issue.issueArray.count
    }//end func

}//end extension


// MARK: - NSTableViewDelegate
extension MenuRulesVC: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView,
                   viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        let issue = Issue.issueArray[row]
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

class viewIssue: NSTableCellView {
    var row = -1
    @IBOutlet weak var chkEnabled: NSButton!
    @IBOutlet weak var lblParam: NSTextField!
    @IBOutlet weak var txtParam: NSTextField!
    @IBOutlet weak var lblRuleName: NSTextField!
    

    @IBAction func chkEnabledClick(_ sender: NSButton) {
        //print("chkEnabled = \(chkEnabled.state)")
        Issue.issueArray[row].enabled = (chkEnabled.state == .on)
    }

    @IBAction func txt1(_ sender: Any) {
        //print("paramText = \(txtParam.stringValue)")
        Issue.issueArray[row].paramText = txtParam.stringValue

    }
}
