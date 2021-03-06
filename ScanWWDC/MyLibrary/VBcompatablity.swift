//
//  VBcompatablity.swift
//  Almanac
//
//  Created by George Bauer on 1/23/18.
//  Copyright © 2018 GeorgeBauer. All rights reserved.
//
//  When next noncompatible ver is made, change sign to Sign
//  Ver 1.8.7  5/02/2019 Refactor to remove single-letter variables - no functionality change.
//      1.8.6  8/22/2018 Fix CDate "08/09/1995 16:19"
//      1.8.5  8/16/2018 Fix CDate "8/09/1995 16:19"
//      1.8.4  8/14/2018 Fix CDate "7/31/2005 2:58 PM"
//      1.8.3  8/11/2018 Fix CDate "8/09/1995 16:19:52";  VBcompPrintToLog= false
//      1.8.2  7/31/2018 Added GetNumberOfLines(Chan)
//      1.8.1  7/09/2018 Improvements to CDate(Str), fixed Val & isNumeric for leading spaces,  Implement Format(Int,Str)
//      1.8.0  6/16/2018 Add MidEquals, Like.  Fix VB.Hour
//      1.7.3  6/15/2018 Fix GetParentPath, Stub for Like.  Add VB.Hour,VB.Minute
//      1.7.2  5/23/2018 Add GetParentPath, change sign to Sign
//      1.7.1  5/21/2018 simplify getHexVal - Caution: returns 0.0 if it encounters non-hex char (unlike VB)
//      1.7.0  5/20/2018 Move .IndexOf to StringExtension
//      1.6.0  5/16/2018 Fix EOF, Fix Instr(start,str,str)
//      1.5.8  5/13/2018 Add LTrim()
//      1.5.7  5/13/2018 Add RTrim()
//      1.5.6  5/13/2018 Fix MsgBox MsgBoxStyle.YesNo    removed  DispatchQueue.main.async from MsgBox;  FileClose checks iChan FreeFile 0...2
//      1.5.5  5/11/2018 Add Asc() & Chr()
//      1.5.4  5/10/2018 Fix PadLeft & PadRight (now PadLeft === Rjust, PadRight == Ljust)
//      1.5.3  5/08/2018 Expand CDate(String) to accept "MM/dd/yyyy hh:mm:ss a"
//      1.5.2  5/08/2018 Allow Val(String) to handle &Hxxx; Change FileOpen encoding: to macOSRoman; Implement Write(chan,txt)
//      1.5.1  5/08/2018 Fix CDbl(String) to work if string has leading or trailing whitespace
//      1.5.0  5/08/2018 Add "Format(Date,formatStr)", expand FileOpen & PrintLine to handle output (still needs Close to do actual writing)
//      1.4.6  5/07/2018 Fix PadLeft & PadRight
//      1.4.5  5/06/2018 Fix Ljust & Rjust, ChangeExtension & PathCombine
//      1.4.4  5/06/2018 Add public var VBcompPrintToLog = true & change some error messages
//      1.4.3  5/06/2018 Fix LineInput in files using CR/LF. Change URL(String: to URL(fileURLWithPath:
//      1.4.2  5/02/2018 New MsgBox,LJust,RJust, String.PadLeft,.PadRight,.Split, ChangeExtension,PathCombine,GetFileName,GetFileNameWithoutExtension
//      1.4.1  4/20/2018 Fix FileOpen,LineInput
//      1.4.0  4/19/2018 Moved Date extensions to MyFuncs.swift
//      1.3.0  4/17/2018 file LineInput
//      1.2.0  4/07/2018 Change CDate(str) to return 11/11/1111 if nil, IsDate() accepts "MM/dd/yyyy", rejects others
//      1.1.9  4/05/2018 Add VB.CreateFile; change VB.CreateDirectory to not force user's home & not create intermediate folders
//      1.1.8  3/30/2018 Fix CInt(String) for "14.9", fix Val() for trailing non-digits "45.6%"
//      1.1.7  3/17/2018 Fix CInt() for negs
//      1.1.6  3/09/2018 Tweak VB.DirectoryExists(), remove String.Length()
//      1.1.5 modified msgBox to accept title
//      1.1.4 modified msgBox alert to DispatchQueue.main.async, Fix CInt()
//  previously 2/18/2018 Added InstrRev, CSng

//TODO:- Testing: 99.22%  LineInput beyond EOF, asc chr errors

// Requires StringEntension, MyFuncs

