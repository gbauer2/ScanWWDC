//
//  FindVBCode.swift
//  AnalyseSwiftCode
//
//  Created by George Bauer on 2/14/19.
//  Copyright © 2018,2019 George Bauer. All rights reserved.//

import Foundation

//MARK:- Globals
var gDictVBwords = [String: Int]()

//MARK:- List of Words
let varVBs =  ["vbCr", "vbLf", "VBcompPrintToLog", "knownProblems"]
let funcVBs = ["UCase", "LCase", "Left", "Right", "Mid", "MidEquals", "InStr", "InStrRev", "Trim", "LTrim", "RTrim",
            "IsNumeric", "Len", "Space", "CInt", "CDbl", "CSng", "Val", "Sign", "Round", "Split", "Weekday", "DateString",
            "CDate", "ChangeExtension", "PathCombine", "GetFileNameWithoutExtension", "GetFileName",
            "GetParentPath", "Format", "Str", "Ljust", "Rjust", "Asc", "Char", "Like", "MsgBox"]
let fileIOVBs = ["FileOpen", "GetNumberOfLines", "FileClose", "LineInput", "EOF", "WriteLine", "Print", "PrintLine", "FreeFile"]
let vbVBs  = ["VB.Left", "VB.Right", "VB.DirectoryExists", "VB.FileExists", "VB.CreateDirectory", "VB.CreateFile", "VB.DeleteFile"
                ,"VB.Rename", "VB.CopyFile", "VB.Month", "VB.Day", "VB.Year", "VB.Hour", "VB.Minute", "VB.Second"]
let pseudoBoxVBs = ["ListBox", "RichTextBox"]
let strExtVBs = [".Substring", ".Split"]

//MARK:- funcs
public func resetVBwords() {
    gDictVBwords = [:]
    for word in varVBs {
        gDictVBwords[word] = 0
    }
    for word in funcVBs {
        gDictVBwords[word] = 0
    }
    for word in fileIOVBs {
        gDictVBwords[word] = 0
    }
    for word in vbVBs {
        gDictVBwords[word] = 0
    }
    for word in strExtVBs {
        gDictVBwords[word] = 0
    }
}
