//
//  ViewController.swift
//  AnalyseSwiftCode
//
//  Created by George Bauer on 11/8/18.
//  Copyright © 2018,2019 George Bauer. All rights reserved.
//

// User Interface:
// When in full screen mode - Show file-path above window
// make btnFindAllxcodeproj the default if popup touched.
// toggle btnFindAllxcodeproj to "Abort" when running, (and disable other buttons).
// selectively enable View & Analyse buttons or use segmented button.
// Use Menus: File/Find_All_xcodeproj_Files
// Help System
// Error Handler
// Single Click for analyse & change dir - no double Click
// if newly opened folder has a single xcodeproj: analyse it
// Display AnalyseSwift as expandable tree, with option for printable.
// Show signatures for funcs & inits

// Code:
// Unit-Test CodeLineDetail for tripleQuote

// showContents - Swift file:
//  Fix namesColor for Types
//  Fix namesColor to include:  ClassNames, funcNames, InstanceVars, Globals, & library names (MK- for MapKit,  etc.)
//     e.g. NSColor, URL, false
//  User chooses colors & truncation

//AnalyseXcodeproj:
// View source
// Display in NSTable with links to AnalyseSwift & with option for printable.
// Show MainGroup.Children {Framework}
// Bug: "mainSourceKey = childKey", "Most likely child" may pick wrong child.
// Bug: AnalyseXcodeproj called twice on startup
// Align all issues using right-justified count.
// Align issues containing filename.swift
// Move project issues to top

// Fix Unhandled

//AnalyseSwift:
// Bug: Handle "var ee: Int=0, ff = 0, gg: Int" vs "var hh = kk.substring(start: 1, length:2)"
// Bug: Handle Raw String with multiple asterisks (***"..."*** )
// Bug: Continuation Line on let, var, etc
// BUG: CodeLineDetail: Do not change inMultiLine if change occurs after firstSplitter
// BUG: Trailing Comment Count
// BUG: Counts don't add up
// BUG: lineNum wrong - on continuation line, shows last lineNum of entire line.
// separate min/max len for func vs var
// computed variables, var observer
// show commentLinesCount(dead code?) vs MarkupLineCount (///) (/**)
// organize by MARK: or by extension
// allow extensions other than class - esp protocols & structs

//MenuRulesVC:
// Refresh analysis when user changes rules.
// Disable Save button until a change is made.
// Differentiate rules & sub-rules.
// Add "Reset Rules"

// More Issues to Flag:
//   Public func without markup
//   CodeLine too long
//   Missing Unit-Test
//   Type-Names must Start with Uppercase

// Need User-Selected Rules & AnalyseXcodeproj table columns & UnitTests for:
//  Free functions
//  Globals
//  Compound Lines

// WWDC:
//  mark "want" if on prefered list & don't "have"
//  show date/time in output.
//  show dounloaded videos that are no longer available online.
//  Allow Batch-analyse for year range.

/*
Public Structs
 AnalyseSwift
   3    lines @     34     Issue
  29    lines @     41     SwiftSummary
   5    lines @    102     BlockAggregate
   6    lines @    112     BlockInfo
  16    lines @    122     LineItem

 AnalyseXcodeproj
  22 lines @ 18     XcodeProj
  10 lines @ 44     PBXNativeTarget

 CodeLineDetail
 140 lines @ 17     CodeLineDetail

 MenuRulesVC
  37 lines @ 25     CodeRule                        for editing rules (includes userDefaults)

 PBX
 194 lines @ 17     PBX (CustomDebugStringConvertible)  for Xcodeproj

 StoredRules
  75 lines @ 41     StoredRule                      for AnalyseSwift

 WordLookup
  31 lines @ 11     WordLookup

*/


import Cocoa    /* partial-line Block Comment does work.*/
/* single-line Block Comment does work. */

/* To generate compiler warnings:
 #warning("This code is incomplete.")
*/

public enum DebugLevel {
    case errorOnly, warningAlso, all
}
public enum TraceLevel {
    case none, major, all
}
public let gDebug: DebugLevel = .warningAlso
public let gTrace: TraceLevel = .major

class ViewController: NSViewController, NSWindowDelegate {

    enum AnalyseMode {
        case /* embedded Block Comment now works.*/ none
        case WWDC
        case swift
        case xcodeproj
    }

    // MARK: - IBOutlets
    @IBOutlet weak var splitView:    NSSplitView!
    @IBOutlet weak var tableView:    NSTableView!
    @IBOutlet weak var infoTextView: NSTextView!
    @IBOutlet weak var saveInfoButton:          NSButton!
    @IBOutlet weak var moveUpButton:            NSButton!
    @IBOutlet weak var btnBack:                 NSButton!
    @IBOutlet weak var btnForward:              NSButton!
    @IBOutlet weak var readContentsButton:      NSButton!
    @IBOutlet weak var analyseContentsButton:   NSButton!
    @IBOutlet weak var btnFindAllxcodeproj:     NSButton!
    @IBOutlet weak var chkIssuesFirst:          NSButton!
    @IBOutlet weak var popupBaseDir:            NSPopUpButton!

