/**
 * Copyright (c) 2018 George Bauer
 *
 */

// make ">" companion to "< Up"
// when in full screen mode - Show file-path above window
// remember state of "ShowAll" checkbox between runs 
// for folders:     show subDirs & Swift files(w/size)
// showContents: colors & truncation in swift file
// Aggregate all swift file data in selected dir  "*.xcodeproj/project.pbxproj"
// recursivly find all file of type .swift or .xcodeproj
// change state storage to userDefaults

// Change View/Analyse buttons to segmented button

// analyse:
// inTripleQuote """
// dependency
// computed variables, var observer
// analysis: show func params
// analysis: show global vars, instance vars
// analysis: organize by MARK: or by extension
// selectively enable View & Analyse buttons
// show methods vs free functions
// allow for extensions other than class

// fixed color of multiline comments

import Cocoa

//#warning("This code is incomplete.")

class ViewController: NSViewController {

    enum AnalyseMode {
        case none
        case WWDC
        case swift
        case xcodeproj
    }

    // MARK: - Outlets
    
    @IBOutlet weak var splitView:    NSSplitView!
    @IBOutlet weak var tableView:    NSTableView!
    @IBOutlet weak var infoTextView: NSTextView!
    @IBOutlet weak var saveInfoButton:          NSButton!
    @IBOutlet weak var moveUpButton:            NSButton!
    @IBOutlet weak var readContentsButton:      NSButton!
    @IBOutlet weak var analyseContentsButton:   NSButton!

    // MARK: - Properties
    var filesList:[URL] = []                    // selectedFolder{didSet}, toggleshowAllFiles, tableViewDoubleClicked, tableView stuff, etc
    var showAllFiles    = false                 // toggleshowAllFiles, myContentsOf(folder: URL)

    var selecFileInfo = FileAttributes(url: nil, name: "???", creationDate: nil, modificationDate: nil, size: 0, isDir: false)

    var analyseFuncLocked = false               // because analyseSwiftFile() is not thread-safe
    var displayedAnalysisUrl: URL?
    var analyseMode = AnalyseMode.none

