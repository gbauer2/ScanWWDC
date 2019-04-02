//
//  StringExtension.swift
//  TestSharedCode
//
//  Created by George Bauer on 10/11/17.
//  Copyright © 2017-2019 GeorgeBauer. All rights reserved.
//  Ver 1.7.0   3/31/2019 Change extension to StringProtocol. Added firstIntIndexOf, lastIntIndexOf, allIntIndexesOf
//  Ver 1.6.1   3/09/2019 Subscripting for Int now only returns Character (avoids "Abiguous" error when compiler can't tell if String or Character)
//      1.6.0   6/13/2018 Add Subscripting for CountablePartialRangeFrom<Int>, PartialRangeThrough<Int>, PartialRangeUpTo<Int>.  Also Documentation
//      1.5.2   5/30/2018 Fix Error in .mid where .mid(begin: i, length: 0) would return same as .mid(begin: i)
//      1.5.1   5/23/2018 Add trimStart, trimEnd
//      1.5.0   5/20/2018 change .indexOf(SearchforStr) to .IndexOf(_) move PadLeft, PadRight from VBCompatability
//      1.4.1   5/16/2018 Protect .mid(str,p,length) from negative length
//      1.4.0   5/06/2018 Add Integer Subscripts again
//      1.3.1   5/06/2018 Remove "Trim", leaving only "trim"
//      1.3.0   5/03/2018 Change func trim() to var trim
//      1.2.1   4/03/2018 Clean up .left, .right
//      1.2.0   4/03/2018 remove subscript routines (not needed in Swift4)
//      1.1.2   3/01/2018 fix .right for negative length
// String extensions 100% tested

import Foundation

// String extensions: 
// subscript(i), subscript(range), left(i), right(i), mid(i,len), rightJust(len),
// indexOf(str), indexOfRev(str), trim, contains(str), containsIgnoringCase(str), pluralize(n)
extension StringProtocol {

    //------ subscript: allows string to be sliced by ints: e.g. str[2] ------
    /// Int wrapper for str[index(startIndex, offsetBy: i)] -> Character
    subscript (_ i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }

//    /// Int wrapper for str[index(startIndex, offsetBy: i)] -> String
//    subscript (_ i: Int) -> String {
//        return String(self[i])
//    }

