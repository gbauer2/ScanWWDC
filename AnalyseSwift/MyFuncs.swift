//
//  MyFuncs.swift
//  Almanac
//
//  Created by George Bauer on 9/29/17.
//  Copyright © 2017 GeorgeBauer. All rights reserved.

//  Ver 1.5.3   5/14/2018   Fix replaceInString
//      1.5.2   5/13/2018   Add replaceCharInString, replaceInString
//      1.5.1   5/02/2018   Add Date stuff isSameDay() timeDiffSecs()
//      1.5.0   4/22/2018   Add printDictionary(dict: [String: String],...), [String: Double], [String: Int], default:expandLevels=0,dashLen=0(auto)
//      1.4.0   4/19/2018   Add Date extensions (from VBCompatability)
//      1.3.0   4/16/2018   move GreatCircAng, GreatCircDist, formatLatLon, formatDistDir, degToCardinal to MapLibVB
//      1.2.1   4/09/2018   Add printDictionary(dict: [String: Date], ...
//      1.2.0   3/09/2018   Add File handling funcs, formatDbl(num,places), isCharDigit
//  ------ General Purpose Subroutines ------

//TODO:- Testing: 100%
// printDictionary Dictionary not NSDictionary, Array not NSArray

import Foundation

//MARK:- General Purpose 

//---- Format Double "%#.#f" using fieldLen, places. ----
public func formatDbl(_ number: Double, _ places: Int) -> String {
    return String(format:"%.\(places)f", number)                            //String(format:%.2f",number)
}

//---- Format Double "%#.#f" using fieldLen, places. fieldLen!=0 to right justify - Truncates ----
public func formatDbl(number: Double, fieldLen: Int = 0, places: Int) -> String {
    let s: String
    if fieldLen == 0 {
        s = String(format:"%.\(places)f", number)                            //String(format:%.2f",number)
    } else {
        s = String(format:"%\(fieldLen).\(places)f", number).left(fieldLen)  //String(format:%6.2f",number)
    }
    return s
}

//---- Format Int using fieldLen ----
public func formatInt(number: Int, fieldLen: Int) -> String {
    let str =  String(number)
    return str.rightJust(fieldLen)
}

//---- Format a String number "%#.#f" using fieldLen & places. fieldLen=0 to remove leading spaces ----
//public func formatDbl(text: String, fieldLen: Int = 0, places: Int) -> String {
//    guard var dbl = Double(text) else {return text}
//    dbl = roundToPlaces(number: dbl, places: places)
//    var w = fieldLen
//    if fieldLen == 0 { w = text.count + places + 2 }
//    let format = "%\(w).\(places)f"
//    var t = String(format:format, dbl)              //String(format:"Alt %5.0f ft",gpsAlt)
//    if fieldLen == 0 { t = t.trimmingCharacters(in: .whitespaces) }
//    return t
//}

// ------ Make Time String "17:02" or " 5:02pm" from "17","2" ------
public func makeTimeStr(hrStr: String, minStr: String, to24: Bool) -> String {
    guard let h24 = Int(hrStr) else { return "?" + hrStr + ":" + minStr + "?" }
    let mm = minStr.count < 2 ? "0" + minStr : minStr
    if to24 {
        let hh = hrStr.count < 2 ? "0" + hrStr : hrStr
        return hh + ":" + mm
    }

    var h12: Int
    var ampm = "am"
    switch h24 {
    case  0 :
        h12 = 12
    case 1...11 :
        h12 = h24
    case 12 :
        h12 = h24
        ampm = "pm"
    default:
        h12 = h24 - 12
        ampm = "pm"
    }
    let hh12 = h12 < 10 ? " \(h12)" : "\(h12)"
    return hh12 + ":" + mm + ampm
}

//---- Rounds "number" to a number of decimal "places" e.g. (3.1426, 2) -> 3.14 ----
//public func roundToPlaces(number: Double, places: Int) -> Double {
//    let divisor = pow(10.0, Double(places))
//    return (number * divisor).rounded() / divisor
//}

//---- Format an integer with leading zeros e.g. (5, 3) -> "005" ----
//public func formatIntWithLeadingZeros(_ num: Int, width: Int) -> String {
//    var a = String(num)
//    while a.count < width {
//        a = "0" + a
//    }
//    return a
//}