    // MARK: - Properties
    let codeColor    = NSColor.black
    let commentColor = NSColor(calibratedRed: 0, green: 0.6, blue: 0.15, alpha: 1)  //Green
    let quoteColor   = NSColor.red
    let keywordColor = NSColor.blue
    let namesColor   = NSColor(calibratedRed: 43/256, green: 131/256, blue: 159/256, alpha: 1)  //BlueGreen
    //(43 131,159) ClassNames, funcNames, InstanceVars, Globals

    var filesList:[URL] = []                // selectedFolder{didSet}, toggleshowAllFiles, tableViewDoubleClicked, tableView stuff, etc
    var showAllFiles    = false             // toggleshowAllFiles, myContentsOf(folder: URL)

    var selecFileInfo = FileAttributes(url: nil, name: "???", creationDate: nil, modificationDate: nil, size: 0, isDir: false)

    var analyseFuncLocked = false           // because analyseSwiftFile() is not thread-safe
    var analyseMode = AnalyseMode.none      // .WWDC, .swift, or .xcodeproj
    var xcodeprojFileCount = 0

    var stackDirBackUrls = [URL?]()
    var stackDirForwardUrls = [URL?]()
    var xcodeprojURLs = [URL]()
    let baseURL = URL(fileURLWithPath: "~")

    // MARK: - Properties with didSet property observer
    var urlMismatch: URL? {
        didSet {
            let url = selectedItemUrl
            selectedItemUrl = nil           // Force a "didSet" for selectedItemUrl
            selectedItemUrl = url
        }
    }
    var selectedFolderUrl: URL? {
        didSet {                                        // run whenever selectedFolderUrl is changed FOLDER
            if let selectedFolderUrl = selectedFolderUrl {
                filesList = myContentsOf(folder: selectedFolderUrl, showAllFiles: showAllFiles)
                selectedItemUrl = nil
                self.tableView.reloadData()
                self.tableView.scrollRowToVisible(0)
                moveUpButton.isEnabled = true
                view.window?.title = selectedFolderUrl.path
            } else {
                moveUpButton.isEnabled = false
                view.window?.title = "Analyse Swift Code"
            }
        }
    }

    static var latestUrl: URL?          // Used by AnalyseSwift.swift as ViewController.latestUrl
    var selectedItemUrl: URL? {
        didSet {                                                // run whenever selectedItemUrl is changed
            ViewController.latestUrl = selectedItemUrl
            infoTextView.string = ""
            saveInfoButton.isEnabled = false
            guard let selectedUrl = selectedItemUrl else { return }
            selecFileInfo = FileAttributes.getFileInfo(url: selectedUrl)       // set selecFileInfo (name,dates,size,type)
            if selectedUrl.pathExtension == "swift" {
                analyseMode = .swift                            //  1) analyse Swift
                readContentsButton.isEnabled    = true
                analyseContentsButton.isEnabled = true
                if gTrace != .none {
                    print("🔷 ViewController #\(#line) selectedItemUrl is Swift File: \(selectedUrl.lastPathComponent)")
                }
                analyseContentsButtonClicked(self)

            } else if selectedUrl.lastPathComponent.hasPrefix("WWDC-20") && selectedUrl.pathExtension == "txt" {
                readContentsButton.isEnabled = true
                analyseMode = .WWDC                             //  2) analyse WWDC-20xx.txt
                analyseContentsButton.isEnabled = true
                if gTrace != .none {
                    print("🔷 ViewController #\(#line) selectedItemUrl is WWDC20xx.txt File: \(selectedUrl.lastPathComponent)")
                }
                analyseContentsButtonClicked(self)

            } else if selecFileInfo.isDir {                     // isDir
                if selectedUrl.pathExtension == "xcodeproj" {
                    analyseMode = .xcodeproj                    //  3) analyse FileName.xcodeproj
                    readContentsButton.isEnabled    = false
                    analyseContentsButton.isEnabled = true
                    if gTrace != .none {
                        print("🔷 ViewController #\(#line) selectedItemUrl is xcodeproj File: \(selectedUrl.lastPathComponent)")
                        }
                    analyseContentsButtonClicked(self)

                } else {                                        //  4) show dir contents
                    readContentsButton.isEnabled    = false
                    analyseContentsButton.isEnabled = false
                    let tempFilesList = myContentsOf(folder: selectedUrl, showAllFiles: showAllFiles)
                    var tempStr = ""
                    tempStr = " \(tempFilesList.count) \("item".pluralize(tempFilesList.count)) in folder."
                    let textAttributes = setFontSizeAttribute(size: 18)
                    let formattedText = NSMutableAttributedString(string: tempStr, attributes: textAttributes)
                    // --- Load infoTextView with formattedText ---
                    infoTextView.textStorage?.setAttributedString(formattedText)
                }
            } else {                                            //  5) show file attributes
                readContentsButton.isEnabled = true
                analyseMode = .none
                analyseContentsButton.isEnabled = false
                let infoString = infoAbout(url: selectedUrl)
                if !infoString.isEmpty {
                    let formattedText = formatWithHeader(infoString)
                    // --- Load infoTextView with formattedText ---
                    infoTextView.textStorage?.setAttributedString(formattedText)
                    saveInfoButton.isEnabled = true
                }
            }
        }//end didSet
    }//var selectedItemUrl