    // MARK: - Properties with didSet property observer
    var urlMismatch: URL? {
        didSet {
            let t = selectedItemUrl
            selectedItemUrl = nil
            selectedItemUrl = t
        }
    }
    var selectedFolderUrl: URL? {
        didSet {                                                // run whenever selectedFolderUrl is changed FOLDER
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

    static var latestUrl: URL?      // Used by AnalyseSwift.swift as ViewController.latestUrl
    var selectedItemUrl: URL? {
        didSet {                                                // run whenever selectedItemUrl is changed ITEM
            ViewController.latestUrl = selectedItemUrl
            infoTextView.string = ""
            saveInfoButton.isEnabled = false
            guard let selectedUrl = selectedItemUrl else { return }
            selecFileInfo = setFileInfo(url: selectedUrl)       // set selecFileInfo (name,dates,size,type)
            if selectedUrl.pathExtension == "swift" {           //  1) analyse Swift
                readContentsButton.isEnabled = true
                analyseMode = .swift
                analyseContentsButton.isEnabled = true
                print("🔷 selectedItemUrl is Swift File: \(selectedUrl.lastPathComponent)")
                analyseContentsButtonClicked(self)

            } else if selectedUrl.lastPathComponent.hasPrefix("WWDC-20") && selectedUrl.pathExtension == "txt" {
                readContentsButton.isEnabled = true
                analyseMode = .WWDC                             //  2) analyse WWDC-20xx.txt
                analyseContentsButton.isEnabled = true
                print("🔷 selectedItemUrl is WWDC20xx.txt File: \(selectedUrl.lastPathComponent)")

            } else if selecFileInfo.isDir {                     // isDir
                if selectedUrl.pathExtension == "xcodeproj" {
                    readContentsButton.isEnabled = false
                    analyseMode = .xcodeproj                    //  3) analyse FileName.xcodeproj
                    analyseContentsButton.isEnabled = true
                    print("🔷 selectedItemUrl is xcodeproj File: \(selectedUrl.lastPathComponent)")
                    analyseContentsButtonClicked(self)

                } else {                                        //  4) show dir contents
                    readContentsButton.isEnabled = false
                    analyseContentsButton.isEnabled = false
                    let tempFilesList = myContentsOf(folder: selectedUrl)
                    var tempStr = ""
                    tempStr = " \(tempFilesList.count) \("item".pluralize(tempFilesList.count)) in folder."
//                    for file in tempFilesList {
//                        tempStr += "\(file.lastPathComponent)\n"
//                    }
                    let textAttributes: [NSAttributedStringKey: Any] = [
                        NSAttributedStringKey.font: NSFont.systemFont(ofSize: 18),
                        NSAttributedStringKey.paragraphStyle: NSParagraphStyle.default
                    ]
                    let formattedText = NSMutableAttributedString(string: tempStr, attributes: textAttributes)

                    infoTextView.textStorage?.setAttributedString(formattedText)
                }
            } else {                                            //  5) show file attributes
                readContentsButton.isEnabled = true
                analyseMode = .none
                analyseContentsButton.isEnabled = false
                let infoString = infoAbout(url: selectedUrl)
                if !infoString.isEmpty {
                    let formattedText = formatInfoText(infoString)
                    infoTextView.textStorage?.setAttributedString(formattedText)
                    saveInfoButton.isEnabled = true
                }//endif
            }//endif
        }//end didSet
    }//var selectedItemUrl

    // MARK: - View Lifecycle & error dialog utility
    override func viewWillAppear() {
        super.viewWillAppear()

/*
        let fontFamilyNames = NSFontManager.shared.availableFontFamilies
        //print("avaialble fonts is \(fontFamilyNames)")
        for famName in fontFamilyNames{
            let fontFamilysubs = NSFontManager.shared.availableMembers(ofFontFamily: famName)?.debugDescription
            print(famName, ":  ", fontFamilysubs!)
        }
*/
        splitView.setPosition(222.0, ofDividerAt: 0)
        restoreCurrentSelections()
    }

    override func viewWillDisappear() {
        saveCurrentSelections()
        super.viewWillDisappear()
    }

    func showErrorDialogIn(window: NSWindow, title: String, message: String) {
        let alert = NSAlert()
        alert.messageText       = title
        alert.informativeText   = message
        alert.alertStyle        = .critical
        alert.beginSheetModal(for: window, completionHandler: nil)
    }

}

// MARK: - Getting file or folder information
extension ViewController {

    // returns a list of urls in folder - sorted alphabetically
    func myContentsOf(folder: URL) -> [URL] {
        let fileManager = FileManager.default

        do {
            let contents = try fileManager.contentsOfDirectory(atPath: folder.path) // fileNames

            let urls = contents
                .filter({ return showAllFiles ? true : !$0.hasPrefix(".") })    // filter out hidden (or not)
                .map { return folder.appendingPathComponent($0) }           // create array with full path

            var urlsFiltered = [URL]()
            if showAllFiles {
                urlsFiltered = urls
            } else {                                                // if NOT showAllFiles: show only folders & swift files
                for url in urls {
                    if url.hasDirectoryPath || url.pathExtension == "swift" || (url.path.contains("WWDC") && url.pathExtension == "txt" ) {
                        urlsFiltered.append(url)
                    }
                }
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

    // returns attributes of url (file or folder) as a FileAttributes struct (defined above)
    func setFileInfo(url: URL) -> FileAttributes {
        let fileManager = FileManager.default
        var key: FileAttributeKey

        do {
            let attributes = try fileManager.attributesOfItem(atPath: url.path)
            let name = url.lastPathComponent

            key = FileAttributeKey(rawValue: "NSFileCreationDate")
            let creationDate = attributes[key] as? Date

            key = FileAttributeKey(rawValue: "NSFileModificationDate")
            let modificationDate = attributes[key] as? Date

            key = FileAttributeKey(rawValue: "NSFileSize")
            let size = attributes[key] as? Int ?? 0

            key = FileAttributeKey(rawValue: "NSFileType")            //NSFileType:    NSFileTypeDirectory
            let fileType = attributes[key] as? String
            let isDir = (fileType?.contains("Dir"))!
            return FileAttributes(url: url, name: name, creationDate: creationDate, modificationDate: modificationDate, size: size, isDir: isDir)

        } catch {
            return FileAttributes(url: url, name: "???", creationDate: nil, modificationDate: nil, size: 0, isDir: false)
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
            let date1 = attributes[key] as! Date
            report.append("\(key.rawValue):\t\(dateFormatter.string(from: date1))")

            key = FileAttributeKey(rawValue: "NSFileModificationDate")
            let date2 = attributes[key] as! Date
            report.append("\(key.rawValue):\t\(dateFormatter.string(from: date2))")

            key = FileAttributeKey(rawValue: "NSFileSize")
            value = attributes[key] as? Int ?? "????"
            report.append("\(key.rawValue):\t\(value)")

            //NSFileType:    NSFileTypeDirectory            // List all attributes
            //            for (key, value) in attributes {
            //                if key.rawValue == "NSFileExtendedAttributes" { continue }  // bypass Extended
            //                report.append("\(key.rawValue):\t\(value)")
            //            }
            return report.joined(separator: "\n")

        } catch {
            return "No information available for \(url.path)"
        }
    }
// MARK: - @IBActions

    //user clicked on SelectFolder button (brings up FileOpenDialog)
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
    }

    // user clicked on ShowAllFiles button
    @IBAction func toggleshowAllFiles(_ sender: NSButton) {
        showAllFiles = (sender.state == .on)
        if let selectedFolderUrl = selectedFolderUrl {
            filesList = myContentsOf(folder: selectedFolderUrl)
            //selectedItemUrl = nil
            tableView.reloadData()
        }
    }

    // user DoubleClicked on file/dir in tableView, so show contents
    @IBAction func tableViewDoubleClicked(_ sender: Any) {
        if tableView.selectedRow < 0 { return }

        let selectedItem = filesList[tableView.selectedRow]

        if selectedItem.hasDirectoryPath {
            selectedFolderUrl = selectedItem
        } else {
            showFileContents(url: selectedItem)
        }
    }

    // user clicked on UpOneLevel button, so select parent
    @IBAction func moveUpClicked(_ sender: Any) {
        if selectedFolderUrl?.path == "/" { return }
        selectedFolderUrl = selectedFolderUrl?.deletingLastPathComponent()
    }

    // saveInfo Clicked
    @IBAction func saveInfoClicked(_ sender: Any) {
        // Make sure we have a view.window and a selectedItemUrl
        guard let window = view.window else { return }
        guard let selectedItemUrl = selectedItemUrl else { return }

        // Create an NSSavePanel
        let panel = NSSavePanel()
        // Set directoryURL to home Directory for CurrentUser
        panel.directoryURL = FileManager.default.homeDirectoryForCurrentUser
        // Set default name of file to write to: "*.fs.txt"
        panel.nameFieldStringValue = selectedItemUrl
            .deletingPathExtension()
            .appendingPathExtension("fs.txt")
            .lastPathComponent

        // Show SavePanel & wait in a closure for user to finish
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
    }

    @IBAction func analyseContentsButtonClicked(_ sender: Any) {
        if let url = selectedItemUrl {
            if analyseMode == .swift || analyseMode == .WWDC {
                do {
                    // Read file content
                    let contentFromFile = try NSString(contentsOf: url, encoding: String.Encoding.utf8.rawValue)

                    if analyseFuncLocked { return }                  // because analyseSwiftFile() is not thread-save
                    analyseFuncLocked = true
                    analyseContentsButton.isEnabled = false
                    infoTextView.string = "Analysing..."
                    DispatchQueue.global(qos: .userInitiated).async {
                        var txt: NSAttributedString
                        if  self.analyseMode == .swift {
                            txt = analyseSwiftFile(contentFromFile as String, selecFileInfo: self.selecFileInfo )
                        } else if self.analyseMode == .WWDC {
                            txt = analyseWWDC(contentFromFile as String, selecFileInfo: self.selecFileInfo)
                        } else {
                            txt = NSAttributedString()
                        }
                        DispatchQueue.main.async {
                            self.infoTextView.textStorage?.setAttributedString(txt)
                            self.analyseFuncLocked = false
                            self.analyseContentsButton.isEnabled = true
                            self.displayedAnalysisUrl = url
                            if url != self.selectedItemUrl {
                                self.urlMismatch = self.selectedItemUrl
                            }//endif url
                        }//endif DispatchQueue.main
                    }//endif DispatchQueue.global

                }//end try do

                catch let error as NSError {
                    print("😡analyseContentsButtonClicked error: \(error)")
                }//end try catch

            } else if analyseMode == .xcodeproj {
                let txt = analyseXcodeproj(url: url)
                self.infoTextView.textStorage?.setAttributedString(txt)
            }//endif analyseMode

        }//end if let
    }//end analyseContentsButtonClicked





}//end class


// MARK: - NSTableViewDataSource
extension ViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return filesList.count
    }

}

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
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        if tableView.selectedRow < 0 {
            selectedItemUrl = nil
            return
        }
        selectedItemUrl = filesList[tableView.selectedRow]
    }

}