//var:  vbCr, vbLf, VBcompPrintToLog, knownProblems
//func: UCase, LCase, Left, Right, Mid, MidEquals, InStr, InStrRev, Trim, LTrim, RTrim, IsNumeric, Len, Space, CInt, CDbl, CSng, Val
//      Sign, Round, Split, Weekday, DateString, CDate, ChangeExtension, PathCombine, GetFileNameWithoutExtension, GetFileName,
//      GetParentPath, Format, Str, Ljust, Rjust, Asc, Char, Like, MsgBox,
//      FileOpen, GetNumberOfLines, FileClose, LineInput, EOF, WriteLine, Print, PrintLine, FreeFile
//      VB.Left, VB.Right, VB.DirectoryExists, VB.FileExists, VB.CreateDirectory, VB.CreateFile, VB.DeleteFile,
//      VB.Rename, VB.CopyFile, VB.Month, VB.Day, VB.Year, VB.Hour, VB.Minute, VB.Second
//      ListBox, RichTextBox
//      String.Substring, String.Split

import Cocoa

let vbCr = "\n"
let vbLf = "\n"

public var VBcompPrintToLog = false
public var knownProblems = 0

@available(*, deprecated, message: "Use 'str.uppercased()' instead")
public func UCase(_ str: String) -> String {
    return str.uppercased()
}

@available(*, deprecated, message: "Use 'str.lowercased()' instead")
public func LCase(_ str: String) -> String {
    return str.lowercased()
}

@available(*, deprecated, message: "Use 'str.prefix(int)' instead")
public func Left(_ str: String, _ int: Int) -> String {
    return str.left(int)
}

@available(*, deprecated, message: "Use 'str.suffix(int)' instead")
public func Right(_ str: String, _ int: Int) -> String {
    return str.right(int)
}

/// Emulates VB Mid func (start at 1)
public func Mid(_ str: String, _ idx: Int) -> String {
    return str.substring(begin: idx - 1)
}

/// Emulates VB Mid func (start at 1)
public func Mid(_ str: String, _ idx: Int, _ len: Int) -> String {
    return str.substring(begin: idx - 1, length: len)
}

//Mid(w, 1, 3) = "FEW"
public func MidEquals(str: String, Start: Int, Len: Int, newStr: String) -> String {
    let startIdx = str.index(str.startIndex, offsetBy: Start-1)
    let endIdx = str.index(startIdx, offsetBy: Len)
    return str.replacingCharacters(in: startIdx..<endIdx, with: newStr)
}

/// Emulates VB InStr func (start at 1)
public func InStr(_ str: String, _ searchStr: String) -> Int {
    return str.firstIntIndexOf(searchStr) + 1
}

/// Emulates VB InStrRev func (start at 1)
public func InStrRev(_ str: String, _ searchStr: String) -> Int {
    return str.lastIntIndexOf(searchStr) + 1
}

/// Emulates VB InStr func (start at 1)
public func InStr(_ start: Int, _ str: String, _ searchStr: String) -> Int {
    let aa = str.substring(begin: start-1)
    let idx = aa.firstIntIndexOf(searchStr)
    if idx < 0 { return 0 }
    return idx + start
}

//---- Trim - Removes whitespace AND NewLines from both ends
@available(*, deprecated, message: "Use 'str.trim' instead")
public func Trim(_ str: String) -> String {
    return str.trimmingCharacters(in: .whitespacesAndNewlines)
}

/// Remove ONLY whitespace from Left
public func LTrim(_ str: String) -> String {
    let trimmed = str.replacingOccurrences(of: "^\\s+", with: "", options: .regularExpression)
    return trimmed
}
/// Remove ONLY whitespace from Right
public func RTrim(_ str: String) -> String {
    let trimmed = str.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
    return trimmed
}

/// true if trimmed String converts to Double
public func IsNumeric(_ str: String) -> Bool {
    return Double(str.trimmingCharacters(in: .whitespaces)) != nil
}

@available(*, deprecated, message: "Use 'str.count' instead")
public func Len(_ str: String) -> Int {
    return str.count
}

@available(*, deprecated, message: "Use 'String(repeating: \" \", count: n)' instead")
public func Space(_ count: Int) -> String {
    return String(repeating: " ", count: count)
}