    // MARK: - Lifecycle

    override func viewDidLoad() {
        WordLookup.initKeyWords()
        WordLookup.initVBwords()
        popupBaseDir.removeAllItems()
        popupBaseDir.addItems(withTitles: ["Desktop","Downloads","Documents","All"])
        popupBaseDir.selectItem(at: 0)

        StoredRule.dictStoredRules = StoredRule.loadRules()
        CodeRule.getUserDefaults()

    }

    override func viewWillAppear() {
        super.viewWillAppear()
        splitView.setPosition(222.0, ofDividerAt: 0)
        restoreCurrentSelections()
        self.view.window?.delegate = self
        self.view.window?.setFrame(NSRect(x: 300, y: 70, width: 1100, height: 800), display: true)
        //self.view.window?.setContentSize(NSSize(width: 1000, height: 800))

        //myStr = UserDefaults.standard.object(forKey: “MyKey”) as? String ?? ""
        //UserDefaults.standard.set(myStr, forKey: “MyKey”)

    }

    override func viewDidAppear() {
        super.viewDidAppear()
//        let presOptions: NSApplication.PresentationOptions = ([.fullScreen,.autoHideMenuBar])
//        print(presOptions)
//        let optionsDictionary = [NSView.FullScreenModeOptionKey.fullScreenModeApplicationPresentationOptions : NSNumber(value: presOptions.rawValue)]
//        self.view.enterFullScreenMode(NSScreen.main!, withOptions:optionsDictionary)
//        self.view.wantsLayer = true
    }


    override func viewWillDisappear() {
        saveCurrentSelections()
        super.viewWillDisappear()
    }

    // Terminate application when this window closes - (needs to be delegate)
    func windowWillClose(_ notification: Notification) {
        NSApplication.shared.terminate(self)
    }

    // MARK: - Methods

    //TODO: Enhance showErrorDialogIn; use for all ⛔️
    func showErrorDialogIn(window: NSWindow, title: String, message: String) {
        let alert = NSAlert()
        alert.messageText       = title
        alert.informativeText   = message
        alert.alertStyle        = .critical
        alert.beginSheetModal(for: window, completionHandler: nil)
    }

    func showDialogIn(window: NSWindow, title: String, message: String, style: NSAlert.Style) {
        let alert = NSAlert()
        alert.messageText       = title
        alert.informativeText   = message
        alert.alertStyle        = style
        alert.beginSheetModal(for: window, completionHandler: nil)
    }

    // Recursive func to find .xcodeproj files & list them in Global var xcodprojURLs
    func findAllXcodeprojFiles(_ folder: URL) {
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: folder.path) // fileNames
            let urls = contents
                .filter({ return !$0.hasPrefix(".") })                      // filter out hidden
                .map { return folder.appendingPathComponent($0) }           // create array with full path

            for url in urls {
                if url.pathExtension == "xcodeproj" {
                    xcodeprojFileCount += 1
                    xcodeprojURLs.append((url))
                } else if url.hasDirectoryPath {

                    let truncPath = truncateURLforDisplay(url: url, maxLength: 80)
                    let str = "\(xcodeprojFileCount) Finding all .xcodeproj files in:\n\(truncPath)"
                    //let textAttributes = setFontSizeAttribute(size: 18)
                    //let formattedText = NSMutableAttributedString(string: tempStr, attributes: textAttributes)

                    DispatchQueue.main.async {
                        // --- Load infoTextView with formattedText ---
                        //self.infoTextView.textStorage?.setAttributedString(formattedText)
                        self.infoTextView.string = str
                    }

                    findAllXcodeprojFiles(url)                              // Recursive call
                }
            }
        }
        catch {
            //TODO: ⛔️ Handle Error
            print("⛔️ ViewController #\(#line): \(error) Error listing contents of \(folder)")
        }
    }


}//end class

// MARK: - Getting file or folder information
extension ViewController {