// MARK: - Save & Restore previous selection
extension ViewController {

    // called from viewWillDisappear
    func saveCurrentSelections() {
        guard let dataFileUrl = urlForDataStorage() else { return }

        let parentForStorage = selectedFolderUrl?.path ?? ""
        let fileForStorage = selectedItemUrl?.path ?? ""
        let completeData = "\(parentForStorage)\n\(fileForStorage)\n"

        try? completeData.write(to: dataFileUrl, atomically: true, encoding: .utf8)
    }

    // called from viewWillAppear
    func restoreCurrentSelections() {
        guard let dataFileUrl = urlForDataStorage() else {print("😡No dataFileUrl!"); return }

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
            print("😡restoreCurrentSelections error: \(error)")
        }
    }//end func restoreCurrentSelections

    private func selectUrlInTable(_ url: URL?) {
        guard let url = url else {
            tableView.deselectAll(nil)
            return
        }

        if let rowNumber = filesList.index(of: url) {
            let indexSet = IndexSet(integer: rowNumber)
            DispatchQueue.main.async {
                self.tableView.selectRowIndexes(indexSet, byExtendingSelection: false)
            }
        }
    }//end func selectUrlInTable

    // returns URL for ".../Application Support/AnalyseSwiftCode/StoredState.txt".  Called from saveCurrentSelections, restoreCurrentSelections
    private func urlForDataStorage() -> URL? {
        let fileManager = FileManager.default

        // The FileManager class has a method for returning a list of appropriate URLs for specific uses.
        // In this case, you are looking for the applicationSupportDirectory in the current user's directory.
        // It is unlikely to return more than one URL, but you only want to take the first one.
        // You can use this method with different parameters to locate many different folders.
        guard let folder = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else { return nil }
        print("✅ dataFileUrl = \(folder)")
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

        // Append another path component to create the full URL for the data file and return that.
        let dataFileUrl = appFolder.appendingPathComponent("StoredState.txt")
        return dataFileUrl
    }//end func urlForDataStorage

}//end class ViewController

