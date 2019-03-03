//
//  AttributableStrings.swift
//  AnalyseSwiftCode
//
//  Created by George Bauer on 12/9/18.
//  Copyright © 2018 Ray Wenderlich. All rights reserved.
//

import Cocoa

// funcs to create NSAttributedString.Key, NSAttributedString, (and NSMutableAttributedString)

extension ViewController {

    struct ColorMark {
        let index: Int
        let color: NSColor
    }

    //---- setFontSizeAttribute - Set NSAttributedString to systemFont(ofSize: size)
    func setFontSizeAttribute(size: CGFloat) -> [NSAttributedString.Key: Any] {
        let textAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: NSFont.systemFont(ofSize: size),
        ]
        return textAttributes
    }
    
    // format 1st line to 20pt font; the rest to 14pt, Tab-stop at 240
    func formatWithHeader(_ text: String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
        paragraphStyle?.minimumLineHeight = 24
        paragraphStyle?.alignment = .left
        paragraphStyle?.tabStops = [ NSTextTab(type: .leftTabStopType, location: 240) ]
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: NSFont.systemFont(ofSize: 14),
            NSAttributedString.Key.paragraphStyle: paragraphStyle ?? NSParagraphStyle.default
        ]
        
        let formattedText = NSMutableAttributedString(string: text, attributes: textAttributes)
        var lengthLine1 = text.IndexOf("\n")
        if lengthLine1 < 0 { lengthLine1 = 0 }
        formattedText.addAttribute(NSAttributedString.Key.font,
                                   value: NSFont.systemFont(ofSize: 20),
                                   range: NSRange(location: 0, length: lengthLine1))
        return formattedText
    }//end func
    
    //---- formatSwiftLine - Add line numbers and comment colors - format tabs at right26 & left32, font at 13pt
    // called from showFileContents()
    func formatSwiftLine(lineNumber: Int, text: String, inBlockComment: inout Bool, inTripleQuote: inout Bool, curlyDepth: inout Int) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = 2
        paragraphStyle.alignment = .left
        paragraphStyle.tabStops = [ NSTextTab(type: .rightTabStopType, location: 26),  NSTextTab(type: .leftTabStopType, location: 32) ]
        
        let lineNumAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: NSFont(name: "Menlo", size: 10)!,
            NSAttributedString.Key.foregroundColor: NSColor.gray,
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ]
        let n4 = "\(lineNumber)".PadLeft(4)
        let formattedLineNum = NSAttributedString(string: "\(n4) ", attributes: lineNumAttributes)
        let output = NSMutableAttributedString(attributedString: formattedLineNum)
        if lineNumber == 25 {
            // Debug Trap
        }
        output.append(formatCodeLine(codeLine: text, inTripleQuote: &inTripleQuote, inBlockComment: &inBlockComment))
        return output
    }//end func formatSwiftLine
    
    // format tabs at 48 & 96, font at 14pt
