//
//  StringExtension.swift
//  Almanac
//
//  Created by George Bauer on 10/11/17.
//  Copyright © 2017 GeorgeBauer. All rights reserved.
//  Ver 1.5.1   5/23/2018 Add trimStart, trimEnd
//  Ver 1.5.0   5/20/2018 change .indexOf(SearchforStr to .IndexOf(_ move PadLeft, PadRight from VBCompatability
//      1.4.1   5/16/2018 Protect .mid(str,p,length) from negative length
//      1.4.0   5/06/2018 Add Subscripts again
//      1.3.1   5/06/2018 "Trim", leaving only "trim"
//      1.3.0   5/03/2018 Change func trim() to var trim
//      1.2.1   4/03/2018 Clean up .left, .right
//      1.2.0   4/03/2018 remove subscript routines (not needed in Swift4)
//      1.1.2   3/01/2018 fix .right for negative length
// String extensions 100% tested

import Foundation

// String extensions: 
// subscript(i), subscript(range), left(i), right(i), mid(i,len), rightJust(len),
// indexOf(str), indexOfRev(str), trim, contains(str), containsIgnoringCase(str), pluralize(n)
extension String {

    //------ subscript: allows string to be sliced be ints: e.g. str[2] ------
    subscript (_ i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    subscript (_ i: Int) -> String {
        return String(self[i] as Character)
    }
    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end   = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end   = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }

    //---- left - get 1st n chars  (same as .prefix, but handles negative numbers) ------
    func left(_ length: Int) -> String {
        return String(self.prefix( max(length, 0)))
    }
    //---- right - get last n chars (same as .suffix, but handles negative numbers) ------
    func right(_ length: Int) -> String {
        return String(self.suffix(max(length, 0)))
    }

    //---- mid - extract a string starting at 'begin', of length (zero-based) ------
    func mid(begin: Int, length: Int = 0) -> String {
        let lenOrig = self.count                // length of subject str
        if begin > lenOrig || begin < 0 || length < 0 { return "" }


        var lenNew = length                     // length of extracted string
        if length == 0 ||  begin + length > lenOrig {
            lenNew = lenOrig - begin
        }

        let startIndexNew = index(startIndex, offsetBy: begin)
        let endIndex = index(startIndex, offsetBy: begin + lenNew)
        return String(self[Range(startIndexNew ..< endIndex)])
    }

    //---- rightJust - format right justify an int in self ------
    func rightJust(_ fieldLen: Int) -> String {
        guard self.count < fieldLen else { return self }
        let maxStr = String(repeating: " ", count: fieldLen)
        return (maxStr + self).right(fieldLen)
    }

    //---- PadRight - add spaces to right
    func PadRight(_ n: Int) -> String {
        let len = self.count
        if n <= len { return String(self.prefix(n)) }
        let fill = String(repeating: " ", count: n - len)
        return self + fill
    }

    //---- PadLeft - add spaces to left
    func PadLeft(_ n: Int) -> String {
        let len = self.count
        if n <= len { return String(self.prefix(n)) }
        let fill = String(repeating: " ", count: n - len)
        return fill + self
    }

    //---- IndexOf - find position of str in self ------
    func IndexOf( _ searchforStr: String) -> Int {
        if self.contains(searchforStr) {
            let lenOrig = self.count
            let lenSearchFor = searchforStr.count
            var p = 0
            while p + lenSearchFor <= lenOrig {
                if self.mid(begin: p, length: lenSearchFor) == searchforStr {
                    return p
                }
                p += 1
            }                       // Should never get here
        }//endif                    // Should never get here
        return -1
    }//end func


    //---- IndexOf - find position of str in self starting a startPoint ------
    func IndexOf(searchforStr: String, startPoint: Int = 0) -> Int {
        if !self.contains(searchforStr) { return -1 }
        let lenOrig = self.count
        let lenSearchFor = searchforStr.count
        var p = startPoint
        while p + lenSearchFor <= lenOrig {
            if self.mid(begin: p, length: lenSearchFor) == searchforStr {
                return p
            }
            p += 1
        }
        return -1
    }

    //---- IndexOfRev - find position of str in self, seaching backwards from end ------
    func IndexOfRev(_ searchforStr: String) -> Int {
        if self.contains(searchforStr) {
            let lenOrig = self.count
            let lenSearchFor = searchforStr.count
            var p = lenOrig - lenSearchFor
            while p >= 0 {
                if self.mid(begin: p, length: lenSearchFor) == searchforStr {
                    return p
                }
                p -= 1
            }                   // Should never get here
        }                       // Should never get here
        return -1
    }

    //---- trim - remove whitespace (and newlines)) at both ends ------
    var trim: String { return self.trimmingCharacters(in: .whitespacesAndNewlines) }

    //---- trimStart & trimEnd - Remove ONLY whitespace from Left or Right
    var trimStart: String {
        return self.replacingOccurrences(of: "^\\s+", with: "", options: .regularExpression)
    }
    var trimEnd: String {
        let trimmed = self.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
        return trimmed
    }

    //---- pluralize - Pluralize a word (English) ------
    func pluralize(_ count: Int) -> String {
        var s: String
        if count == 1 || self.count < 2 {
            s = self
        } else {
            let last2Chars =  self.right(2)
            let lastChar = last2Chars.right(1)
            let secondToLastChar = last2Chars.left(1)
            var prefix = "", suffix = ""

            if lastChar.lowercased() == "y" && vowels.filter({x in x == secondToLastChar}).count == 0 {
                prefix = self.left(self.count - 1)
                suffix = "ies"
            } else if (lastChar.lowercased() == "s" || (lastChar.lowercased() == "o")
                && consonants.filter({x in x == secondToLastChar}).count > 0) {
                prefix = self
                suffix = "es"
            } else {
                prefix = self
                suffix = "s"
            }
            s = prefix + (lastChar != lastChar.uppercased() ? suffix : suffix.uppercased())
        }
        return s
    }
    private var vowels: [String] {
        get {
            return ["a", "e", "i", "o", "u"]
        }
    }
    private var consonants: [String] {
        get {
            return ["b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "q", "r", "s", "t", "v", "w", "x", "z"]
        }
    }
}//end extension String