    // myContentsOf - returns a list of urls in folder, sorted folder/file, then alphabetically.
    func myContentsOf(folder: URL, showAllFiles: Bool) -> [URL] {
        let fileManager = FileManager.default

        do {
            let contents = try fileManager.contentsOfDirectory(atPath: folder.path) // fileNames

            let urls = contents
                .filter({ showAllFiles ? true : !$0.hasPrefix(".") })   // filter out hidden (or not)
                .map { folder.appendingPathComponent($0) }              // create array with full path

            var urlsFiltered = [URL]()
            if showAllFiles {
                urlsFiltered = urls
            } else {                                // if NOT showAllFiles: show only folders & swift files
                urlsFiltered = urls.filter({  $0.hasDirectoryPath || $0.pathExtension == "swift" || ($0.path.contains("WWDC") && $0.pathExtension == "txt" ) })
            }
            // .sort closure returns true when the first element passed should be ordered before the second
            //urlsFiltered.sort(by: { $0.path.lowercased() < $1.path.lowercased() })    // sort alphabetically
            //urlsFiltered.sort(by: { ($0.hasDirectoryPath && !$1.hasDirectoryPath)})   // sort folders 1st
            urlsFiltered.sort(by: { ($0.hasDirectoryPath && !$1.hasDirectoryPath) || (($0.hasDirectoryPath == $1.hasDirectoryPath) && ($0.path.lowercased() < $1.path.lowercased())) })
            return urlsFiltered

        } catch {
            return []
        }
    }

    // returns name, dates, size, type of url (file or folder) as a String
    func infoAbout(url: URL) -> String {
        let fileManager = FileManager.default
        var key: FileAttributeKey
        var value: Any

        do {
            let attributes = try fileManager.attributesOfItem(atPath: url.path)
            let name = url.lastPathComponent
            //var report = ["\(url.path)", ""]      // array: 1st items are path, blank
            var report = [name, ""]                 // array: 1st items are name, blank

            //key = FileAttributeKey(rawValue: "NSFileOwnerAccountName")

            key = FileAttributeKey(rawValue: "NSFileType")
            value = attributes[key] as? String ?? "????"
            report.append("\(key.rawValue):\t\(value)")

            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium       // Mar 26, 2017
            dateFormatter.timeStyle = .short        // 11:05 AM

            key = FileAttributeKey(rawValue: "NSFileCreationDate")
            let date1 = attributes[key] as? Date ?? Date.distantPast
            report.append("\(key.rawValue):\t\(dateFormatter.string(from: date1))")

            key = FileAttributeKey(rawValue: "NSFileModificationDate")
            let date2 = attributes[key] as? Date ?? Date.distantPast
            report.append("\(key.rawValue):\t\(dateFormatter.string(from: date2))")

            key = FileAttributeKey(rawValue: "NSFileSize")
            value = attributes[key] as? Int ?? "????"
            report.append("\(key.rawValue):\t\(value)")

            return report.joined(separator: "\n")

        } catch {
            return "No information available on \(url.path)"
        }
    }

    // MARK: - @IBActions