///Use 'Int(Double(str)?.rounded() ) ?? 0' instead
public func CInt(_ str: String) -> Int {
    let dbl = Double(str.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0.0
    return Int(dbl.rounded())
}

///Use 'Int(dbl.rounded() )' instead
public func CInt(_ dbl: Double) -> Int {
    return Int(dbl.rounded())
}

/// Use 'Double(str.trim) ?? 0' instead
public func CDbl(_ str: String) -> Double {
    return Double(str.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0.0
}

@available(*, deprecated, message: "Use 'Double(int)' instead")
public func CDbl(_ int: Int) -> Double {
    return Double(int)
}

@available(*, deprecated, message: "Use 'Float(n) ?? 0' instead")
public func CSng(_ str: String) -> Float {
    return Float(str) ?? 0.0
}

@available(*, deprecated, message: "Use Float(n) instead")
public func CSng(_ n: Int) -> Float {
    return Float(n)
}

/// Convert String to Double.
///
/// Reads String up to 1st non-numeric Character.
///
/// Returns 0 if String is not numeric.
///
/// Hex values start with '&H' or '0X'.
/// - Parameter string: String to be converted
/// - Returns: Double
public func Val(_ string: String) -> Double {
    let trimmed = string.trimmingCharacters(in: .whitespaces)
    let first2 = trimmed.prefix(2).uppercased()
    if first2 == "&H" || first2 == "0X" {
        return getHexVal(string)
    }
    var str = ""
    for c in trimmed {
        if "0123456789.-".contains(c) {
            str += String(c)
        } else {
            break
        }
    }
    return Double(str) ?? 0.0
}

private func getHexVal(_ string: String) -> Double {
    let str = String(string.dropFirst(2)).uppercased()      //????? needed?
    guard let ret = Int(str, radix: 16) else { return 0.0 }
    return Double(ret)
}

@available(*, deprecated, message: "Use 'n.signum()' instead")
public func Sign(_ int: Int) -> Int {
    return int.signum()
}

/// Round a Double to a fixed number of places.
///
/// - Parameters:
///   - val: Double to be rounded
///   - places: Number of decimal places in returned value
/// - Returns: Double
public func Round(_ val: Double, _ places: Int) -> Double {
    let numberOfPlaces: Double = Double(places)
    let multiplier = pow(10.0, numberOfPlaces)
    let rounded = round(val * multiplier) / multiplier
    return rounded
}

//StringSplitOptions.RemoveEmptyEntries
public enum StringSplitOptions{
    case none
    case RemoveEmptyEntries
}
/// Split a String at a given Character
///
/// - Parameters:
///   - str: String to be split
///   - separator: Character at which to split String
/// - Returns: String array
@available(*, deprecated, message: "Use 'str.components(separatedBy: sep)' instead")
public func Split(_ str: String, _ separator: Character) -> [String] {
    let sep = String(separator)
    return str.components(separatedBy: sep)
}

/// Returns a Weekday Number (1=Sun)
public func Weekday(_ date: Date) -> Int {
    let dateComponents = Calendar.current.dateComponents([.weekday], from: date)
    return dateComponents.weekday ?? -1
}

/// Return formatted String of today's date
public func DateString() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yyyy"
    let dateStr = dateFormatter.string(from: Date())
    return dateStr
}

/// Converts "MM/dd/yyyy" or "MM/dd/yyyy hh:mm:ss a" to Date
///
/// Caution: returns 11/11/1111 if nil
///
/// - Parameter string: String to be converted
/// - Returns: Date
public func CDate(_ string: String) -> Date {
    let dateStr = string.trim
    let len = dateStr.count
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yyyy"
    let nilDate = dateFormatter.date(from: "11/11/1111")!
    if len <= 10 {
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let optionalDate: Date? = dateFormatter.date(from: dateStr)
        //if VBcompPrintToLog { print("VBC😎CDate \(string) -> \(optionalDate)") }
        if let date = optionalDate { return date }
    } else if len >= 17 {                                       // was 19: fix for "8/09/1995 16:19:52" and "7/31/2005 2:58 PM"
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm:ss a"      // fix for "8/09/1995 16:19" len=12
        var optionalDate: Date? = dateFormatter.date(from: dateStr)
        if optionalDate == nil {                                    // fix for "8/09/1995 16:19:52"
            dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"        // fix for "8/09/1995 16:19:52"
            optionalDate = dateFormatter.date(from: dateStr)        // fix for "8/09/1995 16:19:52"
        }
        if optionalDate == nil {                                    // fix for "7/31/2005 2:58 PM"
            dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"         // fix for "7/31/2005 2:58 PM"
            optionalDate = dateFormatter.date(from: dateStr)        // fix for "7/31/2005 2:58 PM"
        }
        //if VBcompPrintToLog { print("VBC😎CDate \(string) -> \(optionalDate)") }
        if let date = optionalDate { return date }
    } else if len >= 12 {               //was 14: fix for "8/09/1995 16:19" len=12
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale?
        //dateFormatter.timeZone = NSTimeZone.init(forSecondsFromGMT: 0) as TimeZone?

        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"
        let optionalDate: Date? = dateFormatter.date(from: dateStr)
        //if VBcompPrintToLog { print("VBC😎CDate \(string) -> \(optionalDate)") }
        if let date = optionalDate {
            var dc = date.getComponents()
            var yr = dc.year!
            if yr < 100 {
                if yr < 80 { yr += 2000 } else { yr += 1900 }
                dc.year = yr
                return dc.date!
            }
            return date
        }
    }
    if VBcompPrintToLog { print("VBC😡CDate could not translate '\(dateStr)'") }
    return nilDate
}

/// Converts MM,dd,yyyy to Date
///
/// - Parameters:
///   - month: month Int
///   - day: day Int
///   - year: 4-digit year Int
/// - Returns: Date
public func CDate(_ month: Int, _ day: Int, _ year: Int) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yyyy"
    let dateStr = "\(month)/\(day)/\(year)"
    let date = dateFormatter.date(from: dateStr)!
    return date
}

