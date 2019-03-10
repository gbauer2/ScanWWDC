//
//  keywords.swift
//  AnalyseSwiftCode
//
//  Created by George Bauer on 1/12/19.
//  Copyright © 2019 George Bauer. All rights reserved.//

import Foundation

// Any, Type
//TODO: Make dictionary; Last group ("associativity",..."willSet") are keywords only in context
// interpolation: "\(varble)"

let keyWords = ["associatedtype","class","deinit","enum","extension","fileprivate","func","import","init","inout","internal",
            "let","open","operator","private","protocol","public","static","struct","subscript","typealias","var",

            "break","case","continue","default","defer","do","else","fallthrough","for","guard",
            "if","in","repeat","return","switch","where","while",

            "Any","as","catch","false","is","nil","rethrows","super","self","Self","throw","throws","true","try","_",

            "#available","#colorLiteral","#column","#else","#elseif","#endif","#file","#fileReference","#function",
            "#if","#imageLiteral","#line","#selector","#sourceLocation",
            "@IBOutlet","@IBAction",

            "associativity","convenience","dynamic","didSet","final","get","infix","indirect",
            "lazy","left","mutating","none","nonmutating", "optional","override","postfix","precedence","prefix",
            "required","right","set","Type","unowned","weak","willSet","super"
]

func isKeyword(word: String) -> Bool {
    if keyWords.contains(word) {
        return true
    } else {
        return false
    }
}

