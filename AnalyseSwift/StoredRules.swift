//
//  StoredRules.swift
//  AnalyseSwiftCode
//
//  Created by George Bauer on 5/28/19.
//  Copyright © 2019 Ray Wenderlich. All rights reserved.
//
import Foundation

// Places to change from CodeRules (maxFuncCodeLines)
//  MenuRulesVC.swift
//      static var               23x                static storedRuleArray,dictStoredRules    24
//      saveUserDefaults()       61x        67
//      getUserDefaults()        96x        98
//      viewDidLoad()           145x        161
//      btnOkClick()            228x        N/A
//      txtRuleCodeLinesInFuncChange()  281
//      txtRuleCodeLinesInFuncChange()  286
//  AnalyseSwift.swift          867x
//  AnalyseXcodeproj.swift      719
//  FormatSwiftSummary.swift    196x

// MARK:- enum RuleID List of Rule Identifiers
public enum RuleID {
    static let bigFunc      = "BigFunc"
    static let bigFile      = "BigFile"
    static let toDo         = "ToDo"
    static let forceUnwrap  = "ForceUnwrap"
    static let global       = "Global"
    static let freeFunc     = "FreeFunc"
    static let compoundLine = "CompoundLine"
}

// MARK:- StoredRule struct 35-140 = 105-lines
public struct StoredRule {
    static var storedRuleArray = [StoredRule]()     // Holds all the possible StoredRules
    static var dictStoredRules = [String: Int]()    // Points to element of storedRuleArray
    
    var identifier: String
    var name:       String
    var desc:       String
    var enabled     = true
    var paramLabel  = ""
    var paramText   = ""
    var paramType   = ""
    var paramMin:   Int?
    var paramMax:   Int?
    var sortOrder   = 0
    var ruleType    = ""
    var paramInt:   Int? { return Int(paramText)}

    //MARK: Initializers
    init(id: String, name: String, desc: String, enabled: Bool) {
        self.identifier = id
        self.name    = name
        self.desc    = desc
        self.enabled = enabled
    }
    init(id: String, name: String, desc: String, enabled: Bool, paramLabel: String, paramText: String,
         paramType: String, paramMin: Int?,  paramMax: Int?, sortOrder: Int, ruleType: String) {
        self.identifier = id
        self.name       = name
        self.desc       = desc
        self.enabled    = enabled
        self.paramLabel = paramLabel
        self.paramText  = paramText
        self.paramType  = paramType
        self.paramMin   = paramMin
        self.paramMax   = paramMax
        self.sortOrder  = sortOrder
        self.ruleType   = ruleType
    }

    //MARK: static func loadRules() 78-129 = 51-lines
    //TODO: ToDo: Identify rule-item by header name.
    //--- rule stored in bundle, *enabled & *param also stored in userdefaults
    // (id, 0/1, paramText)static
    static func loadRules() -> ([StoredRule], [String: Int]) {
        var rules       = [StoredRule]()
        var dictRules   = [String: Int]()
        
        guard let rulesURL = Bundle.main.path(forResource: "Rules", ofType: "txt") else {
            print("⛔️ Error in StoredRules.swift #\(#line) Could not open file: Rules.txt" )
            return (rules, dictRules)
        }

        // Read contents of Rules.txt
        var ruleFileContents = ""
        do {
            ruleFileContents = try String(contentsOfFile: rulesURL, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("Failed reading from URL: \(rulesURL), Error: " + error.localizedDescription)
            return (rules, dictRules)
        }
        print(ruleFileContents)
        
        let lines = ruleFileContents.components(separatedBy: "\n").map { $0.trim }.filter { !$0.isEmpty }

        // Parse the file
        var itemNames = [String]()
        for (i, line) in lines.enumerated() {
            let items = line.components(separatedBy: ",").map { $0.trim }
            if i == 0 {
                itemNames = items
                print(itemNames)
            } else {
                let id          = stripQuotes(from: items[0])
                let name        = stripQuotes(from: items[1])
                let enabled     = (items[2] == "true" ? true : false)
                let paramLabel  = stripQuotes(from: items[3])
                let paramType   = stripQuotes(from: items[4])
                let paramMin    = Int(stripQuotes(from: items[5]))
                let paramMax    = Int(stripQuotes(from: items[6]))
                let paramText   = stripQuotes(from: items[7])
                let ruleType    = stripQuotes(from: items[8])
                let sortOrder   = Int(stripQuotes(from: items[9])) ?? 0
                let desc        = stripQuotes(from: items[10])
                let rule = StoredRule(id: id, name: name, desc: desc, enabled: enabled, paramLabel: paramLabel,
                                  paramText: paramText, paramType: paramType, paramMin: paramMin,
                                  paramMax: paramMax, sortOrder: sortOrder, ruleType: ruleType)
                rules.append(rule)
            }
        }
        
        for (i, rule) in rules.enumerated() {
            dictRules[rule.identifier] = i
        }
        return (rules, dictRules)
    }//end func loadRules

    //MARK: Helper funcs
    private static func stripQuotes(from str: String) -> String {
        if str.hasPrefix("\"") && str.hasSuffix("\"") {
            let newStr = String(str.dropFirst().dropLast())
            return newStr
        } else {
            return str
        }
    }
}//end struct StoredRule