/// Replace one file extension with another
///
/// - Parameters:
///   - name: old filename
///   - newExtension: new file extension
/// - Returns: new filename
public func ChangeExtension(_ name: String, _ newExtension: String) -> String {
    var newExt = newExtension
    if newExtension.hasPrefix(".") {newExt = String(newExtension.dropFirst())}
    let pDot = name.lastIntIndexOf(".")
    if pDot < 0 { return name + "." + newExt }
    let pSlash = name.lastIntIndexOf("/")
    if pDot < pSlash { return name + "." + newExt }
    let name2 = name.dropLast(name.count - pDot - 1)
    return name2 + newExt
}

/// Combine 2 String so they are joind by a single '/'
public func PathCombine(_ base: String, _ addon: String) -> String {
    var base2 = base
    var addon2 = addon
    if base.hasSuffix("/")  { base2  = String(base.dropLast()) }
    if addon.hasPrefix("/") { addon2 = String(addon.dropFirst()) }
    return base2 + "/" + addon2
}

/// Extract a filename from a path, removing the file extension
public func GetFileNameWithoutExtension(_ fullPath: String) -> String {
    var url = URL(fileURLWithPath: fullPath)
    url.deletePathExtension()
    return url.lastPathComponent
}

/// Extract a filename from a path
public func GetFileName(_ fullPath: String) -> String {
    let url = URL(fileURLWithPath: fullPath)
    return url.lastPathComponent
}

/// Remove last element from a filepath
///
/// If fullPath ends with a '/', only the trailing '/' will be removed.
///
/// If fullPath does not contain '/', returns an empty String
public func GetParentPath(_ fullPath: String) -> String {
    let idxSlash = fullPath.lastIntIndexOf("/")
    if idxSlash < 0 { return "" }
    let path = fullPath.left(idxSlash)
    return path
}


@available(*, deprecated, message: "Use ' \"\\(dbl)\" ' instead")
public func Format(_ dbl: Double) -> String {
    return "\(dbl)"
}

@available(*, deprecated, message: "Use ' \"\\(dbl)\" ' instead")
public func Format(_ dbl: Int) -> String {
    return "\(dbl)"
}


/// Format a Date using a format String.
///
/// - Parameters:
///   - date: Date to be formatted
///   - format: e.g. \"E MM/dd/yyyy hh:mm:ss a\"
/// - Returns: String
public func Format(_ date: Date, _ format: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    let dateStr = dateFormatter.string(from: date)
    return dateStr
}
//????????????????
/// Integer format "00", "###000"
public func Format(_ int: Int, _ format: String) -> String {
    let fieldLen = format.count
    var zeros = 0
    for char in format {
        if char == "0" { zeros += 1 }
    }
    var str = "\(int)"
    if str.count < zeros {
        str = String(repeating: "0", count: zeros - str.count) + str
    }
    if str.count < fieldLen {
        str = String(repeating: " ", count: fieldLen - str.count) + str
    }
    return str
}

@available(*, deprecated, message: "Use ' \"\\(anyType)\" ' instead")
public func Str(_ anyType: Any) -> String {
    return "\(anyType)"
}

public func Ljust(_ str: String, _ n: Int) -> String {
    let len = str.count
    if n <= len { return String(str.prefix(n)) }
    let fill = String(repeating: " ", count: n - len)
    return str + fill
}

public func Rjust(_ str: String, _ n: Int) -> String {
    let len = str.count
    if n <= len { return String(str.prefix(n)) }
    let fill = String(repeating: " ", count: n - len)
    return fill + str
}

public func Asc(_ str: String) -> Int {
    if str.isEmpty { return 0 }
    guard let uScaler = (UnicodeScalar(str)) else  { return 0 }
    let int = Int(uScaler.value)
    return int
}

public func Asc(_ char: Character) -> Int {
    let str: String = String(char)
    return Asc(str)
}

public func Chr(_ myInteger: Int) -> Character {
    // convert Int to a valid UnicodeScalar
    if myInteger < 0 || myInteger > 32767 { return Character(UnicodeScalar(0)) }
    guard let myUnicodeScalar = UnicodeScalar(myInteger) else { return Character(UnicodeScalar(0)) }
    return Character(myUnicodeScalar)
}

public func Like(_ str: String, _ template: String) -> Bool {
    var templateRE = "^"
    var insideBrackets = false
    var justGotBracket = false
    for chr in template {
        var chrRE = String(chr)
        if chr == "#" && !insideBrackets { chrRE = "\\d" }
        if chr == "." && !insideBrackets { chrRE = "\\." }
        if chr == "!" && justGotBracket  { chrRE = "^"   }
        if chr == "?"                    { chrRE = "."   }
        templateRE += chrRE
        if chr == "[" {
            insideBrackets = true
            justGotBracket = true
        } else {
            justGotBracket = false
            if chr == "]" { insideBrackets = false }
        }
    }
    templateRE += "$"
    print("🤠\"\(template)\" -> \"\(templateRE)\"")
    return isMatch(for: templateRE, in: str)
//    guard let regex = Regex(pattern: templateRE) else { return false }
//    return regex.match(str)
}