// ------------- returns e.g. "1 name", "2 names", "No names" -----------
public func showCount(count: Int, name: String, ifZero: String = "0") -> String {
    if count == 1 { return "1 \(name)" }
    if count == 0 {
        return "\(ifZero) \(name.pluralize(count))"
    }
    return "\(count) \(name.pluralize(count))"
}

// ---- Test if a String is a valid Integer ---
public func isStringAnInt(_ string: String) -> Bool {
    return Int(string) != nil
}
public func isCharDigit(_ char: Character) -> Bool {
    return Int(String(char)) != nil
}

// ---- Test if a String is a valid Number ---
public func isNumeric(_ string: String) -> Bool {
    return Double(string) != nil
}

public func replaceCharInString(string: String, pos: Int, newChar: Character) -> String {
    let newString = String(string.prefix(pos)) + String(newChar) + string.dropFirst(pos + 1)
    return newString
}

public func replaceInString(string: String, strToInsert: String, from: Int, length: Int) -> String {
    let newStr = String(string.prefix(from)) + strToInsert + string.suffix(string.count - length - from)
    return newStr
}

// MARK:- Date Handling

public func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
    let dateC1 = date1.getComponents()
    let dateC2 = date2.getComponents()
    let sameDay = dateC1.day == dateC2.day && dateC1.month == dateC2.month && dateC1.year == dateC2.year
    return sameDay
}

public func timeDiffSecs(date1: Date, date2: Date) -> Double {
    let difference = date2.timeIntervalSince(date1)
    return difference
}

// MARK:- File Handling

//---- fileExists -
public func fileExists(url: URL) -> Bool {
    let fileExists = FileManager.default.fileExists(atPath: url.path)
    return fileExists
}

//---- folderExists -
public func folderExists(url: URL) -> Bool {
    var isDirectory: ObjCBool = false
    let folderExists = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
    return folderExists
}

// MARK:- Printing Dictionaries
// =================== for Printing Dictionaries =====================
public func formatDictionaryAny(title: String, obj: AnyObject, decimalPlace: Int = 1, titleLen: Int = 10, fillStr: String = ".") -> String {
    var str = "???"
    if obj is String {
        str = obj as! String
    } else if obj is Double {
        let num = obj as! Double
        str = String(num)
    }
    return formatDictionaryStr(title: title, str: str, titleLen: titleLen, fillStr: fillStr)
}

public func formatDictionaryDbl(title: String, num: Double, decimalPlace: Int = 1, titleLen: Int = 10, fillStr: String = ".") -> String {
    let str = String(num)
    return formatDictionaryStr(title: title, str: str, titleLen: titleLen, fillStr: fillStr)
}

public func formatDictionaryInt(title: String, num: Int, titleLen: Int = 10, fillStr: String = ".") -> String {
    let str = String(num)
    return formatDictionaryStr(title: title, str: str, titleLen: titleLen, fillStr: fillStr)
}

public func formatDictionaryStr(title: String, str: String, titleLen: Int = 10, fillStr: String = ".") -> String {
    if title == "" {
        return "\(str)"
    }
    var nFill = titleLen - title.count + 2
    if nFill < 0 { nFill = 0 }
    let fill = String(repeating: fillStr, count: nFill)
    return "\(title) \(fill) \(str)"
}

//=========================================================================================
public func printDictionary(dict: [String: AnyObject]?, expandLevels: Int = 0, dashLen: Int = 0, title: String) {
    guard let d = dict else { print("\n\(title) is nil!"); return }
    let dictNS = d as NSDictionary
    printDictionaryNS(dictNS: dictNS, expandLevels: expandLevels, dashLen: dashLen, title: title)
    return
}

//=========================================================================================
public func printDictionary(dict: [String: AnyObject], expandLevels: Int = 0, dashLen: Int = 0, title: String) {
        let dictNS = dict as NSDictionary
        printDictionaryNS(dictNS: dictNS, expandLevels: expandLevels, dashLen: dashLen, title: title)
        return
    }

//=========================================================================================
public func printDictionary(dict: [String: String], expandLevels: Int = 0, dashLen: Int = 0, title: String) {
    let dictNS = dict as NSDictionary
    printDictionaryNS(dictNS: dictNS, expandLevels: expandLevels, dashLen: dashLen, title: title)
    return
}