    /// Int wrapper for str[HalfOpenRange] -> String
    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end   = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }

    /// Int wrapper for str[ClosedRange] -> String
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end   = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }

    /// Int wrapper for str[CountablePartialRangeFrom<Int>] -> String
    subscript (bounds: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        return String(self[start...])
    }

    /// Int wrapper for str[PartialRangeThrough<Int>] -> String
    subscript (bounds: PartialRangeThrough<Int>) -> String {
        let end   = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[...end])
    }

    /// Int wrapper for str[PartialRangeUpTo<Int>] -> String
    subscript (bounds: PartialRangeUpTo<Int>) -> String {
        let end   = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[..<end])
    }

    //---- left - get 1st n chars ----
    /// Same as .prefix(), but protected from negative numbers
    func left(_ length: Int) -> String {
        return String(self.prefix( Swift.max(length, 0)))
    }
    //---- right - get last n chars ----
    /// Same as .suffix(), but protected from negative numbers
    func right(_ length: Int) -> String {
        return String(self.suffix(Swift.max(length, 0)))
    }

    //---- mid - extract a string starting at 'begin', of length (zero-based Int) ----
    /// Extract a string starting at 'begin', of length (zero-based Ints)
    /// - Parameters:
    ///   - begin: Int Starting point for extracted String
    ///   - length: Int Length of extracted String
    /// - Returns: Extracted String
    func mid(begin: Int, length: Int = 99999) -> String {
        if length == 0 { return "" }
        let lenOrig = self.count                        // length of subject str
        if begin > lenOrig || begin < 0 || length < 0 { return "" }

        var lenNew = Swift.max(length, 0)                     // length of extracted string
        if lenNew == 0 ||  begin + lenNew > lenOrig {
            lenNew = lenOrig - begin
        }

        let startIndexNew = index(startIndex, offsetBy: begin)
        let endIndex = index(startIndex, offsetBy: begin + lenNew)
        return String(self[startIndexNew..<endIndex])
    }

    //---- rightJust - format right justify a String in a field ------
    /// Returns a String of specified length representing an Integer right-justified
    /// - Parameter fieldLen: length of returned String
    /// - Returns: new String padded with spaces
    func rightJust(_ fieldLen: Int) -> String {
        guard self.count < fieldLen else { return self as? String ?? "" }
        let maxStr = String(repeating: " ", count: fieldLen)
        return (maxStr + self).right(fieldLen)
    }

    //---- PadRight - add spaces to right ---- ToDo: Add parameter to allow non-space padding ???
    /// Add spaces to end of String to fill a field
    /// - Parameter n: Size of field (length of resulting String)
    /// - Returns: New String of length n
    func PadRight(_ n: Int) -> String {
        let len = self.count
        if n <= len { return String(self.prefix(n)) }
        let fill = String(repeating: " ", count: n - len)
        return self + fill
    }

    //---- PadLeft - add spaces to left ---- ToDo: Add parameter to allow non-space padding ???
    /// Add spaces to left side of String to fill a field
    /// - Parameter n: Size of field (length of resulting String)
    /// - Returns: New String of length n
    func PadLeft(_ n: Int) -> String {
        let len = self.count
        if n <= len { return String(self.prefix(n)) }
        let fill = String(repeating: " ", count: n - len)
        return fill + self
    }

    //---- IndexOf - find Int index of searchforStr ---- Needs work for performance ???
    /// IndexOf (with capital I) find Int index of 1st String found.
    /// - Parameter searchforStr: String to be searched for
    /// - Returns: Int index (if found) or -1 (if not found)
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
        return -1                   // Indicates "Not found"
    }//end func


    //---- IndexOf - find Int index of searchforStr starting at startPoint ---- Needs work for performance ???
    /// Find 1st Int index of searchforStr starting at startPoint.
    /// - Parameter searchforStr: String to be searched for
    /// - Parameter startPoint: Int: index to start searching
    /// - Returns: Int index (if found) or -1 (if not found)
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

    //---- firstIntIndexOf - find Int index of searchforStr starting at startPoint
    /// Find 1st Int index of searchforStr in self, starting at startingAt.
    /// - Parameter searchforStr: String to be searched for
    /// - Parameter startingAt:   Int index to start searching
    /// - Returns: Int index (if found) or -1 (if not found)
    func firstIntIndexOf(_ searchforStr: String, startingAt: Int = 0) -> Int {
//        guard let index = range(of: searchforStr)?.lowerBound else { return -1 }
//        return distance(from: startIndex, to: index)
        if startingAt > 0 && startingAt >= self.count { return -1 }     // beyond end
        let startInt = Swift.max(startingAt, 0)                         // min startingAt = 0
        let myStartIndex = self.index(self.startIndex, offsetBy: startInt)
        let searchRange = myStartIndex..<self.endIndex
        guard let matchRange = range(of: searchforStr, options: .literal, range: searchRange)
            else { return -1 }
        return distance(from: startIndex, to: matchRange.lowerBound)
    }

    //---- lastIntIndexOf - find last Int index of str in self
    /// Find last Int index of searchforStr.
    /// - Parameter searchforStr: String to be searched for
    /// - Returns: Int index (if found) or -1 (if not found)
    func lastIntIndexOf(_ searchforStr: String) -> Int {
        guard var foundIndex = range(of: searchforStr)?.lowerBound else { return -1 }
        while true {
            let searchIndex  = self.index(foundIndex, offsetBy: 1)
            if searchIndex >= endIndex { break }
            let searchRange = searchIndex..<self.endIndex
            guard let index = range(of: searchforStr, options: .literal, range: searchRange)?.lowerBound else { break }
            foundIndex = index
        }// loop
        return distance(from: startIndex, to: foundIndex)
    }//end func

    //---- allIntIndexesOf - find last Int index of searchforStr
    /// Find last Int index of searchforStr.
    /// - Parameter searchforStr: String to be searched for
    /// - Returns: Int index (if found) or -1 (if not found)
    func allIntIndexesOf(_ searchforStr: String) -> [Int] {
        guard var foundIndex = range(of: searchforStr)?.lowerBound else { return [] }
        var indexes = [Int]()
        while true {
            indexes.append(distance(from: startIndex, to: foundIndex))
            let searchIndex  = self.index(foundIndex, offsetBy: 1)
            if searchIndex >= endIndex { break }
            let searchRange = searchIndex..<self.endIndex
            guard let index = range(of: searchforStr, options: .literal, range: searchRange)?.lowerBound else { break }
            foundIndex = index
        }// loop
        return indexes
    }//end func

    //---- IndexOfRev - find last Int index of searchforStr ---- Needs work for performance ???
    /// Find last Int index of searchforStr.
    /// - Parameter searchforStr: String to be searched for
    /// - Returns: Int index (if found) or -1 (if not found)
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
    /// Same as ".trimmingCharacters(in: .whitespacesAndNewlines)"
    var trim: String { return self.trimmingCharacters(in: .whitespacesAndNewlines) }

    //---- trimStart & trimEnd - Remove ONLY whitespace from Left or Right
    /// Remove whitespace ONLY from left side (uses RegEx)
    var trimStart: String {
        return self.replacingOccurrences(of: "^\\s+", with: "", options: .regularExpression)
    }
    /// Remove whitespace ONLY from right side (uses RegEx)
    var trimEnd: String {
        return self.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
    }

    //---- pluralize - Pluralize a word (English) ------
    /// Pluralize an English word if count > 0
    /// - Parameter count: Triggers pluralization if > 0
    /// - Returns: Pluralized word
    func pluralize(_ count: Int) -> String {
        var s: String
        if count == 1 || self.count < 2 {
            s = self as! String
        } else {
            let last2Chars =  self.right(2)
            let lastChar = last2Chars.right(1)
            let secondToLastChar = last2Chars.left(1)
            var prefix = "", suffix = ""

            if lastChar.lowercased() == "y" && vowels.filter({x in x == secondToLastChar}).isEmpty {
                prefix = self.left(self.count - 1)
                suffix = "ies"
            } else if (lastChar.lowercased() == "s" || (lastChar.lowercased() == "o")
                && consonants.filter({x in x == secondToLastChar}).count > 0) {
                prefix = self as! String
                suffix = "es"
            } else {
                prefix = self as! String
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


