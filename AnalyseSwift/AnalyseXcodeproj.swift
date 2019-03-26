//
//  AnalyseXcodeproj.swift
//  AnalyseSwiftCode
//
//  Created by George Bauer on 11/8/18.
//  Copyright © 2018,2019 George Bauer. All rights reserved.//

import Cocoa

//MARK:- Globals

private var pbxObjects = [String : PBX]()
private var xcodeProj  = XcodeProj()

//MARK:- structs

public struct XcodeProj {
    var filename             = ""   // from URL
    var appName              = ""   // from app target
    var productName          = ""   // from app target
    var archiveVersion       = ""   // base level
    var objectVersion        = ""   // base level
    var organizationName     = ""   // root object
    var compatibilityVersion = ""   // root object
    var LastSwiftUpdateCheck = ""   // root object
    var LastUpgradeCheck     = ""   // root object
    var createdOnToolsVersion = ""  // PBXProject section > attributes > TargetAttributes
    var swiftVerMin          = 0.0  // from XCBuildConfiguration.buildSettings."SWIFT_VERSION = 4.2"
    var swiftVerMax          = 0.0  // from XCBuildConfiguration.buildSettings."SWIFT_VERSION = 4.2"
    var sdkRoot              = ""   // from XCBuildConfiguration.buildSettings.SDKROOT = macosx
    var deploymentTarget     = ""   // from XCBuildConfiguration.buildSettings."MACOSX_DEPLOYMENT_TARGET = 10.12"
    var deploymentVerMin     = 0.0
    var deploymentVerMax     = 0.0
    var swiftURLs            = [URL]()
    var swiftSummaries       = [SwiftSummary]()
    var targets              = PBXNativeTarget()
    var url = FileManager.default.homeDirectoryForCurrentUser   // from URL
}

// component of XcodeProj
struct PBXNativeTarget {
    var name = ""                   // "AnalyseSwiftCode"
    var productName = ""            // "FileSpy"
    var productType = ""            // "com.apple.product-type.application" or "com.apple.product-type.bundle.unit-test"
    var productReference = ""       // key - PBXFileReference
    var buildConfigurationListKey = "" // key - XCConfigurationList contains 2 buildConfigurations(Debug & Release) >
// Begin PBXProject section > attributes > TargetAttributes
    var TestTargetID = ""           // 26ECD3361E874B5B00380F56
    var DevelopmentTeam = ""        // XD8UZ6484B
    var LastSwiftMigration = ""     // 1010
    var createdOnToolsVersion = ""  // 8.2.1
    var ORGANIZATIONNAME    = ""    // ORGANIZATIONNAME = "Ray Wenderlich"
}

// Struct to hold values set by .xcodeproj/project.pbxproj file
// To Add property:
//  1) "var XXX ="         (1 place);
//  2) func changeProperty (2 places)           case "XXX": self.XXX = vals.first ?? ""
//  3) "debugDescription"  (3 places) if !self.XXX.isEmpty    { str += ", XXX=" + self.XXX }
public struct PBX: CustomDebugStringConvertible {       //64-272 = 218-lines
    var isa         = ""
    var name        = ""
    var path        = ""
    var target      = ""
    var fileRef     = ""
    var mainGroup   = ""
    var proxyType   = ""
    var sourceTree  = ""

    var productName     = ""
    var productType     = ""
    var fileEncoding    = ""

    var containerPortal     = ""
    var productRefGroup     = ""
    var productReference    = ""    //????
    var lastKnownFileType   = ""

    var compatibilityVersion    = ""
    var remoteGlobalIDString    = ""
    var buildConfigurationList  = ""

    // arrays
    var files               = [String]()
    var targets             = [String]()
    var children            = [String]()
    var buildRules          = [String]()
    var dependencies        = [String]()
    var buildConfigurations = [String]()

    // attributes
    var LastSwiftUpdateCheck = ""
    var LastUpgradeCheck     = ""
    var ORGANIZATIONNAME     = ""    // ORGANIZATIONNAME = "Ray Wenderlich"

    // buildSettings
    var CreatedOnToolsVersion = ""
    var LastSwiftMigration  = ""
    var TestTargetID        = ""
    var SDKROOT             = ""
    var TEST_HOST           = ""
    var PRODUCT_NAME        = ""
    var SWIFT_VERSION       = ""
    var INFOPLIST_FILE      = ""
    var DEVELOPMENT_TEAM    = ""
    var CODE_SIGN_IDENTITY  = ""
    var MACOSX_DEPLOYMENT_TARGET   = ""
    var IPHONEOS_DEPLOYMENT_TARGET = ""
    var WATCH_DEPLOYMENT_TARGET   = ""
    var TV_DEPLOYMENT_TARGET   = ""
    var ENABLE_STRICT_OBJC_MSGSEND = ""
    var PRODUCT_BUNDLE_IDENTIFIER  = ""