//MARK:- MsgBox 485

public enum MsgBoxStyle {
    case Information
    case OkCancel
    case YesNo
}
public enum MsgBoxResult {
    case None
    case Yes
    case No
    case Ok
    case Cancel
}

public func MsgBox(_ str: String) {
    if VBcompPrintToLog { print("VBMsgBox: ", str) }
    //DispatchQueue.main.async {
        let alert = NSAlert()
        alert.informativeText = str
        alert.runModal()
    //}
    return
}

public func MsgBox(_ str: String, _ title: String) {
    if VBcompPrintToLog { print("VBMsgBox: ", str) }
    //DispatchQueue.main.async {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = str
        alert.runModal()
    //}
    return
}

public func MsgBox(_ str: String, _ style: MsgBoxStyle) -> MsgBoxResult {

    if style == .Information {
        MsgBox(str)
        return .None
    }

    if style == .OkCancel {
        let response = alertOKCancel(question: str, text: "")
        if response {
            return .Ok
        }
        return .Cancel
    }

    if style == .YesNo {
        let response = alertYesNo(question: str, text: "")
        if response {
            return .Yes
        }
        return .No
    }

    return .None                            // Unknown Style
    }

//---- alertOKCancel - OKCancel dialog box. Returns true if OK
private func alertOKCancel(question: String, text: String) -> Bool {
    let alert = NSAlert()
    alert.messageText       = question
    alert.informativeText   = text
    alert.alertStyle        = .warning
    alert.addButton(withTitle: "OK")
    alert.addButton(withTitle: "Cancel")
    return alert.runModal() == .alertFirstButtonReturn
}

//---- alertYesNo - YesNo dialog box. Returns true? if Yes
private func alertYesNo(question: String, text: String) -> Bool {
    let alert = NSAlert()
    alert.messageText       = question
    alert.informativeText   = text
    alert.alertStyle        = .warning
    alert.addButton(withTitle: "Yes")
    alert.addButton(withTitle: "No")
    return alert.runModal() == .alertFirstButtonReturn
}

//---- InputBox - returns text
func InputBox(_ msg: String) -> String {
    let alert = NSAlert()
    alert.messageText = msg
    alert.addButton(withTitle: "Ok")
    alert.addButton(withTitle: "Cancel")
    let input = NSTextField(frame: NSMakeRect(0, 0, 60, 30))
    input.stringValue = ""
    input.font = NSFont(name: "HelveticaNeue-Bold", size: 16)!
    alert.accessoryView = input
    //alert.accessoryView?.window!.makeFirstResponder(input)
    //self.view.window!.makeFirstResponder(input)               //????? How do I make "input" the FirstResponder
    //input.becomeFirstResponder()
    let button: NSApplication.ModalResponse = alert.runModal()
    alert.buttons[0].setAccessibilityLabel("InputBox OK")

    //input.becomeFirstResponder()
    if button == .alertFirstButtonReturn {
        let str = input.stringValue
        return str
    }
    return ""                               // anything else
}



/*
  */

//------------------------------------------------------------------------------
//MARK:- Dummy Routines //599

//------ IsDate - Only checks str in form of "MM/dd/yyyy"
public func IsDate(_ dateStr: String) -> Bool {
    let date = CDate(dateStr)
    let dc = date.getComponents()       // from MyFuncs ?????? Change to internal
    if dc.month != 11 || dc.day != 11 || dc.year != 1111 { return true}
    knownProblems += 1
    return false
}

//------ DateValue - returns 11/11/1111 if str not in form of "MM/dd/yyyy"
public func DateValue(_ dateStr: String) -> Date {
    knownProblems += 1
    return CDate(dateStr)
}

public func Format(_ anyType: Any, _ format: String) -> String {
    knownProblems += 1
    return "\(anyType)"
}

public func Seek(_ chan: Int, _ ptr: Int) {
    print("😡 Not implemented! 'Seek' is a dummy routine.")
    knownProblems += 1
}

//---------------------------------- end Dummies --------------------------------------

//MARK:- File Handling 628