    // Find all ".xcodeproj" files & display them in infoTextView
    @IBAction func btnFindAllXcodeprojClicked(_ sender: Any) {
        var baseDir = FileManager.SearchPathDirectory.userDirectory
        switch popupBaseDir.title {
        case "Desktop":
            baseDir = .desktopDirectory
        case "Downloads":
            baseDir = .downloadsDirectory
        case "Documents":
            baseDir = .documentDirectory
        default:
            break
        }

        let baseFolderURL: URL
        let baseFolderName: String
        if popupBaseDir.title == "All" {
            baseFolderURL = FileManager.default.homeDirectoryForCurrentUser
            baseFolderName = baseFolderURL.lastPathComponent    // short name of that folder
        } else {
            let baseFolderURLs = FileManager.default.urls(for: baseDir, in: .userDomainMask)        // Desktop
            baseFolderURL  = baseFolderURLs[0]                  // URL of folder to search (and its subfolders)
            baseFolderName = baseFolderURL.lastPathComponent    // short name of that folder
        }

        let str = "Reading through Folders ..."
        var textAttributes = setFontSizeAttribute(size: 12)
        var formattedText = NSMutableAttributedString(string: str, attributes: textAttributes)
        // --- Load infoTextView with formattedText ---
        infoTextView.textStorage?.setAttributedString(formattedText)

        xcodeprojURLs = [URL]()

        DispatchQueue.global(qos: .userInitiated).async {

            self.xcodeprojFileCount = 0
            // Recursive func finds .xcodeproj files & lists them in xcodprojURLs
            self.findAllXcodeprojFiles(baseFolderURL)

            let str = "Now reading through the .xcodeproj files."
            DispatchQueue.main.async {
                self.infoTextView.string = str
            }
            let xcodeprojCount = self.xcodeprojURLs.count
            var tempStr = "ViewController #\(#line) \(xcodeprojCount) xcodeproj files found under \(baseFolderName) \(Date().ToString("MM/dd/yyyy HH:mm"))\n\n"
            print(tempStr)

            var dictVersions   = [String:Int]()
            var printablePaths = [String]()

            for (i,url) in self.xcodeprojURLs.enumerated() {
                let str = "Reading \(i) of \(xcodeprojCount) \(url.lastPathComponent)"
                DispatchQueue.main.async {
                    self.infoTextView.string = str
                }
                let (errCode, xcodeProj) = analyseXcodeproj(url:url, goDeep: false, deBug: false)
                if errCode.isEmpty {
                    let verStr = xcodeProj.swiftVerMin == 0 ? "2.x" : String(format: "%.1f", xcodeProj.swiftVerMin)
                    let barePath = url.deletingPathExtension().path
                    var comps = barePath.components(separatedBy: "/")
                    comps.removeFirst(3)                                // Remove: "", "Users", "george"
                    let pathName = comps.joined(separator: "/")
                    let verPath = verStr + " " + pathName
                    printablePaths.append(verPath)

                    if let dictVerCount = dictVersions[verStr] {
                        dictVersions[verStr] = dictVerCount + 1
                    } else {
                        dictVersions[verStr] = 1
                    }
                } else {
                    //TODO: Add Error logging for batch mode
                }//endif has errorCode
            }//next url

            // List the Swift Versions found in version-order, with counts
            tempStr += "Swift  Count\n"
            let sortedVersions = dictVersions.sorted {$0.key < $1.key}
            tempStr = sortedVersions.reduce(tempStr,{ $0 + "\($1.0):      \($1.1)\n" })
            // for (key,val) in sortedVersions { tempStr += "\(key):      \(val)\n" }  // alternative method using loop

            //printablePaths.sort { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
            printablePaths.sort { $0.caseInsensitiveCompare($1) == .orderedAscending }
            var prevPrefix = ""
            for str in printablePaths {
                if str.prefix(3) != prevPrefix {
                    prevPrefix = String(str.prefix(3))
                    tempStr += "\n"                         // add a blank line
                }
                tempStr += str + "\n"                       // append this line
            }//next str

            textAttributes = self.setFontSizeAttribute(size: 14)
            formattedText = NSMutableAttributedString(string: tempStr, attributes: textAttributes)
            DispatchQueue.main.async {
                // --- Load infoTextView with formattedText ---
                self.infoTextView.textStorage?.setAttributedString(formattedText)
            }
        }//end DispatchQueue.global

    }//end func btnFindAllXcodeprojClicked

    //---- selectFolderClicked - User clicked on "Select Folder" button (brings up FileOpenDialog)
    @IBAction func selectFolderClicked(_ sender: Any) {
        guard let window = view.window else { return }

        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false

        panel.beginSheetModal(for: window) { (result) in
            if result.rawValue == NSFileHandlingPanelOKButton {
                //clearForwardStack, pushBackStack
                self.pushDirBackStack()
                self.selectedFolderUrl = panel.urls[0]
                //print(self.selectedFolderUrl)
            }
        }
    }//end func

    //---- truncateURLforDisplay - make a String showing URL, but fitting within maxLength - Tested
    func truncateURLforDisplay(url: URL, maxLength: Int) -> String {
        let fileName = url.lastPathComponent
        let barePath = url.path     // url.deletingPathExtension().path
        var comps = barePath.components(separatedBy: "/")
        comps.removeFirst(3)                                // Remove: "", "Users", "george"
        var pathName = comps.joined(separator: "/")
        if pathName.count > maxLength {
            pathName = ""
            for comp in comps {
                if pathName.count + comp.count + fileName.count + 2 > maxLength { break }
                if !pathName.isEmpty { pathName += "/" }
                pathName += comp
            }
            pathName += "/.../" + fileName
        }
        return pathName
    }

    // user clicked on ShowAllFiles button
    @IBAction func toggleshowAllFiles(_ sender: NSButton) {
        showAllFiles = (sender.state == .on)
        if let selectedFolderUrl = selectedFolderUrl {
            filesList = myContentsOf(folder: selectedFolderUrl, showAllFiles: showAllFiles)
            //selectedItemUrl = nil
            tableView.reloadData()
        }
    }//end func

    // user DoubleClicked on file/dir in tableView, so show contents
    @IBAction func tableViewDoubleClicked(_ sender: Any) {
        if tableView.selectedRow < 0 { return }

        let selectedItem = filesList[tableView.selectedRow]

        if selectedItem.hasDirectoryPath && selectedItem.pathExtension != "xcodeproj"  {
            //clearForwardStack, pushBackStack
            self.pushDirBackStack()
            selectedFolderUrl = selectedItem
        } else {
            //showFileContents(url: selectedItem)
        }
    }//end func

    func pushDirBackStack() {
        //clearForwardStack, pushBackStack
        self.stackDirForwardUrls = []
        self.stackDirBackUrls.append(self.selectedFolderUrl)
        self.btnBack.isEnabled = true
    }

