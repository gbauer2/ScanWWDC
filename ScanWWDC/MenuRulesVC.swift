//
//  MenuRulesVC.swift
//  AnalyseSwiftCode
//
//  Created by George Bauer on 4/4/19.
//  Copyright © 2019,2020 George Bauer. All rights reserved.
//

import Cocoa

public enum ValType {
    case bool, int, text
}

// MARK: - CodeRule struct 16-69 = 53-lines
public struct CodeRule {

    //FIXME: If Rules.txt changes, saveUserDefaults() should be run automatically
    //---- CodeRule.saveUserDefaults - Save the Rules in UserDefaults
    static func saveUserDefaults() {
        let defaults = UserDefaults.standard                    //Save UserDefaults

        print("MenuRulesVC #\(#line)  Save Default Rules")
        for (key, rule) in StoredRule.dictStoredRules {
            let udKey = "Rule_" + key
            let value = (rule.enabled ? "true" : "false") + "," + rule.paramText
            print ("userDefault save  \(udKey):  \(value)")
            defaults.set(value, forKey: udKey)
        }

        // Note: To remove a UserDefault:
        // UserDefaults.standard.removeObject(forKey: "name")
    }

    //---- getUserDefaults - Get the Rules from UserDefaults
    static func getUserDefaults() {
        let defaults = UserDefaults.standard

        // Print Yser Defaults
        let userDefDict = defaults.dictionaryRepresentation()
        print("\n---- User Defaults ----")
        for ud in userDefDict.sorted(by: { $0.key < $1.key }) {
            let key = ud.key
            let value = ud.value
            if !key.hasPrefix("NS") && !key.lowercased().contains("apple") {
                print("\(key.PadRight(30, truncate: true, useEllipsis: true, fillChr: ".")) = \(value)")
            }
        }
        print()

        for (key, _) in StoredRule.dictStoredRules {
            let udKey = "Rule_" + key
            if let str = defaults.string(forKey: udKey) {        //7
                let (enabledTextFromUD, paramFromUD) = splitLine(str, atFirst: ",")
                let enabledFromUD = (enabledTextFromUD == "true")
                print("MenuRulesVC #\(#line)  userDefault get  \(key): enabled=\(enabledFromUD),  paramText=\(paramFromUD)")
                guard let _ = StoredRule.dictStoredRules[key] else {
                    print("⛔️ MenuRulesVC #\(#line) StoredRule.dictStoredRules[\(key)] does not exist.")
                    return
                }
                StoredRule.dictStoredRules[key]?.enabled   = enabledFromUD
                StoredRule.dictStoredRules[key]?.paramText = paramFromUD
            } else {
                print("⛔️ Error - MenuRulesVC #\(#line) -- No UserDefault for \(key)")
            }
        }
    }//end func

}//end struct CodeRules

// MARK: - MenuRulesVC class - UI for changing CodeRules 72-155 = 83-lines
class MenuRulesVC: NSViewController {

    //MARK:- Instance Variables
    static var localRuleArray = [StoredRule]() // Allow user close window without committing changes

    var isEditing = -1

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
        //print("MenuRulesVC:", \(#line), MenuRulesVC.dictStoredRules[0])
    }

    //MARK:- @IBOutlets
    @IBOutlet weak var chkDefault:  NSButton!
    @IBOutlet weak var btnOk:       NSButton!
    @IBOutlet weak var tableView:   NSTableView!
    

    //MARK:- @IBActions

    //---- "Save as Defaults" checkBox change ----
    @IBAction func chkDefaultClicked(_ sender: Any) {

    }

    //---- OK Button Clicked ----
    @IBAction func btnOkClick(_ sender: Any) {
        if isEditing >= 0 {
            //TODO: Force "End Editing" rather than alerting
            //TODO: Cancel Button
            //TODO: Separate "Save for now" & "Save Permanently" buttons
            let text = "You must hit 'Return' to finish editing #\(isEditing) \(MenuRulesVC.localRuleArray[isEditing].name)"
            GBox.alert(text)
            return
        }
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

}//end class MenuRulesVC

//MARK:- NSTextFieldDelegate
extension MenuRulesVC: NSTextFieldDelegate {

