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
        let trimmedLine   = codeLine.trim
        let codeColor     = NSColor.black
        let commentColor  = NSColor(calibratedRed: 0, green: 0.6, blue: 0.15, alpha: 1)  //Green
        var isComment     = false

        if trimmedLine.hasPrefix("/*") && !trimmedLine.contains("*/") { inBlockComment = true }
        if inBlockComment && (!trimmedLine.contains("*/") || trimmedLine.hasSuffix("*/")) { isComment = true }

        if trimmedLine.hasPrefix("//") || isComment {
            if trimmedLine.hasSuffix("*/") { inBlockComment = false}
            textAttributes[NSAttributedString.Key.foregroundColor] = commentColor
            formattedText = NSMutableAttributedString(string: "\(codeLine)\n", attributes: textAttributes)
            return formattedText    // "//" or "/*" Full Comment Line
        }

        if trimmedLine.hasPrefix("/*") && !trimmedLine.contains("*/") { inBlockComment = true }
        // if no comment chars in line
        if !trimmedLine.contains("//") && !trimmedLine.contains("/*") && !trimmedLine.contains("*/") {
            if inBlockComment {
                textAttributes[NSAttributedString.Key.foregroundColor] = commentColor
            } else {
                textAttributes[NSAttributedString.Key.foregroundColor] = codeColor
            }
            formattedText = NSMutableAttributedString(string: "\(codeLine)\n", attributes: textAttributes)
            return formattedText    // AllCode or AllComment
        }

        if trimmedLine.hasSuffix("*/") {
            inBlockComment = false
            textAttributes[NSAttributedString.Key.foregroundColor] = commentColor
            formattedText = NSMutableAttributedString(string: "\(codeLine)\n", attributes: textAttributes)
            return formattedText    // AllCode or AllComment
        }

        if codeLine.contains("//") && !codeLine.contains("\"") {
            formattedText = splitTrailingComment(codeLine: codeLine, codeColor: codeColor, commentColor: commentColor, attributes: textAttributes)
            return formattedText    // Trailing Comment
        }

        // Simple solutions failed, so parse the code char by char
        let chars = Array(codeLine)
        var escaped = false
        var inQuote = false
        for (i, char) in chars.enumerated() {
            if !escaped {
                if char == "\\" {
                    escaped = true
                }
                if char == "\"" {
                    inQuote = !inQuote
                }
                if !inQuote {
                    if char == "/" && chars[i-1] == "/" {
                        let (code, comment) = splitLineAtIntIndex(codeLine: codeLine, indexInt: i-1 )
                        formattedText = formatTrailingComment(code: code, comment: comment, codeColor: codeColor, commentColor: commentColor, attributes: textAttributes)
                        return formattedText    // Trailing Comment
                    }
                }
            } else {
                escaped = false
            }
        }//next

        textAttributes[NSAttributedString.Key.foregroundColor] = codeColor
        formattedText = NSMutableAttributedString(string: "\(codeLine)\n", attributes: textAttributes)
        return formattedText        // All Code
    }//end func formatCodeLine

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
