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

// MARK: - CodeRule struct 25-84 = 59-lines
public struct CodeRule {

    //---- CodeRule.saveUserDefaults - Save the Rules in UserDefaults
    static func saveUserDefaults() {
        let defaults = UserDefaults.standard                    //Save UserDefaults

        print("Save Default Rules")
        for (key, rule) in StoredRule.dictStoredRules {
            let udKey = "Rule_" + key
            let value = (rule.enabled ? "true" : "false") + "," + rule.paramText
            print ("userDefault save  \(udKey):  \(value)")
            defaults.set(value, forKey: udKey)
        }

        //UserDefaults.standard.removeObject(forKey: "name")
    }

    //---- getUserDefaults - Get the Rules from UserDefaults
    static func getUserDefaults() {
        let defaults = UserDefaults.standard

        for (key, _) in StoredRule.dictStoredRules {
            let udKey = "Rule_" + key
            if let str = defaults.string(forKey: udKey) {        //7
                let (enabledText, param) = splitLine(str, atCharacter: ",")
                let enabled = (enabledText == "true")
                print("userDefault get  \(key): enabled=\(enabled),  paramText=\(param)")
                StoredRule.dictStoredRules[key]!.enabled   = enabled
                StoredRule.dictStoredRules[key]!.paramText = param
            } else {
                print("Error #\(#line) No UserDefault for \(key)")
            }
        }
    }//end func

}//end struct CodeRules

// MARK: - MenuRulesVC class - UI for changing CodeRules 87-285 = 198-lines
class MenuRulesVC: NSViewController {

    //MARK:- Instance Variables
    static var localRuleArray = [StoredRule]() // Allow user close window without committing changes

    //MARK:- Lifecycle funcs

    override func viewDidLoad() {
        super.viewDidLoad()

        //MenuRulesVC.localIssueArray = StoredRule.dictStoredRules
        MenuRulesVC.localRuleArray = []
        for (_, rule) in StoredRule.dictStoredRules.sorted(by: { $0.value.sortOrder < $1.value.sortOrder }) {
            MenuRulesVC.localRuleArray.append(rule)
        }
        //btnOk.isEnabled = false
        tableView.delegate   = self
        tableView.dataSource = self

        self.tableView.reloadData()

    }//end func

    override func viewWillAppear() {
        //print("MenuRulesVC:", #line, MenuRulesVC.dictStoredRules[0])
    }

    //MARK:- @IBOutlets

    @IBOutlet weak var lblError:            NSTextField!
    //                                              //@IBOutlets

    @IBOutlet weak var chkDefault:          NSButton!
    @IBOutlet weak var btnOk:               NSButton!

    @IBOutlet weak var menuView: NSView!

    @IBOutlet weak var tableView:    NSTableView!
    @IBOutlet weak var tableCheckEnabled: NSButton!
    

    //MARK:- @IBActions

    //---- "Save as Defaults" checkBox change ----
    @IBAction func chkDefaultClicked(_ sender: Any) {

    }

    //---- OK Button Clicked ----
    @IBAction func btnOkClick(_ sender: Any) {
        StoredRule.dictStoredRules = [:]
        for rule in MenuRulesVC.localRuleArray {
            let id = rule.identifier
            StoredRule.dictStoredRules[id] = rule
        }

        if chkDefault.state == .on {
            CodeRule.saveUserDefaults()
        }

        self.view.window?.close()
    }//end func btnOkClick

    //MARK:- Helper funcs

    func removeNonDigits(_ str: String) -> String {
        var newStr = ""
        for char in str {
            if char.isNumber {
                newStr.append(char)
            }
        }
        return newStr
    }//end func

    // not used
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

//MARK:- MenuRulesVC: NSTextFieldDelegate - not used
extension MenuRulesVC: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        if let txtFld = obj.object as? NSTextField {
            print("🔷 \(txtFld.tag) \(txtFld.stringValue)")
            let tag = txtFld.tag
            switch tag {
            case 201:
                //self.txtRule201.stringValue = txtFld.stringValue
                break
            case 301:
                //self.txt301.stringValue = txtFld.stringValue
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
        return MenuRulesVC.localRuleArray.count
    }//end func

}//end extension


// MARK: - MenuRulesVC: NSTableViewDelegate
extension MenuRulesVC: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView,
                   viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        let rule = MenuRulesVC.localRuleArray[row]
        let desc = rule.desc

        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "RuleCell"), owner: nil) as? viewRule {
            cell.row = row
            cell.lblRuleName.stringValue = desc
            cell.chkEnabled.state = rule.enabled ? .on : .off
            //cell.textField?.stringValue = "Label#1: "
            cell.lblParam.stringValue = rule.paramLabel
            if rule.paramLabel.isEmpty {
                cell.txtParam.isHidden = true
            } else {
                cell.txtParam.isHidden = false
                cell.txtParam.stringValue = rule.paramText
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

    //MARK:- class viewRule: NSTableCellView
    class viewRule: NSTableCellView {
        var row = -1
        @IBOutlet weak var chkEnabled: NSButton!
        @IBOutlet weak var lblParam: NSTextField!
        @IBOutlet weak var txtParam: NSTextField!
        @IBOutlet weak var lblRuleName: NSTextField!


        @IBAction func chkEnabledClick(_ sender: NSButton) {
            //print("chkEnabled = \(chkEnabled.state)")
            MenuRulesVC.localRuleArray[row].enabled = (chkEnabled.state == .on)
        }

        // Triggered by "Enter", or Loss-of-focus
        @IBAction func paramTextChange(_ sender: Any) {
            print("paramText = \(txtParam.stringValue)")
            MenuRulesVC.localRuleArray[row].paramText = txtParam.stringValue

        }
    }//end class