    func popDirBackStack() -> URL? {
        if !self.stackDirBackUrls.isEmpty {
            let url = self.stackDirBackUrls.removeLast()
            self.stackDirForwardUrls.append(self.selectedFolderUrl)
            self.btnForward.isEnabled = true
            if self.stackDirBackUrls.isEmpty {
                self.btnBack.isEnabled = false
            }
            return url
        }
        return nil
    }

    func popDirForwardStack() -> URL? {
        if !self.stackDirForwardUrls.isEmpty {
            let url = self.stackDirForwardUrls.removeLast()
            self.stackDirBackUrls.append(self.selectedFolderUrl)
            self.btnBack.isEnabled = true
            if self.stackDirForwardUrls.isEmpty {
                self.btnForward.isEnabled = false
            }
            return url
        }
        return nil
    }

    @IBAction func btnBackClicked( _ sender: Any) {
        //print("ViewController #\(#line) Back Button Clicked")
        self.selectedFolderUrl = popDirBackStack()
    }

     @IBAction func btnForwardClicked( _ sender: Any) {
     //print("ViewController #\(#line) Forward Button Clicked")
        self.selectedFolderUrl = popDirForwardStack()
     }

    // user clicked on UpOneLevel button, so select parent
    @IBAction func moveUpClicked(_ sender: Any) {
        if selectedFolderUrl?.path == "/" { return }
        //clearForwardStack, pushBackStack
        self.pushDirBackStack()
        selectedFolderUrl = selectedFolderUrl?.deletingLastPathComponent()
    }

     @IBAction func chkIssuesFirstClicked(_ sender: Any) {
        //TODO: Add logic to reload analysis
        let url = selectedItemUrl
        selectedItemUrl = nil           // Force a "didSet" for selectedItemUrl
        selectedItemUrl = url
     }

    // saveInfo Clicked
    @IBAction func saveInfoClicked(_ sender: Any) {
//        test()
//        return
        // Make sure we have a view.window and a selectedItemUrl
        guard let window = view.window else { return }
        guard let selectedItemUrl = selectedItemUrl else { return }

        // Create an NSSavePanel
        let panel = NSSavePanel()
        // Set directoryURL to home Directory
        panel.directoryURL = FileManager.default.homeDirectoryForCurrentUser
        // Set default name of file to write to: "*.fs.txt"
        panel.nameFieldStringValue = selectedItemUrl
            .deletingPathExtension()
            .appendingPathExtension("fs.txt")
            .lastPathComponent

        // Show SavePanel & wait in a closure until user finishes
        panel.beginSheetModal(for: window) { (result) in
            if result.rawValue == NSFileHandlingPanelOKButton,
                let url = panel.url {
                // get the file information and write it to the selected file.
                do {
                    let infoAsText = self.infoAbout(url: selectedItemUrl)
                    try infoAsText.write(to: url, atomically: true, encoding: .utf8)
                } catch {
                    self.showErrorDialogIn(window: window, title: "Unable to save file", message: error.localizedDescription)
                }//end do
            }//endif
        }//end closure
    }//end func saveInfoClicked

    @IBAction func readContentsButtonClicked(_ sender: Any) {
        if let selectedItemUrl = selectedItemUrl {
            showFileContents(url: selectedItemUrl)
        }
    }//end func

