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
enum InMultiLine {
    case none, tripleQuote, blockComment, blockMarkup
}
public struct CodeLineDetail {
    var trimLine = ""               // The entire original line - trimmed
    var codeLine = ""               // The Code portion (clean of comments & quotes)
    var lineNum  = 0                // Original Source Line Number
    var hasTrailingComment = false  // Has code followed by "//"
    var hasEmbeddedComment = false  // Has /*...*/
    var isComment          = false  // Entire line is Comment
    var isMarkup           = false  // Entire line is Mark-up
    var parenMismatch      = 0      // Flag for Line-Continuation ()
    var bracketMismatch    = 0      // Flag for Line-Continuation []
    var openCurlyCount     = 0      // Number of "{"s in line
    var closeCurlyCount    = 0      // Number of "}"s in line
    var firstSplitter: Character?   // String value of first ";", "{", or "}" in line
    var inMultiLine: InMultiLine = .none    // tripleQuote, blockComment, blockMarkup

    init() {}       // replace the default initializer

    /// Strip comments & neutralize quotes from trimmed sourcecode line
    ///
    /// - Parameters:
    ///   - fullLine: Swift source code line
    ///   - lineNum: Swift source line number
    ///   - prevCodeLineDetail: provides: inMultiLine: none, tripleQuote, blockComment, or blockMarkup
    /// - Returns: CodeLineDetail
    init(fullLine: String, inMultiLine: InMultiLine, lineNum: Int) { //38-219 = 181-lines
        //TODO: Raw-string delimiters with more than 1 asterisk **"..."**
        //TODO: Raw-triple-quote    *"""
        //TODO: Mark-up detection   ///     /**.../*
        //TODO: Add return isMarkup (struct?)
        let trimLine = fullLine.trim
        let dummyChar: Character = "~"

        self = CodeLineDetail()
        self.trimLine    = trimLine
        self.lineNum     = lineNum
        self.inMultiLine = inMultiLine
        var inBlockCommentOrMarkup = self.inMultiLine == .blockComment || self.inMultiLine == .blockMarkup

        // inBlockCommentOrMarkup with no end in sight
        if (inBlockCommentOrMarkup) && !trimLine.contains("*/") {
            if self.inMultiLine == .blockComment { self.isComment = true }
            if self.inMultiLine == .blockMarkup  { self.isMarkup  = true }
            return                      // Whole line is in BlockComment or BlockMarkup
        }

        // Starts or ends with <""">, so toggle inMultiLine.tripleQuote
        if trimLine.hasPrefix("\"\"\"") || trimLine.hasSuffix("\"\"\"") {
            if self.inMultiLine == .tripleQuote {
                self.inMultiLine = .none
            } else if self.inMultiLine == .none {
                self.inMultiLine = .tripleQuote
            }
        }

        // No Code in this line
        if !inBlockCommentOrMarkup && trimLine.hasPrefix("//") {
            if trimLine.hasPrefix("///") {
                self.isMarkup = true
            } else {
                self.isComment = true
            }
            return
        }

        //MARK: Now process the line character by character
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
                            //FIXME: Do not change inMultiLine if change occurs after firstSplitter
                            if p >= chars.count || chars[p+1] != "*" {
                                self.inMultiLine = .blockComment
                            } else {
                                self.inMultiLine = .blockMarkup
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
                    } else if char == "{" {
                        self.openCurlyCount += 1
                        if self.firstSplitter == nil { firstSplitter = "{" }
                    } else if char == "}" {
                        self.closeCurlyCount += 1
                        if self.firstSplitter == nil { firstSplitter = "}" }
                    } else if char == ";" {
                        if self.firstSplitter == nil { firstSplitter = ";" }
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
                //FIXME: Do not change inMultiLine if change occurs after firstSplitter
                if char == "/" && prevChar == "*" {         // "*/"
                    self.inMultiLine = .none
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

        let myCodeline: String
        if pComment >= 0 {
            let sliceChars = chars.prefix(pComment - 1)
            myCodeline = String(sliceChars).replacingOccurrences(of: blockCommentStr, with: "")
        } else {
            myCodeline = String(chars).replacingOccurrences(of: blockCommentStr, with: "")
        }
        self.codeLine = myCodeline.trim.replacingOccurrences(of: "\t", with: " ")
    }//end init
}//end struct CodeLineDetail
