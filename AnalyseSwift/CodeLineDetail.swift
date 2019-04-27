//
//  CodeLineDetails.swift
//  AnalyseSwiftCode
//
//  Created by George Bauer on 4/27/19.
//  Copyright © 2019 George Bauer. All rights reserved.
//

import Foundation

public struct CodeLineDetail {
    var codeLine = ""
    var hasTrailingComment = false
    var hasEmbeddedComment = false
    var hasInterpoation    = false
    var isComment          = false
    var isMarkup           = false
    var parenMismatch      = 0
    var bracketMismatch    = 0
}

// Strip comment & neuter quotes from line, returning trimmed code portion, hasTrailingComment, hasEmbeddedComment
/// Strip comments & neutralize quotes from trimmed sourcecode line
///
/// - Parameters:
///   - fullLine: Swift source code line
///   - lineNum: Swift source line number
///   - inTripleQuote: inout. Are we inside a multi-line string literal
///   - inBlockComment: inout. Are we inside a block comment (/*.../*)
///   - inBlockMarkup: inout. Are we inside a block markup  (/**.../*)
/// - Returns: CodeLineDetail
func stripCommentAndQuote(fullLine: String, lineNum: Int,
                          inTripleQuote:  inout Bool
    , inBlockComment: inout Bool
    , inBlockMarkup:  inout Bool) -> CodeLineDetail {   //149-291 = 142-lines
    //TODO: Raw-string delimiters with more than 1 asterisk **"..."**
    //TODO: Raw-triple-quote    *"""
    //TODO: Interpolation       \(var)
    //TODO: Mark-up detection   ///     /**.../*
    //TODO: Add return isMarkup (struct?)
    let trimLine = fullLine.trim
    var codeLineDetail = CodeLineDetail()
    var inBlockCommentOrMarkup = inBlockComment || inBlockMarkup

    // inBlockCommentOrMarkup with no end in sight
    if (inBlockCommentOrMarkup) && !trimLine.contains("*/") {
        if inBlockComment { codeLineDetail.isComment = true }
        if inBlockMarkup  { codeLineDetail.isMarkup  = true }
        return codeLineDetail                         // Whole line is in BlockComment or BlockMarkup
    }

    // All code & nothing to see here
    if !trimLine.contains("//") && !trimLine.contains("\"") && !trimLine.contains("/*")  && !trimLine.contains("*/")
        && !trimLine.contains("(") && !trimLine.contains("[") {
        codeLineDetail.codeLine = trimLine
        return codeLineDetail                        // No comment or quote
    }
    if trimLine.hasPrefix("\"\"\"") || trimLine.hasSuffix("\"\"\"") {
        inTripleQuote = !inTripleQuote
    }
    if !inBlockCommentOrMarkup && trimLine.hasPrefix("//") {
        if trimLine.hasPrefix("///") {
            codeLineDetail.isMarkup = true
        } else {
            codeLineDetail.isComment = true
        }
        return codeLineDetail
    }

    if trimLine.hasPrefix("\"\"\"") || trimLine.hasSuffix("\"\"\"") {
        inTripleQuote = !inTripleQuote
    }
    let blockCommentStr  = "⌇"
    let blockCommentChar = Character(blockCommentStr)
    // Block comment ignores all but "\" and "*/"
    // Raw String ignores all but \# and "#
    //#”You can use “ and “\” in a raw string. Interpolating as \#(var).”#
    //  #"  "#    //    /*  */    \    \#
    var pComment    = -1
    var preserveQuote = false
//    var inQuote     = false     // in String literal OR Raw String
//    var inRawQuote  = false     // in Raw String
    var isEscaped   = false
    var prevChar    = Character(" ")
    var chars = Array(trimLine)
    var quoteStatus: QuoteStatus = .notInQuotes
    let quoteChar: Character = "\""
    for (p,char) in chars.enumerated() {

        //if char == "(" { isEscaped = false }
        if !isEscaped && !inBlockCommentOrMarkup {      //--- Not Escaped & Not inBlockComment & Not inBlockMarkup

            // Quote (")
            if char == quoteChar {
                if quoteStatus == .inRegular {                                    // --inQuote
                    quoteStatus = .notInQuotes
                } else if quoteStatus == .notInQuotes {                           // --not inQuotes
                    preserveQuote = true
                    if prevChar == "#" {        // #" as in #"xxx"#
                        quoteStatus = .inRawString  //????? Count "#"s here
                    } else {
                        quoteStatus = .inRegular
                    }
                }

                // Hashtag "#" Need changing for ###"..."###
            } else if char == "#" {
                if prevChar == quoteChar {           // "# as in #"xxx"#
                    if quoteStatus == .inRawString {                             // --inRawQuote
                        // Check "#"s count here
                        chars[p-1] = prevChar
                        quoteStatus = .notInQuotes      //end of RawString
                    }
                }

                // Asterisk "*"
            } else if char == "*" {
                if quoteStatus == .notInQuotes && prevChar == "/" {   // "/*"   // --not inQuotes
                    chars[p-1] = blockCommentChar
                    codeLineDetail.hasEmbeddedComment = true
                    if p >= chars.count || chars[p+1] != "*" {
                        inBlockComment = true
                    } else {
                        inBlockMarkup = true
                    }
                    inBlockCommentOrMarkup = true
                }

                // BackSlash "\"
            } else if char == "\\" {                                            // --inQuote
                if quoteStatus == .inRegular {
                    isEscaped = true
                }

                // Slash "/"
            } else if char == "/" {
                if quoteStatus == .notInQuotes && prevChar == "/" {             // --not inQuote
                    pComment = p
                    codeLineDetail.hasTrailingComment = true
                    break
                }
            }
        } else {
            isEscaped = false
        }//endif Not escaped and Not blockComment

        // Mark Comment Char & Check for End of Block
        if inBlockCommentOrMarkup {
            if char == "/" && prevChar == "*" {         // "*/"
                inBlockComment = false
                inBlockMarkup = false
                inBlockCommentOrMarkup = false
            }
            chars[p] = blockCommentChar
        }

        // Make quoted Char benign (needs to change for interpolation)
        if quoteStatus != .notInQuotes {
            if preserveQuote {          // Preserve the opening quotation mark
                preserveQuote = false
            } else {
                chars[p] = "~"
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
    codeLineDetail.codeLine = codeLine.trim
    return codeLineDetail
}//end func stripCommentAndQuote

enum QuoteStatus {
    case inRegular, inRawString, notInQuotes
}