    mutating func changeProperty(propertyName: String, vals: [String]) {    //114-181 = 67-lines
        switch propertyName {
        case "isa":         self.isa        = vals.first ?? ""
        case "name":        self.name       = vals.first ?? ""
        case "path":        self.path       = vals.first ?? ""
        case "target":      self.target     = vals.first ?? ""
        case "fileRef":     self.fileRef    = vals.first ?? ""
        case "mainGroup":   self.mainGroup  = vals.first ?? ""
        case "proxyType":   self.proxyType  = vals.first ?? ""
        case "sourceTree":  self.sourceTree = vals.first ?? ""

        case "productName":     self.productName    = vals.first ?? ""
        case "productType":     self.productType    = vals.first ?? ""
        case "fileEncoding":    self.fileEncoding   = vals.first ?? ""

        case "containerPortal":     self.containerPortal    = vals.first ?? ""
        case "productRefGroup":     self.productRefGroup    = vals.first ?? ""
        case "productReference":    self.productReference   = vals.first ?? ""
        case "lastKnownFileType":   self.lastKnownFileType  = vals.first ?? ""

        case "compatibilityVersion":    self.compatibilityVersion   = vals.first ?? ""
        case "remoteGlobalIDString":    self.remoteGlobalIDString   = vals.first ?? ""
        case "buildConfigurationList":  self.buildConfigurationList = vals.first ?? ""

        // arrays
        case "files":           self.files          = vals
        case "targets":         self.targets        = vals
        case "children":        self.children       = vals
        case "buildRules":      self.buildRules     = vals
        case "dependencies":    self.dependencies   = vals
        case "buildConfigurations": self.buildConfigurations = vals

        // attributes
        case "LastSwiftUpdateCheck": self.LastSwiftUpdateCheck = vals.first ?? ""
        case "LastUpgradeCheck":     self.LastUpgradeCheck     = vals.first ?? ""
        case "ORGANIZATIONNAME":     self.ORGANIZATIONNAME     = vals.first ?? ""

        // buildSettings
        case "CreatedOnToolsVersion":   self.CreatedOnToolsVersion = vals.first ?? ""
        case "LastSwiftMigration":  self.LastSwiftMigration     = vals.first ?? ""
        case "TestTargetID":        self.TestTargetID           = vals.first ?? ""
        case "SDKROOT":             self.SDKROOT                = vals.first ?? ""
        case "TEST_HOST":           self.TEST_HOST              = vals.first ?? ""
        case "PRODUCT_NAME":        self.PRODUCT_NAME           = vals.first ?? ""
        case "SWIFT_VERSION":       self.SWIFT_VERSION          = vals.first ?? ""
        case "INFOPLIST_FILE":      self.INFOPLIST_FILE         = vals.first ?? ""
        case "DEVELOPMENT_TEAM":    self.DEVELOPMENT_TEAM       = vals.first ?? ""
        case "CODE_SIGN_IDENTITY":  self.CODE_SIGN_IDENTITY     = vals.first ?? ""
        case "MACOSX_DEPLOYMENT_TARGET":    self.MACOSX_DEPLOYMENT_TARGET   = vals.first ?? ""
        case "IPHONEOS_DEPLOYMENT_TARGET":  self.IPHONEOS_DEPLOYMENT_TARGET = vals.first ?? ""
        case "WATCH_DEPLOYMENT_TARGET":     self.WATCH_DEPLOYMENT_TARGET    = vals.first ?? ""
        case "TV_DEPLOYMENT_TARGET":        self.TV_DEPLOYMENT_TARGET       = vals.first ?? ""
        case "PRODUCT_BUNDLE_IDENTIFIER":   self.PRODUCT_BUNDLE_IDENTIFIER  = vals.first ?? ""
        case "ENABLE_STRICT_OBJC_MSGSEND":  self.ENABLE_STRICT_OBJC_MSGSEND = vals.first ?? ""
        default:
            let ignore =
            ["remoteGlobalIDString","remoteInfo","defaultConfigurationName",
             "explicitFileType","includeInIndex","buildActionMask","runOnlyForDeploymentPostprocessing",
             "developmentRegion","hasScannedForEncodings","knownRegions","buildPhases",
             "projectDirPath","projectRoot","targetProxy","defaultConfigurationIsVisible",
             "indentWidth","tabWidth"
            ]
            if !ignore.contains(propertyName) {
                print("⛔️⛔️⛔️⛔️ #\(#line) property \"\(propertyName) = \(vals[0])\" not handled! ⛔️⛔️⛔️⛔️")
            }

        }//end switch
    }//end func