    @IBAction func analyseContentsButtonClicked(_ sender: Any) {
        if let url = selectedItemUrl {
            if analyseMode == .swift || analyseMode == .WWDC {
                do {
                    // Read file content
                    let contentFromFile = try String(contentsOf: url, encoding: String.Encoding.utf8)

                    if analyseFuncLocked { return }                  // because analyseSwiftFile() is not thread-save
                    analyseFuncLocked = true                         // Lock the button
                    analyseContentsButton.isEnabled = false
                    let issuesFirst = self.chkIssuesFirst.state == .on
                    infoTextView.string = "Analysing..."
                    DispatchQueue.global(qos: .userInitiated).async {
                        var txt: NSAttributedString
                        if  self.analyseMode == .swift {
                            //var swiftSummary = SwiftSummary()
                            let swiftSummary = analyseSwiftFile(contentFromFile: contentFromFile, selecFileInfo: self.selecFileInfo, deBug: true )
                            let attStr = SwiftSumAttStr(swiftSummary: swiftSummary, fileInfo: self.selecFileInfo, issuesFirst: issuesFirst)
                            txt = attStr.completeAttText
                        } else if self.analyseMode == .WWDC {
                            var msg = ""
                            (txt, msg) = analyseWWDC(contentFromFile, selecFileInfo: self.selecFileInfo)
                            if !msg.isEmpty {
                                DispatchQueue.main.async {
                                    if let window = self.view.window {
                                        let comps = msg.components(separatedBy: "|")
                                        let title: String
                                        let message: String
                                        if comps.count >= 2 {
                                            title = comps[0]
                                            message = comps[1]
                                        } else {
                                            title = "Complete"
                                            message = msg
                                        }
                                        self.showDialogIn(window: window, title: title, message: message, style: .informational)
                                    }
                                }
                            }
                        } else {
                            txt = NSAttributedString()
                        }
                        DispatchQueue.main.async {
                            // --- Load infoTextView with formattedText ---
                            self.infoTextView.textStorage?.setAttributedString(txt) // Show txt in infoTextView
                            self.analyseFuncLocked = false                          // Unlock the button
                            self.analyseContentsButton.isEnabled = true             // and Enable it.
                            if url != self.selectedItemUrl {
                                self.urlMismatch = self.selectedItemUrl
                            }
                        }//end DispatchQueue.main
                    }//end DispatchQueue.global

                }//end do/try

                catch let error as NSError {
                    print("😡 ViewController #\(#line): analyseContentsButtonClicked error: \(error)")
                }//end try catch

            } else if analyseMode == .xcodeproj {
                let (errCode, xcodeProj) = analyseXcodeproj(url:url, goDeep: true, deBug: false)
                let formattedText: NSAttributedString
                if errCode.isEmpty {
                    formattedText = showXcodeproj(xcodeProj)
                } else {
                    formattedText = NSAttributedString(string: errCode)
                }
                // --- Load infoTextView with formattedText ---
                self.infoTextView.textStorage?.setAttributedString(formattedText)
            }//endif analyseMode

        }//end if let
    }//end func analyseContentsButtonClicked

}//end class

// MARK: - NSTableViewDataSource
extension ViewController: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return filesList.count
    }//end func

}//end extension

// MARK: - NSTableViewDelegate
extension ViewController: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView,
                   viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let item = filesList[row]

        let fileIcon = NSWorkspace.shared.icon(forFile: item.path)

        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "FileCell"), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = item.lastPathComponent
            cell.imageView?.image = fileIcon
            return cell
        }
        return nil
    }//end func

    func tableViewSelectionDidChange(_ notification: Notification) {
        if tableView.selectedRow < 0 {
            selectedItemUrl = nil
            return
        }
        selectedItemUrl = filesList[tableView.selectedRow]
    }//end func

}//end extension

// MARK: - Save & Restore previous selection
extension ViewController {

    // called from viewWillDisappear
    func saveCurrentSelections() {
        guard let dataFileUrl = urlForDataStorage() else { return }

        let parentForStorage = selectedFolderUrl?.path ?? ""
        let fileForStorage = selectedItemUrl?.path ?? ""
        let issuesFirstTxt = chkIssuesFirst.state == .on ? "true" : "false"
        let completeData = "\(parentForStorage)\n\(fileForStorage)\n\(issuesFirstTxt)\n"

        try? completeData.write(to: dataFileUrl, atomically: true, encoding: .utf8)
    }//end func

    // called from viewWillAppear - ???? Change to UserDefaults?
    func restoreCurrentSelections() {
        guard let dataFileUrl = urlForDataStorage() else {
            print("😡 ViewController #\(#line): No dataFileUrl!")
            return
        }

        do {
            let storedData = try String(contentsOf: dataFileUrl)
            let storedDataComponents = storedData.components(separatedBy: .newlines)
            if storedDataComponents.count >= 2 {

                if storedDataComponents.count >= 3 {
                    if storedDataComponents[2] == "true" {
                        chkIssuesFirst.state = .on
                    } else {
                        chkIssuesFirst.state = .off
                    }
                }//endif >=3

                if !storedDataComponents[0].isEmpty {
                    selectedFolderUrl = URL(fileURLWithPath: storedDataComponents[0])
                    if !storedDataComponents[1].isEmpty {
                        selectedItemUrl = URL(fileURLWithPath: storedDataComponents[1])
                        selectUrlInTable(selectedItemUrl)
                    }
                }
            }//endif >=2
        } catch {
            print("😡 ViewController #\(#line): restoreCurrentSelections error: \(error)")
        }
    }//end func

    // Helper for restoreCurrentSelections
    private func selectUrlInTable(_ url: URL?) {
        guard let url = url else { tableView.deselectAll(nil); return }

        if let rowNumber = filesList.firstIndex(of: url) {
            let indexSet = IndexSet(integer: rowNumber)
            DispatchQueue.main.async {
                self.tableView.selectRowIndexes(indexSet, byExtendingSelection: false)
            }
        }
    }//end func selectUrlInTable