//    func formatContentsTextX(_ text: String) -> NSAttributedString {
//        let paragraphStyle = NSMutableParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
//        paragraphStyle?.minimumLineHeight = 24
//        paragraphStyle?.alignment = .left
//        paragraphStyle?.tabStops = [ NSTextTab(type: .leftTabStopType, location: 48),  NSTextTab(type: .leftTabStopType, location: 96) ]
//
//        let textAttributes: [NSAttributedString.Key: Any] = [
//            NSAttributedString.Key.font: NSFont.systemFont(ofSize: 14),
//            NSAttributedString.Key.paragraphStyle: paragraphStyle ?? NSParagraphStyle.default
//        ]
//
//        let formattedText = NSAttributedString(string: text, attributes: textAttributes)
//        return formattedText
//    }//end func

    func formatCodeLine(codeLine: String, inTripleQuote: inout Bool, inBlockComment: inout Bool) -> NSAttributedString {
        let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: NSFont(name: "PT Mono", size: 12)!]
        var formattedText = NSMutableAttributedString(string: "\(codeLine)\n", attributes: textAttributes)

        let marks = markCodeLine(codeLine: codeLine, inTripleQuote: &inTripleQuote, inBlockComment: &inBlockComment)
        formattedText = constructAttributedLine(codeLine: codeLine, marks: marks, attributes: textAttributes)
        //textAttributes[NSAttributedString.Key.foregroundColor] = codeColor
        //formattedText = NSMutableAttributedString(string: "\(codeLine)\n", attributes: textAttributes)
        return formattedText        // All Code
    }//end func formatCodeLine

    // Simple Lines:
    //      inBlockComment and No "*/" except suffix    -> green, if "*/" inBlockComment=false
    //      hasPrefix("/*") &&  does notcontain("*/")   -> green, inBlockComment=True
    //      hasPrefix("//")                             -> green
    // No Quotes (or 2 quotes separated bt 0 or 1)
    //      if has "//" strip off trailing comment      -> ??//green

    // inBlockComment, inTripleQuote --- inQuote, inComment, inColoredWord, inInterpolation, inCode
    //  NoQuotes, inBlockComment && No"/*", !inBlockComment && No"*/"
    func markCodeLine(codeLine: String, inTripleQuote: inout Bool, inBlockComment: inout Bool) -> [ColorMark] {
        let trimmedLine   = codeLine.trim
        var colorMarks    = [ColorMark(index: 0, color: codeColor)]         // 1st char is code (default)

        // -------- Simple solutions: when entire line is Comment or Quote
        if trimmedLine.hasPrefix("/*") { inBlockComment = true }
        if inBlockComment {
            let trimmedLine2 = String(trimmedLine.dropLast())
            if !trimmedLine2.contains("*/") {
                if trimmedLine.hasSuffix("*/") { inBlockComment = false}
                colorMarks[0] = ColorMark(index: 0, color: commentColor)    // entire line is inBlockComment
                return colorMarks    // "//" or "/*" Full Comment Line
            }
        } else if trimmedLine == "\"\"\"" {
                inTripleQuote = !inTripleQuote
                colorMarks[0] = ColorMark(index: 0, color: quoteColor)      // entire line is inTripleQuote
                return colorMarks                                           // Full TripleQuote Line
        } else if inTripleQuote && !trimmedLine.contains("\"\"\"") {
            colorMarks[0] = ColorMark(index: 0, color: quoteColor)          // entire line is inTripleQuote
            return colorMarks                                               // Full TripleQuote Line
        }

        // ->comment line
        if trimmedLine.hasPrefix("//") {
            return [ColorMark(index: 0, color: commentColor)]               // entire line is Comment
        }

        let idxEndBlock = trimmedLine.range(of: "*/")?.upperBound

        // ->inBlockComment and no end-block before EOL
        if inBlockComment && (idxEndBlock == nil || idxEndBlock == trimmedLine.endIndex) {
            if trimmedLine.hasSuffix("*/") { inBlockComment = false }
            return [ColorMark(index: 0, color: commentColor)]               // entire line is inBlockComment
        }

        //-----------------------------
        // -------- Simple solutions failed, so parse the code char by char!
        let chars = Array(codeLine)
        var escaped = false
        var inQuote = inTripleQuote
        var inComment = inBlockComment
        if inComment {
            colorMarks = [ColorMark(index: 0, color: commentColor)]         // 1st char is inBlockComment
        } else if inQuote {
            colorMarks = [ColorMark(index: 0, color: quoteColor)]           // 1st char is inTripleQuote
        } else {
            colorMarks = [ColorMark(index: 0, color: codeColor)]            // 1st char is code
        }

        var isLookingForWord = true
        var inColoredWord = false
        var pEndWord = -1
        var terminatingChar = Character(" ")
        for (i, char) in chars.enumerated() {
            if i == pEndWord {
                isLookingForWord = true
                if inColoredWord {
                    colorMarks.append(ColorMark(index: i, color: codeColor))
                    inColoredWord = false
                    pEndWord = -1
                } else {
                    print("⛔️ '\(char)' at \(i) pos of \(codeLine)' Not inColoredWord")
                }
            }
            if !escaped {
                if char == "\\" {
                    escaped = true                  // got backslash
                }
                if !inComment && char == "\"" {
                    inQuote = !inQuote              // got quote
                    if inQuote {
                        colorMarks.append(ColorMark(index: i, color: quoteColor))
                        if i>=2 && chars[i-1] == "\"" && chars[i-2] == "\"" {
                            colorMarks.append(ColorMark(index: i, color: quoteColor))
                            inTripleQuote = true
                        }
                    } else {
                        colorMarks.append(ColorMark(index: i+1, color: codeColor))
                    }
                }
                if !inQuote {
                    if i < chars.count-1 {
                        if char == "/" && chars[i+1] == "/" {       // got "//"
                            colorMarks.append(ColorMark(index: i, color: commentColor))
                            break
                        }
                        if char == "/" && chars[i+1] == "*" {       // got "/*"
                            if i == 0 { colorMarks = [] }
                            colorMarks.append(ColorMark(index: i, color: commentColor))
                            inBlockComment = true
                            inComment = true
                        }
                        if char == "*" && chars[i+1] == "/" {       // got "*/"
                            colorMarks.append(ColorMark(index: i+2, color: codeColor))
                            inBlockComment = false
                            inComment = false
                        }
                    }
                }
                if !inQuote && !inComment {

                    if isLookingForWord {
                        if char != " " && char != "(" && char != ")" && char != "[" && char != "]" && char != "." {
                            isLookingForWord = false

                            (pEndWord, terminatingChar) = findEndOfWord(chars: chars, pFirst: i)
                            if "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ#@".contains(char) {
                                isLookingForWord = false
                                var charsInWord = [Character]()
                                for p in i..<pEndWord {
                                    charsInWord.append(chars[p])
                                }
                                let word = String(charsInWord)
                                if i > 0 && chars[i-1] == "." {
                                    colorMarks.append(ColorMark(index: i, color: namesColor))
                                    inColoredWord = true
                                } else if isKeyword(word: word) {
                                    colorMarks.append(ColorMark(index: i, color: keywordColor))
                                    inColoredWord = true
                                } else if word.count > 5 && (word.prefix(2) == "NS" || word.prefix(2) == "UI")  {
                                    colorMarks.append(ColorMark(index: i, color: namesColor))
                                    inColoredWord = true
                                }//endif isKeyword
                            }//endif char is lower or #@AT
                        }//endif not space, paren, or dot
                    }//endif isLookingForWord
                }//endif not in quote or comment
            } else {
                escaped = false
            }
        }//next
        return colorMarks        // Mixed Code
    }//end func markCodeLine

    //
    func findEndOfWord(chars: [Character], pFirst: Int) -> (Int, Character)  {
        for p in pFirst..<chars.count {
            var char = chars[p]
            if char == " " {
                char = findTerminatingChar(chars: chars, pFirst: p)
            }
            if char == " " || char == "(" || char == ")" || char == "[" || char == "]" || char == "." || char == "=" {
                return (p, char)
            }
        }
        return (chars.count, Character(" "))
    }

    func findTerminatingChar(chars: [Character], pFirst: Int) -> Character {
        for p in pFirst..<chars.count {
            let char = chars[p]
            if char != " " {
                if char == "(" || char == ")" || char == "[" || char == "]" || char == "." || char == "=" {
                    return (char)
                }
            }
        }
        return Character(" ")
    }

    func constructLine(codeLine: String, marks: [ColorMark]) -> String {
        var newLine = ""
        for i in 0..<marks.count {
            let start = marks[i].index
            var end = codeLine.count
            if i < marks.count-1 { end = marks[i+1].index }
            let subStr = getSubStr(line: codeLine, start: start, end: end)
            var color = "<green>"
            if marks[i].color == NSColor.red { color = "<red>" }
            if marks[i].color == NSColor.black { color = "<black>" }
            newLine += color + subStr
        }
        return newLine
    }

    func constructAttributedLine(codeLine: String, marks: [ColorMark], attributes: [NSAttributedString.Key: Any]) -> NSMutableAttributedString {
        var lineAttributes = attributes
        let newLine = NSMutableAttributedString()
        for i in 0..<marks.count {
            let start = marks[i].index
            var end = codeLine.count
            if i < marks.count-1 { end = marks[i+1].index }
            let subStr = getSubStr(line: codeLine, start: start, end: end)
            lineAttributes[NSAttributedString.Key.foregroundColor] = marks[i].color
            let formattedText = NSMutableAttributedString(string: "\(subStr)", attributes: lineAttributes)
            newLine.append(formattedText)
        }
        newLine.append(NSMutableAttributedString(string: "\n", attributes: attributes))
        return newLine
    }

    func getSubStr(line: String, start: Int, end: Int) -> String {
        let index1 = line.index(line.startIndex, offsetBy: start)
        let index2 = line.index(line.startIndex, offsetBy: end)
        let range = index1..<index2
        let subStr = String(line[range])
        return subStr
    }

    // Format a simple code//comment line into a NSMutableAttributedString