public struct FileSim: Equatable {     //------------------------------ Simulate VB behind-the-scenes file-handling
    public var openMode  = OpenMode.Closed   //Input,Output, (Random,Binary,Append not implemented)
    public var fileName  = ""
    public var EOF       = false
    public var linePtr   = 0
    public var partialLine = ""
    public var fileLines = [String]()
    public var nFileLines: Int { return fileLines.count }
    public mutating func fileOpen(url: URL, mode: OpenMode) throws {
        if VBcompPrintToLog { print("VB😊Open File: mode=\(mode), url:\n\(url)") }
        let fileManager = FileManager.default
        //let fileDataText = [String]()
        self.openMode = mode
        self.fileName = url.path
        if mode == .Input {
            if(fileManager.fileExists(atPath: url.path)){
                let content = fileManager.contents(atPath: url.path)
                if content == nil { throw OpenError.ReadError }
                let contentAsString = String(data: content!, encoding: String.Encoding.macOSRoman)  // macOSRoman more forgiving than utf8
                if contentAsString == nil { throw OpenError.ReadError }
                //if VBcompPrintToLog { print(contentAsString!) }
                self.fileLines = contentAsString!.components(separatedBy: "\n")
                if VBcompPrintToLog { print("VB😊Open File: has \(self.fileLines.count) lines.") }
                linePtr = 0
            } else {
                print("VBC😡File does not exist!\n\(url.path)")
                throw OpenError.NotExists
            }
        } else if mode == .Output {
            //if VBcompPrintToLog { print("VB😊Open Filefor output.") }
        } else {
            print("VBC😡File OpenMode \(mode) is not supported!\n\(url.path)")
        }
    }//end func FileOpen

    public mutating func getNextLine() -> String {
        var line: String
        if linePtr < fileLines.count {
            line = fileLines[linePtr]
            if line.hasSuffix("\r") { line = String(line.dropLast()) }
        } else {
            line = ""
        }
        linePtr += 1
        if linePtr >= fileLines.count {
            EOF = true
            if linePtr > fileLines.count {
                print("😡 \(linePtr) of \(fileLines.count)")
            }
        }
        if linePtr + 1 == fileLines.count && line.isEmpty { EOF = true }
        return line
    }
}//end struct FileSim

enum OpenError: Error {
    case NotExists
    case NoAvailableChans
    case BadURL
    case ReadError
}

public enum OpenMode {
    case Closed
    case Input
    case Output
    case Random
    case Binary
    case Append
}

public enum OpenAccess {
    case Closed
    case Input
    case Output
}

public let openMode         = OpenMode.Closed
public var VBavailableChans = [true, true, true]
public var fileSim = [FileSim(),FileSim(),FileSim()]

public func FileOpen(_ iChan: Int, _ path: String, _ mode: OpenMode) throws {
    if iChan < 0 || !VBavailableChans[iChan] { throw OpenError.NoAvailableChans}
    let url = URL(fileURLWithPath: path)
    if VBcompPrintToLog { print("VBC😊Open File: Chan=\(iChan), mode=\(mode), url:\n\(url)") }
    do {
        fileSim[iChan] = FileSim()
        try fileSim[iChan].fileOpen(url: url, mode: mode)
        VBavailableChans[iChan] = false                     // file opened ok, show mark the chan as in-use
    } catch {
        throw error
    }
}

// Not a real VB func
public func GetNumberOfLines(_ iChan: Int) -> Int {
    return fileSim[iChan].nFileLines
}

//------ FileClose - releases Chan, flushes WriteLine buffer
public func FileClose(_ iChan: Int) {
    if iChan < 0 || iChan >= fileSim.count { return }
    if fileSim[iChan].openMode == .Output {
        let fileURL = URL(fileURLWithPath: fileSim[iChan].fileName)
        var text = fileSim[iChan].fileLines.joined(separator: "\r\n")
        text += fileSim[iChan].partialLine
        do {
            try text.write(to: fileURL, atomically: true, encoding: .utf8)
        }
        catch { print("😡Error: FileClose failed to Write to \(fileSim[iChan].fileName)") }
    }
    VBavailableChans[iChan] = true
    fileSim[iChan] = FileSim()
    if VBcompPrintToLog { print("VBClose File: Chan=\(iChan)") }
}

public func LineInput(_ iChan: Int) -> String {
    return fileSim[iChan].getNextLine()
}

public func EOF(_ iChan: Int) -> Bool {
    return fileSim[iChan].EOF
}

// variatic param list:                 func arithmeticMean(_ numbers: Double...) -> Double {
public func WriteLine(_ iChan: Int, _ params: Any...) {
    knownProblems += 1
    print("VBC😡WriteLine to chan:\(iChan) not implemented!")
    print(params, separator: ",", terminator: "\n")
}

public func Print(_ iChan: Int, _ txt: String) {
    //print("VBC😡'Print(chan,txt)' not implemented! \(txt)")
    if fileSim[iChan].openMode != .Output {
        knownProblems += 1
        print("VBC😡File OpenMode \(fileSim[iChan].openMode) does not support 'Print'!\n\(fileSim[iChan].fileName)")
        return
    }
    fileSim[iChan].partialLine.append(txt)
}

public func PrintLine(_ iChan: Int, _ txt: String) {
    if fileSim[iChan].openMode != .Output {
        knownProblems += 1
        print("VBC😡File OpenMode \(fileSim[iChan].openMode) does not support 'PrintLine'!\n\(fileSim[iChan].fileName)")
        return
    }
    fileSim[iChan].fileLines.append(fileSim[iChan].partialLine + txt)
    fileSim[iChan].linePtr += 1
    fileSim[iChan].partialLine = ""
}

