//
//  ViewController.swift
//  AnalyseSwiftCode
//
//  Created by George Bauer on 11/8/18.
//  Copyright © 2018,2019 George Bauer. All rights reserved.
//

// User Interface:
// Make ">" companion to "< Up" or maybe a "< back"
// When in full screen mode - Show file-path above window
// make btnFindAllxcodeproj the default if popup touched.
// toggle btnFindAllxcodeproj to "Abort" when running, (and disable other buttons).
// selectively enable View & Analyse buttons or use segmented button.
// Use Menus: File/Find_All_xcodeproj_Files
// Help System
// Error Handler
// Single Click for analyse & change dir - no double Click
// if newly opened folder has a single xcodeproj: analyse it

// Code:
// change state storage to userDefaults

// showContents - Swift file:
//  Fix namesColor to include:  classNames, funcNames, InstanceVars, Globals, & library names (MK- for MapKit,  etc.)
//     e.g. NSColor, URL, false
//  User chooses colors & truncation

//AnalyseXcodeproj:
// View source
// Display in NSTable with links to AnalyseSwift & with option for printable.
// Show MainGroup.Children {Framework}
// Bug: "mainSourceKey = childKey", "Most likely child" may pick wrong child.
// Bug: AnalyseXcodeproj called twice on startup

// Fix Unhandled

//AnalyseSwift:
// Bug: Handle "var ee: Int=0, ff = 0, gg: Int" vs "var hh = kk.substring(start: 1, length:2)"
// Handle String interpolation
// dependency
// computed variables, var observer
// show commentLinesCount(dead code?) vs MarkupLineCount (///) (/**)
// organize by MARK: or by extension
// allow extensions other than class
// Display as expandable tree, with option for printable
// remove display code (tx=, txt=, etc.) from analyseSwiftFile()

//MenuRulesVC:
// Refresh analysis when user changes rules
// Change MenuRulesVC to use a TableView
// Bug: textfield not triggering "Change" when Save button clicked
// More Issues to Flag:
//   Global vars, singletons (dependency injection?)
//   Free functions vs methods
//   Var name too short or too long
//   //TODO: //FIXME:
//   Multiple declarations on a line
//   CodeLine too long
//   Missing Unit-Test
//   Type-Names must Start with Uppercase

//Done:

import Cocoa    /* partial-line Block Comment does work.*/
/* single-line Block Comment does work. */

/* To generate compiler warnings:
 #warning("This code is incomplete.")
*/
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
    @IBOutlet weak var readContentsButton:      NSButton!
    @IBOutlet weak var analyseContentsButton:   NSButton!
    @IBOutlet weak var btnFindAllxcodeproj:     NSButton!
    @IBOutlet weak var popupBaseDir:            NSPopUpButton!

    // MARK: - Properties
    let codeColor    = NSColor.black
    let commentColor = NSColor(calibratedRed: 0, green: 0.6, blue: 0.15, alpha: 1)  //Green
    let quoteColor   = NSColor.red
    let keywordColor = NSColor.blue
    let namesColor   = NSColor(calibratedRed: 43/256, green: 131/256, blue: 159/256, alpha: 1)  //BlueGreen
    //(43 131,159) classNames, funcNames, InstanceVars, Globals

    var filesList:[URL] = []                // selectedFolder{didSet}, toggleshowAllFiles, tableViewDoubleClicked, tableView stuff, etc
    var showAllFiles    = false             // toggleshowAllFiles, myContentsOf(folder: URL)

    var selecFileInfo = FileAttributes(url: nil, name: "???", creationDate: nil, modificationDate: nil, size: 0, isDir: false)

    var analyseFuncLocked = false           // because analyseSwiftFile() is not thread-safe
    var analyseMode = AnalyseMode.none      // .WWDC, .swift, or .xcodeproj
    var xcodeprojFileCount = 0

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
                filesList = myContentsOf(folder: selectedFolderUrl)
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
                print("🔷 ViewController #\(#line) selectedItemUrl is Swift File: \(selectedUrl.lastPathComponent)")
                analyseContentsButtonClicked(self)

            } else if selectedUrl.lastPathComponent.hasPrefix("WWDC-20") && selectedUrl.pathExtension == "txt" {
                readContentsButton.isEnabled = true
                analyseMode = .WWDC                             //  2) analyse WWDC-20xx.txt
                analyseContentsButton.isEnabled = true
                print("🔷 ViewController #\(#line) selectedItemUrl is WWDC20xx.txt File: \(selectedUrl.lastPathComponent)")

            } else if selecFileInfo.isDir {                     // isDir
                if selectedUrl.pathExtension == "xcodeproj" {
                    readContentsButton.isEnabled = false
                    analyseMode = .xcodeproj                    //  3) analyse FileName.xcodeproj
                    analyseContentsButton.isEnabled = true
                    print("🔷 ViewController #\(#line) selectedItemUrl is xcodeproj File: \(selectedUrl.lastPathComponent)")
                    analyseContentsButtonClicked(self)

                } else {                                        //  4) show dir contents
                    readContentsButton.isEnabled = false
                    analyseContentsButton.isEnabled = false
                    let tempFilesList = myContentsOf(folder: selectedUrl)
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
        popupBaseDir.removeAllItems()
        popupBaseDir.addItems(withTitles: ["Desktop","Downloads","Documents","All"])
        popupBaseDir.selectItem(at: 0)

        CodeRule.getUserDefaults()
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        splitView.setPosition(222.0, ofDividerAt: 0)
        restoreCurrentSelections()
        self.view.window?.delegate = self
        self.view.window?.setFrame(NSRect(x: 300, y: 70, width: 900, height: 800), display: true)
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

    // Recursive func to find .xcodeproj files & list them in Global var xcodprojURLs
    public func findAllXcodeprojFiles(_ folder: URL) {
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
            print("⛔️ #\(#line):\(error) Error listing contents of \(folder)")
        }
    }


}//end class