    override func validateProposedFirstResponder(_ responder: NSResponder, for event: NSEvent?) -> Bool {
        if let txtField = responder as? NSTextField {
            let ruleText = getRuleText(txtField)
            var eventTxt = ""
            if let event = event {
                eventTxt = "\(event.type.rawValue)"
            }
            print("👅\(#line) FirstResponder: \(ruleText)     eventType \(eventTxt)")
            txtField.delegate = self
        }
        return true
    }

    func getRuleText(_ txtField: NSTextField) -> String {
        let rule = MenuRulesVC.localRuleArray[txtField.tag]
        return " [#\(txtField.tag) \(rule.name) = \(txtField.stringValue)] "
    }

    func controlTextDidBeginEditing(_ obj: Notification) {
        if let txtField = obj.object as? NSTextField {
            let ruleText = getRuleText(txtField)
            print("➡️➡️\(#line) controlTextDidBeginEditing delegate: \(ruleText)")
        }
    }

    func controlTextDidEndEditing(_ obj: Notification) {
         if let txtField = obj.object as? NSTextField {
             let ruleText = getRuleText(txtField)
            isEditing = -1
             print("⬅️⬅️\(#line) controlTextDidEndEditing delegate: \(ruleText)")
         }
     }

    //
    func controlTextDidChange(_ obj: Notification) {
        if let txtField = obj.object as? NSTextField {
            let ruleText = getRuleText(txtField)
            isEditing = txtField.tag
            print("⚠️\(#line) controlTextDidChange delegate: \(ruleText)")
        }
    }//end func


    //
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        if let txtField = control as? NSTextField {
            let ruleText = getRuleText(txtField)
            print("⬅️\(#line) textShouldEndEditing delegate: \(ruleText) \(txtField.stringValue)")
        }
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

// MARK: - NSTableViewDataSource
extension MenuRulesVC: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return MenuRulesVC.localRuleArray.count
    }//end func

}//end extension


// MARK: - NSTableViewDelegate
extension MenuRulesVC: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView,
                   viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        let rule = MenuRulesVC.localRuleArray[row]
        let desc = rule.desc
        // 11 chars = 88
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "RuleCell"), owner: nil) as? ViewRule {
            cell.row = row
            cell.lblRuleName.stringValue = desc
            cell.chkEnabled.state = rule.enabled ? .on : .off
            //cell.textField?.stringValue = "Label#1: "
            cell.lblParam.stringValue = rule.paramLabel
            cell.txtParam.tag = row             // Identify for NSTextFieldDelegate
            if rule.paramLabel.isEmpty {
                cell.txtParam.isHidden = true
            } else {
                cell.txtParam.isHidden = false
                if rule.paramText.count > 4 {
                    var size = cell.txtParam.frame.size
                    let width =  min( CGFloat(rule.paramText.count) * 8.6, 225)
                    size.width = width
                    cell.txtParam.setFrameSize(size)
                }
                cell.txtParam.stringValue = rule.paramText
            }
            return cell
        }
        return nil
    }//end func

    func tableViewSelectionDidChange(_ notification: Notification) {
        if tableView.selectedRow < 0 {
            print("⛔️ Error - MenuRulesVC #\(#line) -- bad tableView selection")
            return
        }
        print("MenuRulesVC #\(#line) -- Selected Row # \(tableView?.selectedRow ?? -1)")
    }//end func

}//end extension

//MARK:- Table Cell (class ViewRule: NSTableCellView)
class ViewRule: NSTableCellView, NSTextFieldDelegate {
    var row = -1
    @IBOutlet weak var chkEnabled: NSButton!
    @IBOutlet weak var lblParam:    NSTextField!
    @IBOutlet weak var txtParam:    NSTextField!
    @IBOutlet weak var lblRuleName: NSTextField!


    @IBAction func chkEnabledClick(_ sender: NSButton) {
        //print("MenuRulesVC #\(#line) -- chkEnabled = \(chkEnabled.state)")
        MenuRulesVC.localRuleArray[row].enabled = (chkEnabled.state == .on)
    }

    // Triggered by "Enter", or Loss-of-focus
    @IBAction func paramTextChange(_ sender: Any) {
        print("🤪🤪 MenuRulesVC #\(#line) @IBAction func paramTextChange -- paramText = \(txtParam.stringValue)")
        MenuRulesVC.localRuleArray[row].paramText = txtParam.stringValue
    }

}//end class