// returns a free file channel or -1
public func FreeFile() -> Int {
    for i in 0...2 {
        if VBavailableChans[i] { return i}
    }
    return -1
}

//MARK:- Input (from VBdataArray) - Obsolete 790

//public func Input(_ index: inout Int, _ val: inout String) {
//    val = VBdataArray[index]
//    index += 1
//}
//
//public func Input(_ index: inout Int, _ val: inout Double) {
//    let line = VBdataArray[index]
//    index += 1
//    val = Double(line) ?? 0.0
//}
//
//public func Input(_ index: inout Int, _ val: inout Int) {
//    let line = VBdataArray[index]
//    index += 1
//    val = Int(line) ?? 0
//}


//VB.AppInfoDirectoryPath
//Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData)
//New DirectoryInfo(DailyClimateBaseDir)
//if a Like "## ## ##"
//var ReadText: String = File.ReadAllText(...

//MARK:- VB Class VB.xxx 816

//---- VB.Left -
public class VB {

    //---- VB.Left -
    static func Left(_ str: String, _ count: Int) -> String {
        return str.left(count)
    }

    //---- VB.Right -
    static func Right(_ str: String, _ count: Int) -> String {
        return str.right(count)
    }

    //VB File IO

    //---- VB.DirectoryExists -
    static func DirectoryExists(_ atPath: String) -> Bool {
        var isDirectory: ObjCBool = false
        let folderExists = FileManager.default.fileExists(atPath: atPath, isDirectory: &isDirectory)
        return folderExists
    }

    //---- VB.FileExists -
    static func FileExists(_ atPath: String) -> Bool {
        return FileManager.default.fileExists(atPath: atPath)
    }

    //---- VB.CreateDirectory - creates a Directory
    static func CreateDirectory(_ atPath: String) -> Bool {
        let iReturn: Bool
        do {
            try FileManager.default.createDirectory(atPath: atPath, withIntermediateDirectories: false, attributes: nil)
            iReturn = true
        } catch let error as NSError {
            print("VBC😡Error: \(error.localizedDescription)")
            iReturn = false
        }
        return iReturn
    }

    //---- VB.CreateFile - creates a File
    static func CreateFile(_ atPath: String) -> Bool {
        FileManager.default.createFile(atPath: atPath, contents: nil, attributes: nil)
        return true
    }

    //---- VB.DeleteFile -
    @available(*, deprecated, message: "Use FileManager.default.removeItem(atPath: atPath) instead")
    static func DeleteFile(_ atPath: String) -> Bool {
        let iReturn: Bool
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(atPath: atPath)
            iReturn = true
        } catch let error {
            print("VBC😡Error: \(error.localizedDescription)")
            iReturn = false
        }
        return iReturn
    }

    //---- VB.Rename -
    @available(*, deprecated, message: "Use FileManager.default.moveItem(atPath: atPath, toPath: to) instead")
    static func Rename(_ atPath: String, _ to: String) -> Bool {
        do {
            try FileManager.default.moveItem(atPath: atPath, toPath: to)
        } catch {
            print("VBC😡Error: \(error.localizedDescription)")
            return false
        }
        return true
    }

    //---- VB.CopyFile -
    static func CopyFile(_ atPath: String, _ toPath: String) -> Bool {
        let iReturn: Bool
        do {
            try FileManager.default.copyItem(atPath: atPath, toPath: toPath)
            iReturn = true
        } catch {
            print("VBC😡Error: \(error.localizedDescription)")
            iReturn = false
        }
        return iReturn
    }

    // VB Date Stuff

    //---- VB.Month -
    static func Month(_ date: Date) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M"
        let out = Int(dateFormatter.string(from: date))!
        return out
    }

    //---- VB.Day -
    static func Day(_ date: Date) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        let out = Int(dateFormatter.string(from: date))!
        return out
    }

    //---- VB.Year -
    static func Year(_ date: Date) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y"
        let out = Int(dateFormatter.string(from: date))!
        return out
    }

    //---- VB.Hour -
    static func Hour(_ date: Date) -> Int {
        //let unitFlags:Set<Calendar.Component> = [ .year, .month, .day, .hour, .minute, .second, .calendar, .timeZone, .weekday, .weekdayOrdinal, .quarter, .weekOfMonth, .weekOfYear ]
        let dateComponents = Calendar.current.dateComponents([.hour], from: date)
        return dateComponents.hour ?? -1
    }

    //---- VB.Minute -
    static func Minute(_ date: Date) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "m"
        let out = Int(dateFormatter.string(from: date))!
        return out
    }
    
    //---- VB.Second -
    static func Second(_ date: Date) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "s"
        let out = Int(dateFormatter.string(from: date))!
        return out
    }

}//end VB class
//---------------------------------------------------------------------