    //---- debugDescription - used for print
    public var debugDescription: String {       //184-244 = 60-lines
        //let sep = "\(sep)"
        let sep = "\n\t"
        let selfName = self.name.isEmpty ? "" : " - name: \"\(self.name)\""
        let selfPath = self.path.isEmpty ? "" : " - path: \"\(self.path)\""
        let selfProductName = self.productName.isEmpty ? "" : " - productName: \"\(self.productName)\""
        var str = self.isa + selfName + selfPath + selfProductName
        if !self.fileRef.isEmpty    { str += "\(sep)fileRef = " + self.fileRef }
        //if !self.name.isEmpty       { str += "\(sep)name = " + self.name }
        //if !self.path.isEmpty       { str += "\(sep)path = " + self.path }
        if !self.target.isEmpty     { str += "\(sep)target = " + self.target }
        if !self.mainGroup.isEmpty  { str += "\(sep)mainGroup = " + self.mainGroup }
        if !self.proxyType.isEmpty  { str += "\(sep)proxyType = " + self.proxyType }
        if !self.sourceTree.isEmpty { str += "\(sep)sourceTree = " + self.sourceTree }

        //if !self.productName.isEmpty    { str += "\(sep)productName = " + self.productName }
        if !self.productType.isEmpty    { str += "\(sep)productType = " + self.productType }
        if !self.fileEncoding.isEmpty   { str += "\(sep)fileEncoding = " + self.fileEncoding }

        if !self.containerPortal.isEmpty    { str += "\(sep)containerPortal = " + self.containerPortal }
        if !self.productRefGroup.isEmpty    { str += "\(sep)productRefGroup = " + self.productRefGroup }
        if !self.productReference.isEmpty   { str += "\(sep)productReference = " + self.productReference }
        if !self.lastKnownFileType.isEmpty  { str += "\(sep)lastKnownFileType = " + self.lastKnownFileType }

        if !self.compatibilityVersion.isEmpty   { str += "\(sep)compatibilityVersion = " + self.compatibilityVersion }
        if !self.remoteGlobalIDString.isEmpty   { str += "\(sep)remoteGlobalIDString = " + self.remoteGlobalIDString }
        if !self.buildConfigurationList.isEmpty { str += "\(sep)buildConfigurationList = " + self.buildConfigurationList }

        // arrays
        if !self.files.isEmpty          { str += "\(sep)\(showArray(name: "files",        array: self.files))" }
        if !self.targets.isEmpty        { str += "\(sep)\(showArray(name: "targets",      array: self.targets))" }
        if !self.children.isEmpty       { str += "\(sep)\(showArray(name: "children",     array: self.children))" }
        if !self.buildRules.isEmpty     { str += "\(sep)\(showArray(name: "buildRules",   array: self.buildRules))" }
        if !self.dependencies.isEmpty   { str += "\(sep)\(showArray(name: "dependencies", array: self.dependencies))" }
        if !self.buildConfigurations.isEmpty { str += "\(sep)\(showArray(name: "buildConfigurations", array: self.buildConfigurations))" }

        // attributes
        if !self.LastSwiftUpdateCheck.isEmpty { str += "\(sep)LastSwiftUpdateCheck = " + self.LastSwiftUpdateCheck }
        if !self.LastUpgradeCheck.isEmpty     { str += "\(sep)LastUpgradeCheck = " + self.LastUpgradeCheck }
        if !self.ORGANIZATIONNAME.isEmpty     { str += "\(sep)ORGANIZATIONNAME = " + self.ORGANIZATIONNAME }

        // buildSettings
        if !self.CreatedOnToolsVersion.isEmpty  { str += "\(sep)CreatedOnToolsVersion = " + self.CreatedOnToolsVersion }
        if !self.LastSwiftMigration.isEmpty     { str += "\(sep)LastSwiftMigration = "  + self.LastSwiftMigration }
        if !self.TestTargetID.isEmpty           { str += "\(sep)TestTargetID = "        + self.TestTargetID }
        if !self.SDKROOT.isEmpty                { str += "\(sep)SDKROOT = "             + self.SDKROOT }
        if !self.TEST_HOST.isEmpty              { str += "\(sep)TEST_HOST = "           + self.TEST_HOST }
        if !self.PRODUCT_NAME.isEmpty           { str += "\(sep)PRODUCT_NAME = "        + self.PRODUCT_NAME }
        if !self.SWIFT_VERSION.isEmpty          { str += "\(sep)SWIFT_VERSION = "       + self.SWIFT_VERSION }
        if !self.INFOPLIST_FILE.isEmpty         { str += "\(sep)INFOPLIST_FILE = "      + self.INFOPLIST_FILE }
        if !self.DEVELOPMENT_TEAM.isEmpty       { str += "\(sep)DEVELOPMENT_TEAM = "    + self.DEVELOPMENT_TEAM }
        if !self.CODE_SIGN_IDENTITY.isEmpty     { str += "\(sep)CODE_SIGN_IDENTITY = "  + self.CODE_SIGN_IDENTITY }
        if !self.MACOSX_DEPLOYMENT_TARGET.isEmpty   { str += "\(sep)MACOSX_DEPLOYMENT_TARGET = "   + self.MACOSX_DEPLOYMENT_TARGET }
        if !self.IPHONEOS_DEPLOYMENT_TARGET.isEmpty { str += "\(sep)IPHONEOS_DEPLOYMENT_TARGET = " + self.IPHONEOS_DEPLOYMENT_TARGET }
        if !self.WATCH_DEPLOYMENT_TARGET.isEmpty    { str += "\(sep)WATCH_DEPLOYMENT_TARGET = "    + self.WATCH_DEPLOYMENT_TARGET }
        if !self.TV_DEPLOYMENT_TARGET.isEmpty       { str += "\(sep)TV_DEPLOYMENT_TARGET = "       + self.TV_DEPLOYMENT_TARGET }
        if !self.PRODUCT_BUNDLE_IDENTIFIER.isEmpty  { str += "\(sep)PRODUCT_BUNDLE_IDENTIFIER = "  + self.PRODUCT_BUNDLE_IDENTIFIER }
        if !self.ENABLE_STRICT_OBJC_MSGSEND.isEmpty { str += "\(sep)ENABLE_STRICT_OBJC_MSGSEND = " + self.ENABLE_STRICT_OBJC_MSGSEND }

        return str
    }

    private func showArray(name: String, array: [String]) -> String {
        var str = name
        var comma = " ="
        for item in array {
            str += "\(comma) \(item)"
            comma = ","
        }
        return str
    }

    static func setDictPropertyPBX(dict: inout [String : PBX], key: String, propertyName: String, vals: [String]) {

        if vals.isEmpty {
            print("⛔️⛔️⛔️⛔️ \(#line) No value for pbxDict[\(key)] ⛔️⛔️⛔️⛔️")
            return
        }
        if dict[key] == nil {
            dict[key] = PBX()
            if propertyName != "isa" {
                print("⛔️⛔️⛔️⛔️ \(#line) Cannot set pbxDict[\(key)] = \(vals[0]), because it does't exist. ⛔️⛔️⛔️⛔️")
                return
            }
        }

        dict[key]!.changeProperty(propertyName: propertyName, vals: vals)

    }

}//end struct PBX

//MARK:- funcs

