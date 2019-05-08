//
//  CodeLineDetails.swift
//  AnalyseSwiftCode
//
//  Created by George Bauer on 4/27/19.
//  Copyright © 2019 George Bauer. All rights reserved.
//

import Foundation

enum QuoteStatus {
    case inRegular, inRawString, notInQuotes
}

public struct CodeLineDetail {
    var trimLine = ""               // The entire line - trimmed
    var codeLine = ""               // The Code portion (clean of comments & quotes
    var hasTrailingComment = false
    var hasEmbeddedComment = false
    var hasInterpolation   = false  // not used
    var isComment          = false  // Entire line is Comment
    var isMarkup           = false  // Entire line is Mark-up
    var parenMismatch      = 0      // Flags for Line-Continuation
    var bracketMismatch    = 0
    var inTripleQuote      = false  // Multi-line state
    var inBlockComment     = false
    var inBlockMarkup      = false
    init() {}

    /// Strip comments & neutralize quotes from trimmed sourcecode line
    ///
    /// - Parameters:
    ///   - fullLine: Swift source code line
    ///   - lineNum: Swift source line number
    ///   - prevCodeLineDetail: provides: inTripleQuote: inside multi-line string literal?  inBlockComment: inside block comment (/*.../*)?  inBlockMarkup: inside a block markup  (/**.../*)?
    /// - Returns: CodeLineDetail
    init(fullLine: String, prevCodeLineDetail: CodeLineDetail, lineNum: Int) { //37-216 = 179-lines
        //TODO: Raw-string delimiters with more than 1 asterisk **"..."**
        //TODO: Raw-triple-quote    *"""
        //TODO: Mark-up detection   ///     /**.../*
        //TODO: Add return isMarkup (struct?)
        let trimLine = fullLine.trim
        let dummyChar: Character = "~"

        self = CodeLineDetail()
        self.trimLine       = trimLine
        self.inBlockComment = prevCodeLineDetail.inBlockComment
        self.inBlockMarkup  = prevCodeLineDetail.inBlockMarkup
        self.inTripleQuote  = prevCodeLineDetail.inTripleQuote
        var inBlockCommentOrMarkup = self.inBlockComment || self.inBlockMarkup

        // inBlockCommentOrMarkup with no end in sight
        if (inBlockCommentOrMarkup) && !trimLine.contains("*/") {
            if self.inBlockComment { self.isComment = true }
            if self.inBlockMarkup  { self.isMarkup  = true }
            return                          // Whole line is in BlockComment or BlockMarkup
        }

        // All code & nothing to see here
        if !trimLine.contains("//") && !trimLine.contains("\"") && !trimLine.contains("/*")  && !trimLine.contains("*/")
            && !trimLine.contains("(") && !trimLine.contains("[") {
            self.codeLine = trimLine
            return                        // No comment or quote
        }
        if trimLine.hasPrefix("\"\"\"") || trimLine.hasSuffix("\"\"\"") {
            self.inTripleQuote.toggle()
        }
        if !inBlockCommentOrMarkup && trimLine.hasPrefix("//") {
            if trimLine.hasPrefix("///") {
                self.isMarkup = true
            } else {
                self.isComment = true
            }
            return
        }
        let blockCommentStr  = "⌇"
        let blockCommentChar = Character(blockCommentStr)
        let quoteChar        = Character("\"")

        // Block comment ignores all but "\" and "*/"
        // Raw String ignores all but \# and "#
        //#”You can use “ and “\” in a raw string. Interpolating as \#(var).”#
        //  #"  "#    //    /*  */    \    \#
        var pComment    = -1
        var preserveQuote = false
        var isEscaped   = false
        var prevChar    = Character(" ")
        var chars = Array(trimLine)
        var quoteStatus: QuoteStatus = .notInQuotes     // inRegular, inRawString, notInQuotes
        var inInterpolate = false
        var interpolateParenDepth = 0

        for (p, char) in chars.enumerated() {

            //if char == "(" { isEscaped = false }
            if !isEscaped && !inBlockCommentOrMarkup {      //--- Not Escaped & Not inBlockComment & Not inBlockMarkup

                if quoteStatus == .notInQuotes {                // ------------ NOT in quotes

                    if char == quoteChar {                              //- Quote (")
                        preserveQuote = true
                        if prevChar == "#" {        // #" as in #"xxx"#
                            quoteStatus = .inRawString  //????? Count "#"s here
                        } else {
                            quoteStatus = .inRegular
                        }

                    } else if char == "*" {                             //- Asterisk "*"
                        if prevChar == "/" {   // "/*"   // --not inQuotes
                            chars[p-1] = blockCommentChar
                            self.hasEmbeddedComment = true
                            if p >= chars.count || chars[p+1] != "*" {
                                self.inBlockComment = true
                            } else {
                                self.inBlockMarkup = true
                            }
                            inBlockCommentOrMarkup = true
                        }

                    }  else if char == "/" {                            //- Comment "//"
                        if prevChar == "/" {
                            pComment = p
                            self.hasTrailingComment = true
                            break                               // EXIT LOOP
                        }

                    } else if char == "(" {
                        self.parenMismatch += 1
                    } else if char == ")" {
                        self.parenMismatch -= 1
                    } else if char == "[" {
                        self.bracketMismatch += 1
                    } else if char == "]" {
                        self.bracketMismatch -= 1

                    }//endif char


                } else if quoteStatus == .inRawString {         // ------------ in Raw String

                    if char == "#" {                                // Hashtag "#"
                        //Need changing for ###"..."###
                        if prevChar == quoteChar {          // "# as in #"xxx"#
                            // Check "#"s count here
                            chars[p-1] = quoteChar      // restore "
                            quoteStatus = .notInQuotes  // end of RawString
                        } else if prevChar == "\\" && chars[p+1] == "(" {
                            inInterpolate = true
                            interpolateParenDepth = 0
                            chars[p]   = dummyChar
                            chars[p-1] = dummyChar
                        }
                    }

                } else if quoteStatus == .inRegular {           // ------------ in Regular quotes

                    if char == quoteChar {                              //- Quote (")
                        quoteStatus = .notInQuotes

                    } else if char == "\\" && chars[p+1] != "(" {       //- BackSlash "\"
                        isEscaped = true
                    } else if char == "(" && prevChar == "\\" {
                        inInterpolate = true
                        interpolateParenDepth = 0
                    }


                }//endif quoteStatus

            } else {
                isEscaped = false
            }//endif Not escaped and Not blockComment

            // Mark Comment Char & Check for End of Block
            if inBlockCommentOrMarkup {
                if char == "/" && prevChar == "*" {         // "*/"
                    self.inBlockComment = false
                    self.inBlockMarkup = false
                    inBlockCommentOrMarkup = false
                }
                chars[p] = blockCommentChar
            }

            // Make quoted Char benign (needs to change for interpolation)
            if quoteStatus != .notInQuotes {
                if preserveQuote {          // Preserve the opening quotation mark
                    preserveQuote = false
                } else if inInterpolate {
                    if char == "(" {
                        if interpolateParenDepth == 0 { chars[p] = " " }
                        interpolateParenDepth += 1
                    } else if char == ")" {
                        interpolateParenDepth -= 1
                        if interpolateParenDepth == 0 {
                            chars[p] = " "
                            inInterpolate = false
                        }
                    }
                } else {
                    chars[p] = dummyChar
                }
            }

            prevChar = char
        }//next p
        //----------------------

        let codeLine: String
        if pComment >= 0 {
            let sliceChars = chars.prefix(pComment - 1)
            codeLine = String(sliceChars).replacingOccurrences(of: blockCommentStr, with: "")
        } else {
            codeLine = String(chars).replacingOccurrences(of: blockCommentStr, with: "")
        }
        self.codeLine = codeLine.trim
    }//end init
}//end struct