// MARK: - Read file (GWB).
extension ViewController {

    // read contents of file & display them in infoTextView
    func showFileContents(url: URL) {
        var showLineNumbers = false
        var inMultiLineComment = false
        if url.pathExtension == "swift" {
            showLineNumbers = true
        }
        if url.lastPathComponent.hasPrefix("WWDC-20") && url.pathExtension == "txt" {
            showLineNumbers = true
        }
        do {
            var formattedText = NSMutableAttributedString()
            // Read file content
            let contentFromFile = try NSString(contentsOf: url, encoding: String.Encoding.utf8.rawValue)
            let lines = contentFromFile.components(separatedBy: "\n")

            if showLineNumbers {

                for i in 0..<lines.count {
                    //let line = "\(i+1) \(lines[i])\n"
                    let aa = lines[i].trim
                    if aa.hasPrefix("/*") {                         // "/*"
                        inMultiLineComment = true
                    }

                    if aa.hasPrefix("*/") {                         // "*/"
                        inMultiLineComment = false
                    }


                    let formattedLine = formatSwiftLine(lineNumber: i+1, text: lines[i], inMultiLineComment: inMultiLineComment)
                    formattedText.append(formattedLine)
                }
                infoTextView.textStorage?.setAttributedString(formattedText)

            } else {
                formattedText = formatInfoText(contentFromFile as String) as! NSMutableAttributedString
                infoTextView.textStorage?.setAttributedString(formattedText)
            }
        }
        catch let error as NSError {
            let err = "😡showFileContents error: \(error.localizedDescription)"
            print(err)
            let str = "\(selecFileInfo.name)\n\n'View' only works for text-based files."
            let formattedText = formatInfoText(str)
            infoTextView.textStorage?.setAttributedString(formattedText)
        }
    }//end func showFileContents