//// Not used - just for reference
//private func DirStuff() {
//    let completePath = "/Users/sarah/Desktop/Files.playground"
//    let completeUrl = URL(fileURLWithPath: completePath)
//    print(completeUrl)
//
//    // get your home folder
//    let home = FileManager.default.homeDirectoryForCurrentUser          // file:///Users/georgebauer/
//    let playgroundPath = "Desktop/Files.playground"
//    let playgroundUrl  = home.appendingPathComponent(playgroundPath)    // file:///Users/georgebauer/Desktop/Files.playground/
//    print(playgroundUrl.path)                                           // "/Users/georgebauer/Desktop/Files.playground"
//    print(playgroundUrl.absoluteString)                                 // "file:///Users/georgebauer/Desktop/Files.playground/"
//    print(playgroundUrl.absoluteURL)                                    // "file:///Users/georgebauer/Desktop/Files.playground/"
//    //print(playgroundUrl.baseURL)                                               // nil
//    print(playgroundUrl.pathComponents)                                 // ["/", "Users", "georgebauer", "Desktop", "Files.playground"]
//    print(playgroundUrl.lastPathComponent)                              // "Files.playground"
//    print(playgroundUrl.pathExtension)                                  // "playground"
//    print(playgroundUrl.isFileURL)                                      // true
//    print(playgroundUrl.hasDirectoryPath)                               // true
//
//    var urlForEditing = home
//    print(urlForEditing.path)
//
//    urlForEditing.appendPathComponent("Desktop")
//    print(urlForEditing.path)
//
//    urlForEditing.appendPathComponent("Test file")                      // file:///Users/georgebauer/Desktop/Test%20file
//    print(urlForEditing.path)
//
//    urlForEditing.appendPathExtension("txt")                            // file:///Users/georgebauer/Desktop/Test%20file.txt
//    print(urlForEditing.path)
//
//    urlForEditing.deletePathExtension()
//    print(urlForEditing.path)
//
//    urlForEditing.deleteLastPathComponent()
//    print(urlForEditing.path)
//
//    //While those commands edited the URL in place, you can also create a new URL from an existing one.
//    let fileUrl = home
//        .appendingPathComponent("Desktop")
//        .appendingPathComponent("Test file")
//        .appendingPathExtension("txt")
//    print(fileUrl.path)
//
//    let desktopUrl = fileUrl.deletingLastPathComponent()
//    print(desktopUrl.path)
//
//    //NSString has a lot of file path manipulation methods, but Swift’s String struct doesn’t.
//    //Instead, you should use URLs when working with file paths.
//    //Working with URLs will become even more important as Apple transitions to the new Apple File System (APFS).
//    //However, there is one case where you still have to use a string: checking to see if a file or folder exists.
//    //The best way to get a string version of a URL is through the path property.
//
//    let fileManager = FileManager.default
//    fileManager.fileExists(atPath: playgroundUrl.path)
//
//    let missingFile = URL(fileURLWithPath: "this_file_does_not_exist.missing")
//    fileManager.fileExists(atPath: missingFile.path)
//
//    //Checking whether a folder exists is more obscure, as you have to check if the URL points to a valid resource that is also a folder.
//    //This requires a very un-Swifty mechanism of using an inout Objective-C version of a Bool.
//    var isDirectory: ObjCBool = false
//    fileManager.fileExists(atPath: playgroundUrl.path, isDirectory: &isDirectory)
//    print(isDirectory.boolValue)
//
//    let isDir = fileManager.fileExists(atPath: playgroundUrl.path)
//    print("isDir = \(isDir)")
//    //Current Dir
//    let currentPath = fileManager.currentDirectoryPath
//    print("Current path = \(currentPath)")
//}//end func dirStuff - Not used - just for reference

//MARK:- ListBox Class simulators 1029
class ListBox {
    var SelectedIndex = 0
    var Text = ""
    var Items = [String]()
    //var SelectedItem:String { return Items.Items(SelectedIndex) } //????? does not work
}

//class ItemList {
//    var Items = [String]()
//    var Count: Int { return Items.count }
//
//    func Clear() {
//        Items = []
//    }
//    func clear() {
//        Items = []
//    }
//    func Add(_ newItem: String) {
//        Items.append(newItem)
//    }
//    func append(_ newItem: String) {
//        Items.append(newItem)
//    }
//}

//MARK:- RichTextBox Class 1055
class RichTextBox {
    var Text = ""
    var TextLength: Int { return Text.count }
    func AppendText(_ str: String) {
        Text += str
    }
}

// MARK:- String Extensions 1064
extension String {

    @available(*, deprecated, message: "Use 'substring(begin:, length:)' instead")
    func Substring(_ begin: Int, _ length: Int) -> String {
        return substring(begin: begin, length: length)
    }

    func Split(_ sep: String, _ splitOpts: StringSplitOptions = .none) -> [String] {
        //let sepStr = String(sep)
        let arr = self.components(separatedBy: sep)
        if splitOpts != .RemoveEmptyEntries {
            return arr
        }
        let nonempty = arr.filter { (x) -> Bool in !x.isEmpty }    // Use filter to eliminate empty strings.
        return nonempty
    }

}//end String Extensions