    // returns URL from ".../Application Support/AnalyseSwiftCode/StoredState.txt".
    // Called from saveCurrentSelections, restoreCurrentSelections
    private func urlForDataStorage() -> URL? {
        let fileManager = FileManager.default

        // The FileManager class has a method that returns a list of appropriate URLs with specific uses.
        // In this case, you are seeking the applicationSupportDirectory in the current user's directory.
        // It is unlikely to return more than one URL, but you only want to take the first one.
        // You can use this method with different parameters to locate many different folders.
        guard let folder = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else { return nil }
        print("\n\n✅ ViewController #\(#line): dataFileUrl = \(folder.path)")
        // append a path component to create an app-specific folder URL and check to see if it exists.
        let appFolder = folder.appendingPathComponent("AnalyseSwiftCode")
        var isDirectory: ObjCBool = false
        let folderExists = fileManager.fileExists(atPath: appFolder.path, isDirectory: &isDirectory)
        if !folderExists || !isDirectory.boolValue {
            do {
                // If folder doesn't exist, try to create it and & intermediate folders along path, return nil if it fails.
                try fileManager.createDirectory(at: appFolder, withIntermediateDirectories: true, attributes: nil)
            } catch {
                return nil
            }
        }

        // Append another path component to create the full URL of the data file and return that.
        let dataFileUrl = appFolder.appendingPathComponent("StoredState.txt")
        return dataFileUrl
    }//end func urlForDataStorage

}//end extension ViewController

// MARK: - Read file (GWB).
extension ViewController {

    // read contents of file & display them in infoTextView
    func showFileContents(url: URL) {
        var showLineNumbers = false
        //var isSwiftSource   = false

        if url.pathExtension == "swift" {
            showLineNumbers = true
            //isSwiftSource   = true
        }
        if url.lastPathComponent.hasPrefix("WWDC-20") && url.pathExtension == "txt" {
            showLineNumbers = true
        }
        do {
            let formattedText = NSMutableAttributedString()
            // Read file content & populate "lines"
            let contentFromFile = try String(contentsOf: url, encoding: String.Encoding.utf8)
            let lines = contentFromFile.components(separatedBy: "\n")

            if showLineNumbers {
                var formattedLine: NSAttributedString
                var inBlockComment = false
                var inTripleQuote  = false
                var curlyDepth = 0
                for (i, line) in lines.enumerated() {
                    formattedLine = formatSwiftLine(lineNumber: i+1, text: line, inBlockComment: &inBlockComment, inTripleQuote: &inTripleQuote, curlyDepth: &curlyDepth)
                    formattedText.append(formattedLine)
                }//next line

                // --- Load infoTextView with formattedText ---
                infoTextView.textStorage?.setAttributedString(formattedText)

            } else {
                // Show raw text as read
                guard let formattedText = formatWithHeader(contentFromFile) as? NSMutableAttributedString else {
                    print("😡 ViewController #\(#line): Could not format read text")
                    return
                }
                // --- Load infoTextView with formattedText ---
                infoTextView.textStorage?.setAttributedString(formattedText)
            }
        }//end do
        catch let error as NSError {
            let err = "😡 ViewController #\(#line): showFileContents error: \(error.localizedDescription)"
            print(err)
            let str = "\(selecFileInfo.name)\n\n'View' only works in text-based files."
            let formattedText = formatWithHeader(str)
            // --- Load infoTextView with formattedText ---
            infoTextView.textStorage?.setAttributedString(formattedText)
        }//end catch

    }//end func showFileContents

    func sampleCodeTest() {
        let str = "a👿b🇩🇪c"
        let range1 = str.range(of: "b🇩🇪")!
        print(str[range1])                                  // b🇩🇪

        // String range to NSRange:
        let nsRange = NSRange(range1, in: str)
        print((str as NSString).substring(with: nsRange))   // b🇩🇪

        // NSRange back to String range:
        let range2 = Range(nsRange, in: str)!
        print(str[range2])                                  // b🇩🇪

        let codeLines = [
                        "  This is a code line // With a trailing comment",
                        "  This is a /*embedded block comment*/ more code",
                        "  // This is a Comment Line",
                        "       // This is a Comment Line",
                        "  This is 2nd code line",
                        "  /*  Start Block  ",
                        "  Block Comment Line#1",
                        "  Block Comment Line#2",
                        "  */"  ,
                        "  This is 3rd code line",
                        "  /* Block Comment whole line */  ",
                        "  This is 4th code line",
        ]

        let combined = NSMutableAttributedString()

        var inTripleQuote = false
        var inBlockComment = false
        for codeLine in codeLines {
            combined.append(formatCodeLine(codeLine: codeLine, inTripleQuote: &inTripleQuote, inBlockComment: &inBlockComment))
        }

        // --- Load infoTextView with formattedText ---
        infoTextView.textStorage?.setAttributedString(combined)
        var xxx =
        """
        1st triple quote
        """
        xxx = """
        2nd triple quote
        """
        xxx =
        """
        3rd triple quote
        with more tha 1 line
        """
        print(xxx)
    }//end func test

}//end Extension