    // format 1st line to 20pt font; the rest to 14pt
    func formatInfoText(_ text: String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
        paragraphStyle?.minimumLineHeight = 24
        paragraphStyle?.alignment = .left
        paragraphStyle?.tabStops = [ NSTextTab(type: .leftTabStopType, location: 240) ]

        let textAttributes: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font: NSFont.systemFont(ofSize: 14),
            NSAttributedStringKey.paragraphStyle: paragraphStyle ?? NSParagraphStyle.default
        ]

        let formattedText = NSMutableAttributedString(string: text, attributes: textAttributes)
        var lengthLine1 = text.IndexOf("\n")
        if lengthLine1 < 0 { lengthLine1 = 0 }
        formattedText.addAttribute(NSAttributedStringKey.font,
                                   value: NSFont.systemFont(ofSize: 20),
                                   range: NSRange(location: 0, length: lengthLine1))
        return formattedText
    }

    //---- formatSwiftLine - Add line numbers and comment colors - format tabs at right26 & left32, font at 13pt
    func formatSwiftLine(lineNumber: Int, text: String, inMultiLineComment: Bool = false) -> NSAttributedString {
        var (codeLine, comment) = ("","")
        if inMultiLineComment {
            (codeLine, comment) = ("",text)
        } else {
            (codeLine, comment) = stripComment(fullLine: text, lineNum: lineNumber)
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = 2
        paragraphStyle.alignment = .left
        paragraphStyle.tabStops = [ NSTextTab(type: .rightTabStopType, location: 26),  NSTextTab(type: .leftTabStopType, location: 32) ]

        let lineNumAttributes: [NSAttributedStringKey: Any] = [
            //NSAttributedStringKey.font: NSFont.systemFont(ofSize: 10),
            NSAttributedStringKey.font: NSFont(name: "Menlo", size: 10)!,
            NSAttributedStringKey.foregroundColor: NSColor.gray,
            NSAttributedStringKey.paragraphStyle: paragraphStyle
        ]
        let formattedLineNum = NSAttributedString(string: "\t\(lineNumber)", attributes: lineNumAttributes)

        var textAttributes: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font: NSFont(name: "PT Mono", size: 12)!,
            NSAttributedStringKey.paragraphStyle: paragraphStyle
        ]
        let formattedText = NSAttributedString(string: "\t\(codeLine)", attributes: textAttributes)

        //green
        textAttributes[NSAttributedStringKey.foregroundColor] = NSColor(calibratedRed: 0, green: 0.6, blue: 0.15, alpha: 1)
        let formatedComment = NSMutableAttributedString(string: comment + "\n", attributes: textAttributes)

        let output = NSMutableAttributedString(attributedString: formattedLineNum)
        output.append(formattedText)
        output.append(formatedComment)
        return output
    }

    // format tabs at 48 & 96, font at 14pt
    func formatContentsTextX(_ text: String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
        paragraphStyle?.minimumLineHeight = 24
        paragraphStyle?.alignment = .left
        paragraphStyle?.tabStops = [ NSTextTab(type: .leftTabStopType, location: 48),  NSTextTab(type: .leftTabStopType, location: 96) ]

        let textAttributes: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font: NSFont.systemFont(ofSize: 14),
            NSAttributedStringKey.paragraphStyle: paragraphStyle ?? NSParagraphStyle.default
        ]

        let formattedText = NSAttributedString(string: text, attributes: textAttributes)
        return formattedText
    }

}



