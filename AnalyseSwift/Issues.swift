//
//  Issues.swift
//  AnalyseSwiftCode
//
//  Created by George Bauer on 5/28/19.
//  Copyright © 2019 Ray Wenderlich. All rights reserved.
//

import Foundation


//MARK:- Neww
// List of SwiftSummary issues - not used
//private enum IssueIndex {
//    static let nonCamelVar  = 0
//    static let compoundLine = 2
//    static let forceUnwrap  = 3
//    static let vbCompatCall = 4
//    static let freeFunc     = 5
//    static let global       = 6
//    static let massiveFunc  = 7
//    static let massiveFile  = 8
//    static let count        = 9
//}

//TODO: Add label2, param2, Type1, Type2, 3?, sortGroup#(or name), RuleType, Range1-3
public struct Issue {
    static var issueArray = [Issue]()          // Holds all the possible issues
    static var dictIssues = [String: Int]()    // Points to element of issueArray
    
    var identifier: String
    var name:       String
    var desc:       String
    var enabled     = true
    var paramLabel  = ""
    var paramText   = ""
    var paramType   = ""
    var paramMin:   Int?
    var paramMax:   Int?
    var displayGroup = ""
    var ruleType    = ""
    var items       = [LineItem]()
    init(id: String, name: String, desc: String, enabled: Bool) {
        self.identifier = id
        self.name    = name
        self.desc    = desc
        self.enabled = enabled
    }
    init(id: String, name: String, desc: String, enabled: Bool, paramLabel: String, paramText: String,
         paramType: String, paramMin: Int?,  paramMax: Int?, displayGroup: String, ruleType: String) {
        self.identifier   = id
        self.name         = name
        self.desc         = desc
        self.enabled      = enabled
        self.paramLabel   = paramLabel
        self.paramText    = paramText
        self.paramType    = paramType
        self.paramMin     = paramMin
        self.paramMax     = paramMax
        self.displayGroup = displayGroup
        self.ruleType     = ruleType
    }
    
    //--- rule stored in bundle, *enabled & *param also stored in userdefaults
    // (id, 0/1, paramText)static
    static func loadRules() -> ([Issue], [String: Int]) {
        //var issue = Issue(id: "??", name: "???", desc: "????", enabled: false)
        var issues  = [Issue]()
        var dictIssues = [String: Int]()
        
        // File location
        guard let rulesURL = Bundle.main.path(forResource: "Rules", ofType: "txt") else {
            print("⛔️ Error in Issues.swift #\(#line) Could not open file: Rules.txt" )
            return (issues, dictIssues)
        }
        // Read from the file
        var ruleFileContents = ""
        do {
            ruleFileContents = try String(contentsOfFile: rulesURL, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("Failed reading from URL: \(rulesURL), Error: " + error.localizedDescription)
            return (issues, dictIssues)
        }
        print(ruleFileContents)
        
        let lines = ruleFileContents.components(separatedBy: "\n").map { $0.trim }.filter { !$0.isEmpty }
        
        var itemNames = [String]()
        for (i, line) in lines.enumerated() {
            let items = line.components(separatedBy: ",").map { $0.trim }
            if i == 0 {
                itemNames = items
                print(itemNames)
            } else {
                let id           = stripQuotes(from: items[0])
                let name         = stripQuotes(from: items[1])
                let enabled      = (items[2] == "true" ? true : false)
                let paramLabel   = stripQuotes(from: items[3])
                let paramType    = stripQuotes(from: items[4])
                let paramMin     = Int(stripQuotes(from: items[5]))
                let paramMax     = Int(stripQuotes(from: items[6]))
                let paramText    = stripQuotes(from: items[7])
                let ruleType     = stripQuotes(from: items[8])
                let displayGroup = stripQuotes(from: items[9])
                let desc         = stripQuotes(from: items[10])
                let issue = Issue(id: id, name: name, desc: desc, enabled: enabled, paramLabel: paramLabel,
                                  paramText: paramText, paramType: paramType, paramMin: paramMin,
                                  paramMax: paramMax, displayGroup: displayGroup, ruleType: ruleType)
                issues.append(issue)
            }
        }
        
        for (i, issue) in issues.enumerated() {
            dictIssues[issue.identifier] = i
        }
        return (issues, dictIssues)
    }//end func loadRules
    
    private static func stripQuotes(from str: String) -> String {
        if str.hasPrefix("\"") && str.hasSuffix("\"") {
            let newStr = String(str.dropFirst().dropLast())
            return newStr
        } else {
            return str
        }
    }
}//end struct Issue