//MARK: analyseXcodeproj 42-lines
//---- analyseXcodeproj - Analyse a .xcodeproj file, returning an errorText and an XcodeProj instance
public func analyseXcodeproj(url: URL, goDeep: Bool, deBug: Bool = true) -> (String, XcodeProj) {   //280-322 = 42-lines
    xcodeProj = XcodeProj()
    xcodeProj.url = url
    xcodeProj.filename = url.lastPathComponent
    let pbxprojURL = url.appendingPathComponent("project.pbxproj")
    let urlFile = URL(fileURLWithPath: #file)
    let swiftFilename = urlFile.lastPathComponent
    print("\n🔷 \(swiftFilename) line#\(#line) Start processing 😃\(xcodeProj.filename)😃")

    do {
        let storedData = try String(contentsOf: pbxprojURL)

        pbxToXcodeProj(storedData, deBug: deBug)

        if deBug {print("\n🍎 \(xcodeProj)")}
    } catch {
        return  ( "Error: Could not read \"\(pbxprojURL.lastPathComponent)\"\n\(pbxprojURL.path)", xcodeProj)
    }

    if goDeep {

        xcodeProj.swiftSummaries = []
        for url in xcodeProj.swiftURLs {
            let fileInfo = FileAttributes.getFileInfo(url: url)       // set selecFileInfo (name,dates,size,type)

            do {
                let contentFromFile = try String(contentsOf: url, encoding: String.Encoding.utf8)
                let (swiftSummary, _) = analyseSwiftFile(contentFromFile: contentFromFile, selecFileInfo: fileInfo )
                xcodeProj.swiftSummaries.append(swiftSummary)
            } catch let error as NSError {
                print("⛔️ analyseContentsButtonClicked error: ⛔️\n⛔️\(error)⛔️")
            }//end try catch
        }
        if deBug {
            print("✅✅✅✅✅✅")
            print(xcodeProj)
            print("✅✅✅✅✅✅")
        }
    }

    return ( "", xcodeProj)

}//end func analyseXcodeproj


func stripComments(_ line: String) -> String {      //325-357 = 32-lines
    var cleanLine = line
    if cleanLine.contains("//") {
        let comps = cleanLine.components(separatedBy: "//")
        cleanLine = comps[0].trim
    }
    if !cleanLine.contains("/*") { return cleanLine }

    if !cleanLine.contains("*/") {
        print("⛔️ BlockComment-Start with no BlockComment-end\n\"\(line)\"")
        return cleanLine
    }
    let chars = Array(cleanLine)
    var cleanerLine = String(chars[0])
    var inBlock = false
    var ignorePrev = false
    for i in 1..<chars.count {
        if chars[i-1] == "/" && chars[i] == "*" {
            inBlock = true
            ignorePrev = true
        } else if chars[i-1] == "*" && chars[i] == "/" {
            inBlock = false
            ignorePrev = true
        } else {
            if ignorePrev {
                ignorePrev = false
            } else if !inBlock {
                cleanerLine.append(chars[i-1])
            }
        }
    }
    return cleanerLine
}//end func

//MARK: pbxToXcodeProj 319-lines
func pbxToXcodeProj(_ str: String, deBug: Bool = true) {        //360-679 = 319-lines
    if deBug {
        print("Start pbxToXcodeProj")
        print("🏄‍♂️")
        print("🏄‍♂️ Uncomment to get a fresh copy of projectpbxproj.txt")
        //print(str)      // Use to copy & paste into text editor for debugging
        print("🏄‍♂️")
    }
    pbxObjects.removeAll()
    var rootObjectKey  = ""
    let (strClean,linePtr) = stripCommentsAndNewlines(str)
    let chars = Array(strClean)
    var depth = 0
    var bufrs = [String]()
    bufrs.append("")

    for ptrChar in 0..<chars.count {
        let char = chars[ptrChar]


        if char == "{" {                                    // "{"
            bufrs[depth] = bufrs[depth].trim
            if !bufrs[depth].hasSuffix("=") { print("⛔️ #\(#line) NO EQUAL SIGN in \"\(bufrs[depth])\" ⛔️") }
            //if deBug { print("🐯⬇️ bufrs[\(depth)]: \"\(bufrs[depth])\" { Getting properties ...")}
            depth += 1
            bufrs.append("")

        } else if char == "}" {
            if depth > 0 && !bufrs[depth-1].hasSuffix("=") { print("⛔️ #\(#line) NO EQUAL SIGN in \"\(bufrs[depth])\" ⛔️") }
            //if deBug {print("🐯⬆️ bufrs[\(depth-1)]: \"\(bufrs[depth-1])\"")}
            bufrs.removeLast()
            depth -= 1

        } else if char == ";" {                             // ";"
            var parts = [String]()
            var start = 1
            if depth >= 1 && bufrs[1] == "objects =" { start = 2 }

            if depth >= start {
                for d in start...depth {
                    parts.append(bufrs[d].trim)
                }//next
            }

            if let partLast = parts.last {
                if !partLast.hasSuffix("=") {

                    if deBug {
                        if parts.count < 2 || parts[1].hasPrefix("isa =") { print() }   // blank line before "isa ="

                        if parts.count < 3 || parts[1] != "buildSettings" || !parts[2].contains("GCC") || !parts[2].contains("CLANG") {
                            print("↔️\(linePtr[ptrChar])-\(depth) \(parts)")
                        }
                    }

                    let assignee = parts[0]
                    let objKey = String(assignee.dropLast()).trim   // remove " =" from objKey
                    let isa0 = getAssigneeIsa(string: assignee, pbxObjects: pbxObjects)
                    if parts.count == 1 {
                        //if deBug {print(partLast)}
                        let (key, val) = keyValDecode(partLast)
                        switch key {
                        case "archiveVersion":
                            xcodeProj.archiveVersion = val
                        case "objectVersion":
                            xcodeProj.objectVersion = val
                        case "rootObject":
                            rootObjectKey = val
                        default:
                            print("😡 Unhandled line \(linePtr[ptrChar]) \"\(partLast)\" 😡😡")
                        }
                    } else if parts.count == 2 {
                        if assignee.hasSuffix("=") {
                            let (propertyName, vals) = getPropertyAndVals(from: parts[1])
                            PBX.setDictPropertyPBX(dict: &pbxObjects, key: objKey, propertyName: propertyName, vals: vals)
                        }
                    } else if parts.count == 3 {
                        //if deBug {print("3parts:", parts)}

                        if isa0 == "PBXProject" && parts[1] == "attributes =" {     // PBXProject > attributes
                            if deBug {print("   PBXProject attribute: \(parts[2])")}
                            let (propertyName, vals) = getPropertyAndVals(from: parts[2])
                            let got1: Bool
                            switch propertyName {
                            case "LastSwiftUpdateCheck" : got1 = true
                            case "LastUpgradeCheck"     : got1 = true
                            case "ORGANIZATIONNAME"     : got1 = true
                            default: got1 = false
                            }
                            if got1 {
                                PBX.setDictPropertyPBX(dict: &pbxObjects, key: objKey, propertyName: propertyName, vals: vals)
                            } else {
                                if deBug {print("😡3😡??? Unimplemented attribute: \"\(isa0)\", \"\(parts[1])\", \"\(parts[2])\" 😡😡")}
                            }

                        } else if isa0 == "XCBuildConfiguration" && parts[1] == "buildSettings ="   {
                            if !parts[2].contains("GCC") && !parts[2].contains("CLANG") {
                                let (propertyName, vals) = getPropertyAndVals(from: parts[2])
                                let got1: Bool
                                switch propertyName {
                                case "SDKROOT"                   : got1 = true;
                                case "SWIFT_VERSION"             : got1 = true
                                case "MACOSX_DEPLOYMENT_TARGET"  : got1 = true
                                case "IPHONEOS_DEPLOYMENT_TARGET": got1 = true
                                case "WATCHOS_DEPLOYMENT_TARGET" : got1 = true
                                default: got1 = false
                                }
                                if got1 {
                                    //if deBug {print(objKey, pbxObjects[objKey] ?? "???")}
                                    PBX.setDictPropertyPBX(dict: &pbxObjects, key: objKey, propertyName: propertyName, vals: vals)
                                    if deBug {print(objKey, pbxObjects[objKey] ?? "???\n")}
                                } else {
                                    if deBug {print("😡3😡??? Unimplemented attribute \(isa0), \(parts[1]), \(parts[2]) 😡😡")}
                                }

                            }
                        } else {
                            if deBug {print("😡😡??", isa0, parts[1], parts[2], "😡😡")}
                        }

                    } else {    // parts.count > 3
                        if parts[1] != "attributes =" || parts[2] != "TargetAttributes =" {
                            if deBug {print("😡\(parts.count)😡??? Unimplemented TargetAttributes \(isa0), \(parts[1]), \(parts[2]) 😡😡")}
                        }
                        // ↔️183-6 ["26ECD32F1E874B5B00380F56 =", "attributes =", "TargetAttributes =", "26ECD3361E874B5B00380F56 =", "CreatedOnToolsVersion = 8.2.1"]
                        let targetKey = String(parts[3].dropLast()).trim   // remove " =" from objKey
                        let (propertyName, vals) = getPropertyAndVals(from: parts[4])
                        let got1: Bool
                        switch propertyName {
                        case "CreatedOnToolsVersion": got1 = true
                        case "LastSwiftMigration"   : got1 = true
                        case "TestTargetID"         : got1 = true
                        default: got1 = false
                        }
                        if got1 {
                            PBX.setDictPropertyPBX(dict: &pbxObjects, key: targetKey, propertyName: propertyName, vals: vals)
                        } else {
                            if deBug {print("😡\(parts.count)😡??? Unimplemented attribute \(isa0), \(parts[1]), \(parts[2]) 😡😡")}
                        }

                        /* 5 (-6)  "TargetAttributes =", "26ECD3361E874B5B00380F56 =",
                         isa = PBXNativeTarget
                         "CreatedOnToolsVersion = 8.2.1"
                         "DevelopmentTeam = XD8UZ6484B"
                         "LastSwiftMigration = 1010"
                         "ProvisioningStyle = Automatic"
                         "TestTargetID = 26ECD3361E874B5B00380F56" (only for unit or UI Testing)
                         */
                    }
                }
            }//parts not nil
            bufrs[depth] = ""

        } else {                                        // not "{" or "}" or ";"
            bufrs[depth].append(char)
        }

    }//next ptrChar

    // rootObject[pbxObjects] -> mainGroup[pbxGroup]    -> children (prog, unit-tests, product, framework)[pbxGroup]
    //        -> productRefGroup[pbxGroup]      name=Products   -> 3-children (.app, .xctest, .xctest)[PBXFileReference]
    //        -> buildConfigurationList
    //        -> targets[PBXNativeTarget]

    //Analyse rootObject

    //RootObject
    let rootObject = pbxObjects[rootObjectKey]!

    if deBug {
        print("\n\(#line) ----0 Root Object [PBXProject] ------------------------")
        print(rootObjectKey, rootObject)
    }

    //RootObject > mainGroup
    let mainGroupKey = rootObject.mainGroup
    let mainGroupObj = pbxObjects[mainGroupKey]!
    if deBug {
        print("\n\n\(#line) --------1 rootObject > mainGroup [PBXGroup] ------------")
        print(mainGroupKey, mainGroupObj)
    }
    let mainGroupChildrenKeys = mainGroupObj.children
    var appSourceKey = ""
    var appSourceObj = PBX()

    if deBug {print("\n\(#line) --------1 RootObject.mainGroup > \(mainGroupChildrenKeys.count)-children [PBXGroup] ------------")}
    // find Most likely child to have swift source files
    for ( i, childKey) in mainGroupChildrenKeys.enumerated() {
        let childObj = pbxObjects[childKey]!
        if deBug {
            print("\n\(#line) ------------2 rootObject.mainGroup.child[\(i)] [PBXGroup] - children are [PBXFileReference] --------")
            print(childKey, pbxObjects[childKey] ?? "⛔️ #line-\(#line)Error: Missing mainGroupChildrenKey")
        }
        // real stuff
        if i == 0 {
            appSourceKey = childKey            // first child is usually the app
            if !isTestOrProductOrFramework(name: childObj.name) { break }
        }
        if !isTestOrProductOrFramework(name: childObj.name) {
            appSourceKey = childKey
            break
        }
    }

    //RootObject > productRefGroup - debug print
    if deBug {
        let productRefGroupKey = rootObject.productRefGroup
        print("\n\(#line) --------1 rootObject.productRefGroup [PBXGroup] - children are [PBXFileReference] ------------")
        print("              * Same as mainGroup.child named \"Products\"")
        print(productRefGroupKey, pbxObjects[productRefGroupKey] ?? "⛔️ #line-\(#line)Error: Missing rootObject.productRefGroup")
    }
    //RootObject > buildConfigurationList - debug print
    if deBug {
        let buildConfigurationListKey = rootObject.buildConfigurationList
        print("\n\(#line) --------1 rootObject.buildConfigurationList [XCConfigurationList] - children are [XCBuildConfiguration] ------------")
        print(buildConfigurationListKey, pbxObjects[buildConfigurationListKey] ?? "⛔️ #line-\(#line)Error: Missing rootObject.buildConfigurationList")
    }

    let rootbuildConfigurationListKey = rootObject.buildConfigurationList
    let rootbuildConfigurationListObj = pbxObjects[rootbuildConfigurationListKey]!
    for (i, buildConfigurationKey) in rootbuildConfigurationListObj.buildConfigurations.enumerated() {
        if deBug {
            print("\n\(#line) ------------2 rootObject.buildConfigurationList.buildConfiguration[\(i)] [PBXBuildConfiguration] --------")
            print(buildConfigurationKey, pbxObjects[buildConfigurationKey] ?? "⛔️ #line-\(#line)Error: Missing rootObject.buildConfigurationKey")
        }

        let buildConfigurationObj = pbxObjects[buildConfigurationKey]!
        let sdkroot = buildConfigurationObj.SDKROOT
        if deBug {print("🔹 \(buildConfigurationKey) SDKROOT = \"\(sdkroot)\"")}
        if !sdkroot.isEmpty {
            if !xcodeProj.sdkRoot.isEmpty && xcodeProj.sdkRoot != sdkroot {
                print("⛔️⛔️ #line-\(#line) sdkRoot mismatch: \(xcodeProj.sdkRoot) != \(sdkroot)  ⛔️⛔️")
            } else {
                xcodeProj.sdkRoot = sdkroot
            }
        }

        updateDeploymentTarget(buildConfigurationObj: buildConfigurationObj)

    }//next


    //RootObject > targets
    let targetKeys = rootObject.targets
    if deBug {
        print("\n\(#line) --------1 RootObject > \(targetKeys.count)-targets [PBXNativeTarget] ------------")
        for ( i, targetKey) in targetKeys.enumerated() {
            print("\n\(#line) ------------2 rootObject.target[\(i)] [PBXNativeTarget] --------")
            print(targetKey, pbxObjects[targetKey] ?? "⛔️ #line-\(#line)Error: Missing rootObject.targetKey")
        }
        print("----------------------------------------------------------------")
    }

    xcodeProj.compatibilityVersion = rootObject.compatibilityVersion
    xcodeProj.LastSwiftUpdateCheck = rootObject.LastSwiftUpdateCheck
    xcodeProj.LastUpgradeCheck     = rootObject.LastUpgradeCheck
    xcodeProj.organizationName     = rootObject.ORGANIZATIONNAME

    if !appSourceKey.isEmpty {
        appSourceObj = pbxObjects[appSourceKey]!
        let dirPath = appSourceObj.path.replacingOccurrences(of: "\"", with: "")
        if deBug {
            print()
            print("---- Most likely child to have swift source files [PBXGroup]. Children are [PBXFileReference] ----")
            print("appSourceObj = ",appSourceObj)
            print()
            print("😈appSourceObj.path = \"\(dirPath)\"")
        }
        let sourceFileKeys = appSourceObj.children
        for sourceFileKey in sourceFileKeys {
            let sourceFileObj = pbxObjects[sourceFileKey]!
            let filePath = sourceFileObj.path
            if filePath.hasSuffix(".swift") {
                let url = xcodeProj.url.deletingLastPathComponent().appendingPathComponent(dirPath).appendingPathComponent(filePath)
                xcodeProj.swiftURLs.append(url)
                if deBug {print(url.path)}
            }
            if deBug {print("😈", sourceFileObj)}
        }
    }

    // Set SDKROOT, SWIFT_VERSION, MACOSX_DEPLOYMENT_TARGET
    // for each target in rootObject
    for targetKey in rootObject.targets {
        guard let targetObj = pbxObjects[targetKey] else { continue }   // make non-optional targetObj
        let productType = targetObj.productType
        //if deBug {print(targetKey, targetObj)}
        if !productType.contains(".application") { continue }           // only pay attention to application target
        xcodeProj.appName = targetObj.name
        xcodeProj.productName = targetObj.productName
        xcodeProj.createdOnToolsVersion = targetObj.CreatedOnToolsVersion

        let buildConfigurationListKey = targetObj.buildConfigurationList
        if buildConfigurationListKey.isEmpty { continue }                   // missing buildConfigurationListKey
        guard let buildConfigurationListObj = pbxObjects[buildConfigurationListKey] else { continue }   // "
        for buildConfigurationKey in buildConfigurationListObj.buildConfigurations {
            guard let  buildConfigurationObj = pbxObjects[buildConfigurationKey] else { continue }

            let swiftVer = buildConfigurationObj.SWIFT_VERSION
            let ver = getVersionNumber(text: swiftVer)
            if ver > xcodeProj.swiftVerMax { xcodeProj.swiftVerMax = ver }
            if xcodeProj.swiftVerMin == 0.0 || ver < xcodeProj.swiftVerMin { xcodeProj.swiftVerMin = ver }
            if deBug {print("🔹 \(buildConfigurationKey) SWIFT_VERSION = \"\(swiftVer)\"")}

            let macOSXDeploymentTarget = buildConfigurationObj.MACOSX_DEPLOYMENT_TARGET
            let iPhoneOSDeploymentTarget = buildConfigurationObj.IPHONEOS_DEPLOYMENT_TARGET
            if !macOSXDeploymentTarget.isEmpty {
                print("⚠️ MACOSX_DEPLOYMENT_TARGET found in Target buildConfiguration")
                //xcodeProj.deploymentTarget = "macOS Deployment Target = " + macOSXDeploymentTarget
            }
            if !iPhoneOSDeploymentTarget.isEmpty {
                print("⚠️ IPHONEOS_DEPLOYMENT_TARGET found in Target buildConfiguration")
                //xcodeProj.deploymentTarget = "iPhoneOS Deployment Target = " + iPhoneOSDeploymentTarget
            }

        }//next buildConfigurationKey
    }//next targetKey

    if deBug {print("\n--------------------------------------------------\n")}
}//end func pbxToXcodeProj


private func updateDeploymentTarget(buildConfigurationObj: PBX) {
    var os = "macOS"    //    "macOS Deployment Target = "
    var deploymentTarget = buildConfigurationObj.MACOSX_DEPLOYMENT_TARGET
    if deploymentTarget.isEmpty {
        os = "iPhoneOS"
        deploymentTarget = buildConfigurationObj.IPHONEOS_DEPLOYMENT_TARGET
    }
    if deploymentTarget.isEmpty {
        deploymentTarget = buildConfigurationObj.WATCH_DEPLOYMENT_TARGET
        os = "WatchOS"
    }
    if deploymentTarget.isEmpty {
        deploymentTarget = buildConfigurationObj.TV_DEPLOYMENT_TARGET
        os = "tvOS"
    }

    if !deploymentTarget.isEmpty {
        xcodeProj.deploymentTarget = os + " Deployment Target = " + deploymentTarget
    }
}

private func isTestOrProductOrFramework(name: String) -> Bool {
    return name == "Frameworks" || name == "Products" || name.hasSuffix("Tests")
}

// Get the isa of the pbxObject refered to by string
private func getAssigneeIsa(string: String, pbxObjects: [String : PBX]) -> String {
    var objKey = string
    var isa = ""
    if objKey.hasSuffix("=") { objKey = String(string.dropLast()).trim }
    isa = pbxObjects[objKey]?.isa ?? ""
    return isa
}

// Decode " xxx = yyy ; " into ("xxx","yyy")
private func keyValDecode(_ str: String) -> (String, String) {
    let comps = str.components(separatedBy: "=")
    if comps.count < 2  { return ("","")}
    let key = comps[0].trim
    var val = comps[1].trim
    if val.hasSuffix(";") { val = String(val.dropLast()).trim }
    return (key, val)
}

//---- getPropertyAndVals - returns a property name & an array of values from a Sting like "propName = val" or "propName = (val1, val2, ...)"
func getPropertyAndVals(from text: String) -> (propName: String, vals: [String]) {
    let comps = text.components(separatedBy: "=")
    let propName = comps[0].trim
    let vals: [String]
    var valStr: String
    if comps.count > 1 {
        valStr = comps[1].trim
    } else {
        valStr = "???"
    }
    if valStr.hasPrefix("(") && valStr.hasSuffix(")") {
        valStr = String(valStr.dropFirst().dropLast()).trim
        if valStr.hasSuffix(",") { valStr = String(valStr.dropLast()) }
        vals = valStr.components(separatedBy: ",").map {$0.trim}
    } else {
        vals = [valStr]
    }
    return (propName, vals)
}

//---- stripCommentsAndNewlines -
//Returns String stripped of comments, newLines, tabs & double-spaces.
//Also returns linePointer witch contains a Line-Number for each Character.
func stripCommentsAndNewlines(_ str: String) -> (String, [Int]) {       //751-800 = 49-lines
    if str.contains("//") {
        print("⛔️⛔️⛔️  #\(#line) Contains \" // \"")
    }
    if !str.contains("/*") { return (str, [Int]() ) }
    if !str.contains("*/") {
        print("⛔️ BlockComment-Start with no BlockComment-end\n\"\(str)\"")
        return (str, [Int]() )
    }

    let chars = Array(str)
    var newStr = String(chars[0])
    var inBlock = false
    var ignorePrev = false
    for i in 1..<chars.count {
        let prevChar = chars[i-1]
        if prevChar == "/" && chars[i] == "*" {         // "/*"
            inBlock = true
            ignorePrev = true
        } else if prevChar == "*" && chars[i] == "/" {  // "*/"
            inBlock = false
            ignorePrev = true
        } else {                                        // all the rest
            if ignorePrev {
                ignorePrev = false
            } else if !inBlock {
                if prevChar != "\t" { newStr.append(prevChar) }
            }
        }
    }//next i
    newStr.append(chars.last ?? Character(""))      //???? Get that last Character

    newStr = newStr.replacingOccurrences(of: "  ", with: " ") // Remove Double-Spaces

    // Now build outputStr & Line-Number array, removing newLines.
    var outputStr = ""
    var linePtrs = [Int]()
    let lines = newStr.components(separatedBy: "\n")
    for (num, line) in lines.enumerated() {
        outputStr.append(line)                 // append the line without \n
        if line.count > 0 {
            for _ in 0..<line.count { // Set Line-Number for each Character position.
                linePtrs.append(num+1)
            }
            //p1 = p1 + line.count
        }
    }//next line

    return (outputStr, linePtrs)
}//end func stripCommentsAndNewlines


//---- getVersionNumber - Gets a Version Number (Double) from String
func getVersionNumber(text: String) -> Double {
    var txt = text
    if txt.hasPrefix("\"") { txt.removeFirst() }    // Remove "
    if txt.hasSuffix("\"") { txt.removeLast()  }    // Remove "

    let parts = txt.components(separatedBy: ".")
    if parts.count > 2 {                            // If > 1 decimalPoint, only use 1st 2 parts
        txt = parts[0] + "." + parts[1]
    }
    let version = Double(txt) ?? 0.0                // Return 0.0 if not valid
    return version
}

//not used
private func isObjectKey(_ str: String) -> Bool {
    var hexObj = str.trim
    if hexObj.hasPrefix("=") { hexObj = String(hexObj.dropFirst()).trim }
    if hexObj.hasSuffix("=") { hexObj = String(hexObj.dropLast()).trim }

    if hexObj.count != 24 { return false }  // must be exactly 24-characters

    for char in hexObj {
        if !(char >= "0" && char <= "9") || (char >= "A" && char <= "F") { return false }
    }
    return true
}

//MARK: NSAttributedString stuff - Called from ViewController

//let attributesLargeFont  = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 20), NSAttributedString.Key.paragraphStyle: paragraphStyleA1]
//let attributesMediumFont = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 16), NSAttributedString.Key.paragraphStyle: paragraphStyleA1]
//let attributesSmallFont  = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 12), NSAttributedString.Key.paragraphStyle: paragraphStyleA1]
//var attTxt  = NSMutableAttributedString(string: "", attributes: attributesSmallFont)

public struct IssuePreferences {
    var maxFileCodeLines = 500
    var maxFuncCodeLines = 200
    var diffentProductNameAllowed = false
    var allowedOrganizations = ["GeorgeBauer","georgebauer"]
    var underscoreAllowed = false
    var minumumSwiftVersion = 4.0
}

public func showXcodeproj(_ xcodeProj: XcodeProj) -> NSAttributedString  {
    let issuePreferences = IssuePreferences()

    var text = ""
    var issues = [String]()
    text += "          ---------------- \(xcodeProj.filename) ----------------\n"
    text += "Application Name         = \(xcodeProj.appName)\n"
    if xcodeProj.appName != xcodeProj.productName {
        text += "Product Name             = \(xcodeProj.productName)\n"
        if !issuePreferences.diffentProductNameAllowed {
            issues.append("AppName: \"\(xcodeProj.appName)\" != ProductName: \"\(xcodeProj.productName)\"")
        }
    }

    if xcodeProj.swiftVerMin != xcodeProj.swiftVerMax {
        let issue = "Multiple Swift Versions: \(xcodeProj.swiftVerMin) & \(xcodeProj.swiftVerMax)"
        text += "\(issue)\n"
        issues.append(issue)
    } else {
        if xcodeProj.swiftVerMin == 0.0 {
            let issue = "No Swift Version found"
            text += "\(issue)!\n"
            issues.append(issue)
        } else {
            if xcodeProj.swiftVerMin < issuePreferences.minumumSwiftVersion {
                issues.append("Obsolete Swift Version \(xcodeProj.swiftVerMin)")
            }
            text += "Swift Version used       = \(xcodeProj.swiftVerMin)\n"
        }
    }
    text += "Archive Version          = \(xcodeProj.archiveVersion)\n"
    text += "Object Version           = \(xcodeProj.objectVersion)\n"
    text += "Compatibility Version    = \(xcodeProj.compatibilityVersion)\n"
    text += "Last Swift Update Check  = \(xcodeProj.LastSwiftUpdateCheck)\n"
    text += "Last Upgrade Check       = \(xcodeProj.LastUpgradeCheck)\n"
    text += "Organization Name        = \(xcodeProj.organizationName)\n"
    text += "Created On Tools Version = \(xcodeProj.createdOnToolsVersion)\n"
    text += "SDK Root                 = \(xcodeProj.sdkRoot)\n"
    text += "\(xcodeProj.deploymentTarget)\n"    // deploymentTarget

    if !issuePreferences.allowedOrganizations.isEmpty {
        if !issuePreferences.allowedOrganizations.contains(xcodeProj.organizationName) {
            issues.append("External Organization \"\(xcodeProj.organizationName)\"")
        }
    }
    var totalCodeLineCount     = 0
    var totalNonCamelCaseCount = 0
    var totalForceUnwrapCount  = 0
    var totalVbCompatCallCount = 0

    text += "\n                           ---- \(showCount(count: xcodeProj.swiftURLs.count, name: "Swift file")) ----\n"   // "Swift files"
    text += "------ FileName ------     CodeLines  NonCamelCase  ForceUnwrap VBcompatability\n"

    for swiftSummary in xcodeProj.swiftSummaries {
        let name = swiftSummary.fileName
        let isTest = swiftSummary.url.path.contains("TestSharedCode")
        if isTest || (name != "VBcompatablity.swift" && name != "MyFuncs.swift" && name != "StringExtension.swift") {
            let count = swiftSummary.codeLineCount
            totalCodeLineCount      += count
            if count > issuePreferences.maxFileCodeLines {
                issues.append("\"\(name)\" has \(count) code-lines (>\(issuePreferences.maxFileCodeLines)).")
            }
            let c2 = swiftSummary.nonCamelCases.count
            totalNonCamelCaseCount  += c2
            let c3 = swiftSummary.forceUnwraps.count
            totalForceUnwrapCount   += c3
            let c4 = swiftSummary.vbCompatCalls.count
            totalVbCompatCallCount  += c4
            //text += "\(swiftSummary.url.lastPathComponent)  -  nonCamel \(swiftSummary.nonCamelCases.count)\n"
            text += format2(swiftSummary.url.lastPathComponent,count,c2,c3,c4)
        } else {
            text += "(\(swiftSummary.url.lastPathComponent))\n"
        }
    }//next
    text += "\n\(format2("  -- Totals --",totalCodeLineCount,totalNonCamelCaseCount,totalForceUnwrapCount,totalVbCompatCallCount))\n"

    //------------------------------------------------------------------
    //------------- Issues --------------
    let totalIssueCount = totalNonCamelCaseCount + totalForceUnwrapCount + totalVbCompatCallCount + issues.count

    if totalIssueCount == 0 {
        text += "\n-------- No Issues --------\n"
    } else {
        text += "\n-------- \(totalIssueCount) Possible \("Issue".pluralize(totalIssueCount)) --------\n"
        if totalNonCamelCaseCount > 0 {text += "\(showCount(count: totalNonCamelCaseCount, name: "NonCamelCase Variable")).\n"}
        if totalForceUnwrapCount  > 0 {text += "\(showCount(count: totalForceUnwrapCount,  name: "ForceUnwrap")).\n"}
        if totalVbCompatCallCount > 0 {text += "\(showCount(count: totalVbCompatCallCount, name: "VBcompatability Call")).\n"}
    }
    for issue in issues {
        text += issue + "\n"
    }


    // ------- NSAttributedString -------
    //        txvMain.font = NSFont(name: "Courier", size: 12)

    let textAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font: NSFont(name: "Courier", size: 14)!,        //systemFont(ofSize: 18),
        NSAttributedString.Key.paragraphStyle: NSParagraphStyle.default
    ]
    let formattedText = NSMutableAttributedString(string: text, attributes: textAttributes)
    return formattedText
}//end func

private func format2(_ name: String, _ c1: Int, _ c2: Int, _ c3: Int, _ c4: Int) -> String {
    let txt = name.PadRight(26) + fmtI(c1, wid: 8)  + fmtI(c2, wid: 11) +
                                  fmtI(c3, wid: 13) + fmtI(c4, wid: 13) + "\n"
    return txt
}
private func fmtI(_ number: Int, wid: Int) -> String {
    if number == 0 { return "-".PadLeft(wid) }
    return formatInt(number: number, fieldLen: wid)
}
