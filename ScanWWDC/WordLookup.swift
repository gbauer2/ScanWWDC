//
//  WordLookup.swift
//  AnalyseSwiftCode
//
//  Created by George Bauer on 1/12/19.
//  Copyright © 2019 George Bauer. All rights reserved.//

import Foundation

//MARK:- Word Lookup for keyWords & VBWords 11-111 = 100-lines
public struct WordLookup {

    //MARK:- List of Swift KeyWords

    private static let keyWords =
    ["associatedtype","class","deinit","enum","extension","fileprivate","func","import","init","inout","internal",
    "let","open","operator","private","protocol","public","static","struct","subscript","typealias","var",

    "break","case","continue","default","defer","do","else","fallthrough","for","guard",
    "if","in","repeat","return","switch","where","while",

    "Any","as","catch","false","is","nil","rethrows","self","Self","super","throw","throws","true","try","_",

    "#available","#colorLiteral","#column","#else","#elseif","#endif","#file","#fileReference","#function",
    "#if","#imageLiteral","#line","#selector","#sourceLocation",
    "@IBOutlet","@IBAction",

    "associativity","convenience","dynamic","didSet","final","get","infix","indirect",
    "lazy","left","mutating","none","nonmutating", "optional","override","postfix","precedence","prefix",
    "required","right","set","Type","unowned","weak","willSet"
    ]

    //MARK: init Swift KeyWords

    static var dictKeyWords = [String: Int]()

    static func initKeyWords() {
        let zipped = zip(keyWords, Array(repeating: 0, count: keyWords.count) )
        dictKeyWords = Dictionary(uniqueKeysWithValues: zipped)
    }//end func

    static func isKeyword(word: String) -> Bool {
        return dictKeyWords[word] != nil
    }

    //MARK: List of VB Words
    // Last group ("associativity",..."willSet") are keywords only in context

    private static let varVBs  = ["vbCr", "vbLf", "VBcompPrintToLog", "knownProblems"]
    private static let funcVBs = ["UCase", "LCase", "Left", "Right", "Trim", "LTrim", "RTrim",
                   "IsNumeric", "Len", "Space", "CInt", "CDbl", "CSng", "Val", "Sign", "Round", "Split", "Weekday",
                   "DateString", "CDate", "ChangeExtension", "PathCombine", "GetFileNameWithoutExtension", "GetFileName",
                   "GetParentPath", "Format", "Str", "Ljust", "Rjust", "Asc", "Char", "Like", "MsgBox", "GreatCircAng", "GreatCircDist", "DecodeDegMin", "LatText", "LonText", "LLtext", "HourMin24", "IsDayLite", "DeCode3LetterMon", "MonthToText", "LJust", "RJust", "NumSuffix"]

    private static let vbVBs      = ["VB.Left", "VB.Right", "VB.DirectoryExists", "VB.FileExists", "VB.CreateDirectory",
                      "VB.CreateFile", "VB.DeleteFile", "VB.Rename", "VB.CopyFile",
                      "VB.Month", "VB.Day", "VB.Year", "VB.Hour", "VB.Minute", "VB.Second"]
    private static let pseudoBoxVBs = ["ListBox", "RichTextBox"]
    private static let strExtVBs    = [".Substring", ".Split"]

    // VBCompatability funcs using base-1 String indices
    private static let string1VBs = ["Mid", "MidEquals", "InStr", "InStrRev", ]
    // VBCompatability funcs doing file I/O
    private static let fileIOVBs  = ["FileOpen", "GetNumberOfLines", "FileClose", "LineInput", "EOF",
                                     "WriteLine", "Print", "PrintLine", "FreeFile"]

    //MARK: initVBwords

    static var dictVBwords = [String: Int]()
    static var dictVBstringWords = [String: Int]()
    static var dictVBfileWords = [String: Int]()
    static func initVBwords() {
        dictVBwords = [:]               // Most VBCompatability funcs
        for word in varVBs {
            dictVBwords[word] = 1
        }
        for word in funcVBs {
            dictVBwords[word] = 2
        }
        for word in vbVBs {
            dictVBwords[word] = 5
        }
        for word in strExtVBs {
            dictVBwords[word] = 6
        }


        dictVBstringWords = [:]         // VBCompatability funcs using base-1 String indices
        for word in string1VBs {
            dictVBstringWords[word] = -3
        }

        dictVBfileWords = [:]           // VBCompatability funcs doing file I/O
        for word in fileIOVBs {
            dictVBfileWords[word] = -4
        }
    }//end initVBwords

    static func isVBword(word: String) -> Bool {
        return dictVBwords[word] != nil
    }

    static func isVBstringWord(word: String) -> Bool {
        return dictVBstringWords[word] != nil
    }

    static func isVBfileWord(word: String) -> Bool {
        return dictVBfileWords[word] != nil
    }

}//end struct WordLookup