// MARK: - Getting file or folder information
extension ViewController {

    // myContentsOf - returns a list of urls in folder, sorted folder/file, then alphabetically
    func myContentsOf(folder: URL) -> [URL] {
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
            var tempStr = "\(xcodeprojCount) xcodeproj files found under \(baseFolderName) \(Date().ToString("MM/dd/yyyy HH:mm"))\n\n"
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
            filesList = myContentsOf(folder: selectedFolderUrl)
            //selectedItemUrl = nil
            tableView.reloadData()
        }
    }//end func

    // user DoubleClicked on file/dir in tableView, so show contents
    @IBAction func tableViewDoubleClicked(_ sender: Any) {
        if tableView.selectedRow < 0 { return }

        let selectedItem = filesList[tableView.selectedRow]

        if selectedItem.hasDirectoryPath {
            selectedFolderUrl = selectedItem
        } else {
            //showFileContents(url: selectedItem)
        }
    }//end func

    // user clicked on UpOneLevel button, so select parent
    @IBAction func moveUpClicked(_ sender: Any) {
        if selectedFolderUrl?.path == "/" { return }
        selectedFolderUrl = selectedFolderUrl?.deletingLastPathComponent()
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
                    infoTextView.string = "Analysing..."
                    DispatchQueue.global(qos: .userInitiated).async {
                        var txt: NSAttributedString
                        if  self.analyseMode == .swift {
                            //var swiftSummary = SwiftSummary()
                            let swiftSummary = analyseSwiftFile(contentFromFile: contentFromFile, selecFileInfo: self.selecFileInfo, deBug: true )
                            txt = formatSwiftSummary(swiftSummary: swiftSummary, selecFileInfo: self.selecFileInfo, deBug: true)
                        } else if self.analyseMode == .WWDC {
                            txt = analyseWWDC(contentFromFile, selecFileInfo: self.selecFileInfo)
                        } else {
                            txt = NSAttributedString()
                        }
                        DispatchQueue.main.async {
                            // --- Load infoTextView with formattedText ---
                            self.infoTextView.textStorage?.setAttributedString(txt) // Show txt in infoTextView
                            self.analyseFuncLocked = false                          // Unlock the button...
                            self.analyseContentsButton.isEnabled = true             // and Enable it.
                            if url != self.selectedItemUrl {
                                self.urlMismatch = self.selectedItemUrl
                            }
                        }//end DispatchQueue.main
                    }//end DispatchQueue.global

                }//end try do

                catch let error as NSError {
                    print("😡 #\(#line): analyseContentsButtonClicked error: \(error)")
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
        let completeData = "\(parentForStorage)\n\(fileForStorage)\n"

        try? completeData.write(to: dataFileUrl, atomically: true, encoding: .utf8)
    }//end func

    // called from viewWillAppear - ???? Change to UserDefaults?
    func restoreCurrentSelections() {
        guard let dataFileUrl = urlForDataStorage() else {
            print("😡 #\(#line): No dataFileUrl!")
            return
        }

        do {
            let storedData = try String(contentsOf: dataFileUrl)
            let storedDataComponents = storedData.components(separatedBy: .newlines)
            if storedDataComponents.count >= 2 {
                if !storedDataComponents[0].isEmpty {
                    selectedFolderUrl = URL(fileURLWithPath: storedDataComponents[0])
                    if !storedDataComponents[1].isEmpty {
                        selectedItemUrl = URL(fileURLWithPath: storedDataComponents[1])
                        selectUrlInTable(selectedItemUrl)
                    }
                }
            }
        } catch {
            print("😡 #\(#line): restoreCurrentSelections error: \(error)")
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
                    print(" #\(#line): Could not format read text")
                    return
                }
                // --- Load infoTextView with formattedText ---
                infoTextView.textStorage?.setAttributedString(formattedText)
            }
        }//end do
        catch let error as NSError {
            let err = "😡 #\(#line): showFileContents error: \(error.localizedDescription)"
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
        """
        print(xxx)
    }//end func test

}//end Extension
