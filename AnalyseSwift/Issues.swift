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

//TODO: Add identifier longName, rulesStr[:], rulesInt[:]
public struct Issue {
    var name        = ""
    var desc        = ""
    var enabled     = true
    var rules       = [String: String]()
    var items       = [LineItem]()
    var dict        = [String: Int]()
    init(name: String, desc: String, enabled: Bool) {
        self.name    = name
        self.desc    = desc
        self.enabled = enabled
    }
    init(name: String, desc: String, enabled: Bool, rules: [String: String]) {
        self.name    = name
        self.desc    = desc
        self.enabled = enabled
        self.rules   = rules
    }
}
//MARK:- end Neww


public func getDefaultIssues() -> [String: Issue]  {
    var issues = [String: Issue]()

    issues["ToDo"]      = Issue(name: "ToDoFixMe",      desc: "TODO: or FIXME:",        enabled: true)
    issues["Naming"]    = Issue(name: "NonCamelCase",   desc: "NonCamelCase",           enabled: true)
    issues["F_Unwrap"]  = Issue(name: "Force-Unwrap",   desc: "Force-Unwrap",           enabled: true)
    issues["VB"]        = Issue(name: "VB",             desc: "VBCompatability Call",   enabled: true)
    issues["FreeFunc"]  = Issue(name: "FreeFunc",       desc: "Free Func",              enabled: true)
    issues["Global"]    = Issue(name: "Global",         desc: "Global",                 enabled: true)
    issues["Compound"]  = Issue(name: "Compound",       desc: "Compound Line",          enabled: true)
    issues["LargeFunc"] = Issue(name: "Massive func",   desc: "Very large func",        enabled: true)
    issues["LargeFile"] = Issue(name: "Massive File",   desc: "Very large file",        enabled: true)

    return issues
}

