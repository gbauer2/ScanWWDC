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
    //swift rules
    static let bigFunc       = "BigFunc"
    static let bigFile       = "BigFile"
    static let toDo          = "ToDo"
    static let forceUnwrap   = "ForceUnwrap"
    static let global        = "Global"
    static let freeFunc      = "FreeFunc"
    static let varNaming     = "varNaming"
    static let nonCamelVar   = "NonCamelVar"
    static let nameLenMinV   = "NameLenMinV"
    static let nameLenMaxV   = "NameLenMaxV"
    static let noUnderscoreV = "NoUnderscoreV"
    static let noAllCapsV    = "NoAllCapsV"
    static let compoundLine  = "CompoundLine"
    //project rules
    static let productDif    = "ProductDif"
    static let organization  = "Organization"
    static let minVerSwift   = "MinVerSwift"
}

// MARK:- StoredRule struct 46-145 = 99-lines
public struct StoredRule {
    static var dictStoredRules = [String: StoredRule]()    // Points to element of storedRuleArray
    
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

    //MARK: static func loadRules() 88-134 = 46-lines
    //TODO: ToDo: Identify rule-item by header name.
    //--- rule stored in bundle, *enabled & *param also stored in userdefaults
    // (id, 0/1, paramText)static
    static func loadRules() -> [String: StoredRule] {
        var dictRules = [String: StoredRule]()
        
        guard let rulesURL = Bundle.main.path(forResource: "Rules", ofType: "txt") else {
            print("⛔️ Error in StoredRules.swift #\(#line) Could not open file: Rules.txt" )
            return dictRules
        }

        // Read contents of Rules.txt
        var ruleFileContents = ""
        do {
            ruleFileContents = try String(contentsOfFile: rulesURL, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("Failed reading from URL: \(rulesURL), Error: " + error.localizedDescription)
            return dictRules
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
                let id          = items[0].removeEnclosingQuotes()
                let name        = items[1].removeEnclosingQuotes()
                let enabled     = (items[2] == "true" ? true : false)
                let paramLabel  = items[3].removeEnclosingQuotes()
                let paramType   = items[4].removeEnclosingQuotes()
                let paramMin    = Int(items[5].removeEnclosingQuotes())
                let paramMax    = Int(items[6].removeEnclosingQuotes())
                let paramText   = items[7].removeEnclosingQuotes()
                let ruleType    = items[8].removeEnclosingQuotes()
                let sortOrder   = Int(items[9].removeEnclosingQuotes()) ?? 0
                let desc        = items[10].removeEnclosingQuotes()
                let rule = StoredRule(id: id, name: name, desc: desc, enabled: enabled, paramLabel: paramLabel,
                                  paramText: paramText, paramType: paramType, paramMin: paramMin,
                                  paramMax: paramMax, sortOrder: sortOrder, ruleType: ruleType)
                dictRules[id] = rule
            }
        }
        return dictRules
    }//end func loadRules

}//end struct StoredRule
