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
    var displayGroup = 0
    var enabled     = true
    var paramLabel  = ""
    var paramText   = ""
    var paramType   = ""
    var paramMin:   Int?
    var paramMax:   Int?
    var items       = [LineItem]()
    init(id: String, name: String, desc: String, enabled: Bool) {
        self.identifier = id
        self.name    = name
        self.desc    = desc
        self.enabled = enabled
    }
    init(id: String, name: String, desc: String, enabled: Bool, paramLabel: String, paramText: String) {
        self.identifier = id
        self.name    = name
        self.desc    = desc
        self.enabled = enabled
        self.paramLabel  = paramLabel
        self.paramText  = paramText
    }
}

// id
//"desc"
//name,ruleType,sortGroup#(or name)
//*enabled
//paramLabel, paramType, paramMin, paramMax, *paramText
//--- rule stored in bundle, *enabled & *param also stored in userdefaults
// (id, 0/1, paramText)
public func loadIssues() {
//    var issue = Issue(id: "??", name: "???", desc: "????", enabled: false)
//    var issues  = [Issue]()
//    var dictIssues = [String: Int]()

}

//TODO: Replace setDefaultIssues() with external table
public func setDefaultIssues() -> ([Issue], [String: Int])  {
    var issue = Issue(id: "??", name: "???", desc: "????", enabled: false)
    var issues  = [Issue]()
    var dictIssues = [String: Int]()

    issue       = Issue(id: "BigFile", name: "Massive File",  desc: "File too large",               enabled: true)
    issue.paramLabel = "Max: "
    issue.paramText  = "520"
    issues.append(issue)

    issue       = Issue(id: "BigFunc",  name: "Massive func", desc: "Function too large",           enabled: true)
    issue.paramLabel = "Max: "
    issue.paramText  = "140"
    issues.append(issue)

    issues.append(Issue(id: "ToDo",     name: "ToDoFixMe",    desc: "\"TODO:\" or \"FIXME:\" line", enabled: true))
    issues.append(Issue(id: "Naming",   name: "NonCamelCase", desc: "NonCamelCase Variable",        enabled: true))
    issues.append(Issue(id: "F_Unwrap", name: "Force-Unwrap", desc: "Force-Unwrap",                 enabled: true))
    issues.append(Issue(id: "VB",       name: "VBCompatCall", desc: "VBCompatability Call",         enabled: false))
    issues.append(Issue(id: "FreeFunc", name: "FreeFunc",     desc: "Free Function",                enabled: true))
    issues.append(Issue(id: "Global",   name: "Global",       desc: "Global Variable",              enabled: true))
    issues.append(Issue(id: "Compound", name: "Compound",     desc: "Compound Line",                enabled: true))

    for (i, issue) in issues.enumerated() {
        dictIssues[issue.identifier] = i
    }
    return (issues, dictIssues)
}