//=========================================================================================
public func printDictionary(dict: [String: Int], expandLevels: Int = 0, dashLen: Int = 0, title: String) {
    let dictNS = dict as NSDictionary
    printDictionaryNS(dictNS: dictNS, expandLevels: expandLevels, dashLen: dashLen, title: title)
    return
}

//=========================================================================================
public func printDictionary(dict: [String: Double], expandLevels: Int = 0, dashLen: Int = 0, title: String) {
    let dictNS = dict as NSDictionary
    printDictionaryNS(dictNS: dictNS, expandLevels: expandLevels, dashLen: dashLen, title: title)
    return
}

//=========================================================================================
public func printDictionary(dict: [String: Date], expandLevels: Int = 0, dashLen: Int = 0, title: String) {
    let dictNS = dict as NSDictionary
    printDictionaryNS(dictNS: dictNS, expandLevels: expandLevels, dashLen: dashLen, title: title)
    return
}

//=========================================================================================
public func printDictionaryNS(dictNS: NSDictionary,expandLevels: Int, dashLen: Int, title: String) {
    var length = dashLen
    let type = expandLevels > 0 ? "expanded": "base"
    print("========================== \(title) \(type) ===========================")
    
    if expandLevels == 0 {
        if length == 0 {        // Automatic Length calculation
            for (key, _) in dictNS {
                let keyLen = String(describing: key).count + 1
                if keyLen > length { length = keyLen }
            }
        }
        var isFirst = true
        var a1 = ""
        if length < 2 { length = 22 }
        for (key, value) in dictNS {
            if !isFirst { a1 += "\n" }
            isFirst = false
            var str2 = "????"
            let str1 = String(describing: key)
            if var str0 = value as? String {
                str0 = str0.replacingOccurrences(of: "\n", with: " ")
                var s: NSString = str0 as NSString
                if s.length > 60 {
                    s = s.substring(to: 59) as NSString
                    s = s.appending("...") as NSString
                }
                str2 = "\"" + (s as String) + "\""
                //} else if let db = value as? Int {
                //    str2 = String(db)
            } else if let db = value as? Double {
                str2 = String(db)
            } else if let db = value as? Date {
                str2 = db.ToString("MM/dd/yyyy hh:mm:ss a zzz")
            } else if value is NSArray {
                let n = (value as! NSArray).count
                str2 = "(Array) with \(n) " + "item".pluralize(n)
            } else if value is NSDictionary {
                let n = (value as! NSDictionary).count
                str2 = "{Dictionary} with \(n) " + "item".pluralize(n)
            }
            a1 += str1 + getDashes(key: str1, length: length) + "> " + str2
        }// next
        print(a1)
        
    } else {                                    // expandLevels > 0
        if length < 2 { length = 14 }
        for (key, value) in dictNS {
            //print("\(key) --> \(value) ")
            let sKey = key as! String
            print(sKey + getDashes(key: sKey, length: length) + ">", value)
        }//next
    }
    print("======================== end \(title) \(type) =========================\n")
    if expandLevels > 0 { print() }
}//end func

// Helper for printDictionaryNS
func getDashes(key: String, length: Int) -> String {
    let i = max(1, length - key.count - 1)
    let dashes = String(repeatElement("-", count: i))
    return " " + dashes
}

//MARK:- Date Extensions
extension Date {

    //---- Date.ToString - using formats like "MM/dd/yyyy hh:mm:ss"
    func ToString(_ format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let out = dateFormatter.string(from: self)
        return out
    }

    //---- Date.getComponants -
    func getComponents() -> DateComponents {
        let unitFlags:Set<Calendar.Component> = [ .year, .month, .day, .hour, .minute, .second, .calendar, .timeZone, .weekday, .weekdayOrdinal, .quarter, .weekOfMonth, .weekOfYear ]
        let dateComponents = Calendar.current.dateComponents(unitFlags, from: self)
        return dateComponents
    }

    var DateOnly: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateStr = dateFormatter.string(from: self)
        let date = dateFormatter.date(from: dateStr)!
        return date
    }

}//end Date extension


/**/
