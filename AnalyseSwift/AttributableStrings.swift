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
    func formatContentsTextX(_ text: String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
        paragraphStyle?.minimumLineHeight = 24
        paragraphStyle?.alignment = .left
        paragraphStyle?.tabStops = [ NSTextTab(type: .leftTabStopType, location: 48),  NSTextTab(type: .leftTabStopType, location: 96) ]
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: NSFont.systemFont(ofSize: 14),
            NSAttributedString.Key.paragraphStyle: paragraphStyle ?? NSParagraphStyle.default
        ]
        
        let formattedText = NSAttributedString(string: text, attributes: textAttributes)
        return formattedText
    }//end func

    func formatCodeLine(codeLine: String, inTripleQuote: inout Bool, inBlockComment: inout Bool) -> NSAttributedString {
        var textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: NSFont(name: "PT Mono", size: 12)!]
        var formattedText = NSMutableAttributedString(string: "\(codeLine)\n", attributes: textAttributes)
        let codeColor     = NSColor.black
        let commentColor  = NSColor(calibratedRed: 0, green: 0.6, blue: 0.15, alpha: 1)  //Green
        let quoteColor    = NSColor.red

        let marks = markCodeLine(codeLine: codeLine, inTripleQuote: &inTripleQuote, inBlockComment: &inBlockComment)
        formattedText = constructAttributedLine(codeLine: codeLine, marks: marks,
                                codeColor: codeColor, commentColor: commentColor, quoteColor: quoteColor,
                                attributes: textAttributes)
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

    //  NoQuotes, inBlockComment && No"/*", !inBlockComment && No"*/"
    func markCodeLine(codeLine: String, inTripleQuote: inout Bool, inBlockComment: inout Bool) -> [ColorMark] {
        let trimmedLine   = codeLine.trim
        let codeColor     = NSColor.black
        let commentColor  = NSColor(calibratedRed: 0, green: 0.6, blue: 0.15, alpha: 1)  //Green
        let quoteColor    = NSColor.red
        var colorMarks    = [ColorMark(index: 0, color: codeColor)]

        if trimmedLine.hasPrefix("/*") { inBlockComment = true }
        if inBlockComment {
            let trimmedLine2 = String(trimmedLine.dropLast())
            if !trimmedLine2.contains("*/") {
                if trimmedLine.hasSuffix("*/") { inBlockComment = false}
                colorMarks[0] = ColorMark(index: 0, color: commentColor)
                return colorMarks    // "//" or "/*" Full Comment Line
            }
        }

        // ->comment line
        if trimmedLine.hasPrefix("//") {
            return [ColorMark(index: 0, color: commentColor)]
        }

        let idxEndBlock = trimmedLine.range(of: "*/")?.upperBound

        // ->inBlockComment and no end-block before EOL
        if inBlockComment && (idxEndBlock == nil || idxEndBlock == trimmedLine.endIndex) {
            if trimmedLine.hasSuffix("*/") { inBlockComment = false }
            return [ColorMark(index: 0, color: commentColor)]
        }

        // Simple solutions failed, so parse the code char by char
        let chars = Array(codeLine)
        var escaped = false
        var inQuote = false
        var inComment = inBlockComment
        if inComment {
            colorMarks = [ColorMark(index: 0, color: commentColor)]
        } else {
            colorMarks = [ColorMark(index: 0, color: codeColor)]
        }
        for (i, char) in chars.enumerated() {
            if !escaped {
                if char == "\\" {
                    escaped = true                  // got backslash
                }
                if !inComment && char == "\"" {
                    inQuote = !inQuote              // got quote
                    if inQuote {
                        colorMarks.append(ColorMark(index: i+1, color: quoteColor))
                    } else {
                        colorMarks.append(ColorMark(index: i, color: codeColor))
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
            } else {
                escaped = false
            }
        }//next
        return colorMarks        // Mixed Code
    }//end func markCodeLine

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

    func constructAttributedLine(codeLine: String, marks: [ColorMark],
                                 codeColor: NSColor, commentColor: NSColor, quoteColor: NSColor,
                                 attributes: [NSAttributedString.Key: Any]) -> NSMutableAttributedString {
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

    func splitTrailingComment(codeLine: String, codeColor: NSColor, commentColor: NSColor, attributes: [NSAttributedString.Key: Any]) -> NSMutableAttributedString {
        var myAttributes  = attributes
        myAttributes[NSAttributedString.Key.foregroundColor] = codeColor
        var formattedText = NSMutableAttributedString()

        let splitIndex = codeLine.range(of: "//")?.lowerBound
        if let splitIndex = splitIndex {
            let (code, comment) = splitLineAtIndex(codeLine: codeLine, splitIndex: splitIndex)
            formattedText = NSMutableAttributedString(string: "\(code)", attributes: myAttributes)
            myAttributes[NSAttributedString.Key.foregroundColor] = commentColor
            let cmt = NSMutableAttributedString(string: "\(comment)\n", attributes: myAttributes)
            formattedText.append(cmt)
        } else {
            formattedText = NSMutableAttributedString(string: "\(codeLine)", attributes: myAttributes)
        }
        return formattedText        // Code with trailing comment
    }//end func

    // Format a simple code//comment line into a NSMutableAttributedString
    func formatTrailingComment(code: String, comment: String, codeColor: NSColor, commentColor: NSColor, attributes: [NSAttributedString.Key: Any]) -> NSMutableAttributedString {
        var myAttributes  = attributes
        myAttributes[NSAttributedString.Key.foregroundColor] = codeColor
        var formattedText = NSMutableAttributedString()
        formattedText = NSMutableAttributedString(string: "\(code)", attributes: myAttributes)
        myAttributes[NSAttributedString.Key.foregroundColor] = commentColor
        let cmt = NSMutableAttributedString(string: "\(comment)\n", attributes: myAttributes)
        formattedText.append(cmt)
        return formattedText        // NSMutableAttributedString - Code with trailing comment
    }//end func

    // Split a codeLine into code & comment at an integer index
    func splitLineAtIntIndex(codeLine: String, indexInt: Int ) -> (code: String, comment: String) {
        let splitIndex = codeLine.index(codeLine.startIndex, offsetBy: indexInt)
        let code = String(codeLine[..<splitIndex])
        let comment = String(codeLine[splitIndex...])
        return (code, comment)        // Code with trailing comment
    }//end func

    // Split a codeLine into code & comment at a String.Index
    func splitLineAtIndex(codeLine: String, splitIndex: String.Index ) -> (code: String, comment: String) {
        let code = String(codeLine[..<splitIndex])
        let comment = String(codeLine[splitIndex...])
        return (code, comment)        // Code with trailing comment
    }//end func

}//end extension