//    func formatTrailingComment(code: String, comment: String, codeColor: NSColor, commentColor: NSColor, attributes: [NSAttributedString.Key: Any]) -> NSMutableAttributedString {
//        var myAttributes  = attributes
//        myAttributes[NSAttributedString.Key.foregroundColor] = codeColor
//        var formattedText = NSMutableAttributedString()
//        formattedText = NSMutableAttributedString(string: "\(code)", attributes: myAttributes)
//        myAttributes[NSAttributedString.Key.foregroundColor] = commentColor
//        let cmt = NSMutableAttributedString(string: "\(comment)\n", attributes: myAttributes)
//        formattedText.append(cmt)
//        return formattedText        // NSMutableAttributedString - Code with trailing comment
//    }//end func

    // Split a codeLine into code & comment at an integer index
//    func splitLineAtIntIndex(codeLine: String, indexInt: Int ) -> (code: String, comment: String) {
//        let splitIndex = codeLine.index(codeLine.startIndex, offsetBy: indexInt)
//        let code = String(codeLine[..<splitIndex])
//        let comment = String(codeLine[splitIndex...])
//        return (code, comment)        // Code with trailing comment
//    }//end func

    // Split a codeLine into code & comment at a String.Index
//    func splitLineAtIndex(codeLine: String, splitIndex: String.Index ) -> (code: String, comment: String) {
//        let code = String(codeLine[..<splitIndex])
//        let comment = String(codeLine[splitIndex...])
//        return (code, comment)        // Code with trailing comment
//    }//end func

}//end extension
