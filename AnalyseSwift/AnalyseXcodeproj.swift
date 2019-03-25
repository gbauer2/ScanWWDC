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
    var name            = ""        // from URL
    var organizationName = ""
    var archiveVersion  = ""        // base level
    var objectVersion   = ""        // base level
    var createdOnToolsVersion = ""  // PBXProject section > attributes > TargetAttributes
    var swiftVerMin     = 0.0       // from XCBuildConfiguration.buildSettings."SWIFT_VERSION = 4.2"
    var swiftVerMax     = 0.0
    var sdkRoot         = ""        // from XCBuildConfiguration.buildSettings.SDKROOT = macosx
    var deploymentTarget = ""       // from XCBuildConfiguration.buildSettings."MACOSX_DEPLOYMENT_TARGET = 10.12"
    var deploymentVerMin = 0.0
    var deploymentVerMax = 0.0
    var swiftURLs       = [URL]()
    var swiftSummaries  = [SwiftSummary]()
    var targets         = PBXNativeTarget()
    var url = FileManager.default.homeDirectoryForCurrentUser   // from URL
}

//13 sections
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

//struct XCBuildConfiguration {
//    var name = ""                       // Release or Debug
//    var SDKROOT = ""                    // macosx
//    var SWIFT_VERSION = ""              // SWIFT_VERSION = 4.2
//    var TEST_HOST = ""                  // \"$(BUILT_PRODUCTS_DIR)/AnalyseSwiftCode.app/Contents/MacOS/AnalyseSwiftCode\""
//    var MACOSX_DEPLOYMENT_TARGET = ""   // MACOSX_DEPLOYMENT_TARGET = 10.12
//    var IPHONEOS_DEPLOYMENT_TARGET = "" // IPHONEOS_DEPLOYMENT_TARGET = 11.1
//    var PRODUCT_BUNDLE_IDENTIFIER = ""  // PRODUCT_BUNDLE_IDENTIFIER = com.georgebauer.analyseswiftcode
//}

// Struct to hold values set by .xcodeproj > project.pbxproj file
// To Add property:
//  1) "var XXX ="         (1 place);
//  2) func changeProperty (2 places)           case "XXX": self.XXX = vals.first ?? ""
//  3) "debugDescription"  (3 places) if !self.XXX.isEmpty    { str += ", XXX=" + self.XXX }
public struct PBX: CustomDebugStringConvertible {       //66-273 = 217-lines
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
    var ENABLE_STRICT_OBJC_MSGSEND = ""
    var PRODUCT_BUNDLE_IDENTIFIER  = ""

    mutating func changeProperty(propertyName: String, vals: [String]) {    //118-182 = 64-lines
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
        case "PRODUCT_BUNDLE_IDENTIFIER":   self.PRODUCT_BUNDLE_IDENTIFIER  = vals.first ?? ""
        case "ENABLE_STRICT_OBJC_MSGSEND":  self.ENABLE_STRICT_OBJC_MSGSEND = vals.first ?? ""
        default:
            let ignore =
            ["remoteGlobalIDString","remoteInfo","defaultConfigurationName",
             "explicitFileType","includeInIndex","buildActionMask","runOnlyForDeploymentPostprocessing",
             "developmentRegion","hasScannedForEncodings","knownRegions","buildPhases",
             "projectDirPath","projectRoot","targetProxy","defaultConfigurationIsVisible",
            ]
            if !ignore.contains(propertyName) {
                print("⛔️⛔️⛔️⛔️ \(propertyName) not handled! ⛔️⛔️⛔️⛔️")
            }

        }//end switch
    }//end func

    //---- debugDescription - used for print
    public var debugDescription: String {       //185-243 = 58-lines
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
            print("⛔️⛔️⛔️⛔️ No value for pbxDict[\(key)] ⛔️⛔️⛔️⛔️")
            return
        }
        if dict[key] == nil {
            dict[key] = PBX()
            if propertyName != "isa" {
                print("⛔️⛔️⛔️⛔️ Cannot set pbxDict[\(key)] = \(vals[0]), because it does't exist. ⛔️⛔️⛔️⛔️")
                return
            }
        }

        dict[key]!.changeProperty(propertyName: propertyName, vals: vals)

    }

}//end struct PBX

//MARK:- funcs

//MARK: analyseXcodeproj 89-lines
//---- analyseXcodeproj - Analyse a .xcodeproj file, returning an errorText and an XcodeProj instance
public func analyseXcodeproj(url: URL, goDeep: Bool) -> (String, XcodeProj) {   //277-366 = 89-lines
    xcodeProj = XcodeProj()
    xcodeProj.url = url
    xcodeProj.name = url.lastPathComponent
    let pbxprojURL = url.appendingPathComponent("project.pbxproj")

    do {
        let storedData = try String(contentsOf: pbxprojURL)

        preProcess(storedData)

        let xcodeprojLines = storedData.components(separatedBy: "\n")
        var gotBuildSettings = false

        // Scan pbxproj file for stuff not covered in preProcess()
        for (idx, line) in xcodeprojLines.enumerated() {
            let lineNum = idx+1

            if gotBuildSettings {       // In BuildSettings
               if line.contains("DEPLOYMENT_TARGET") {
                    print("✅ \(lineNum) \"DEPLOYMENT_TARGET\" \(line)")
                    let (key, val) = keyValDecode(line)
                    //let x = xcodeProj.DEPLOYMENT_TARGET
                    xcodeProj.deploymentTarget = key + " = " + val          // ???? xcodeProj.deploymentTarget

                } else if line.contains("SWIFT_VERSION") {

                } else if line.lowercased().contains("ver") && !line.contains("NVER") {
                    print("✅ \(lineNum) \"ver\" \(line)")
                }
            } else {
                if line.contains("buildSettings =") { gotBuildSettings = true }
                if line.contains("CreatedOnToolsVersion") {
                    (_, xcodeProj.createdOnToolsVersion) = keyValDecode(line)
                    print("✅ \(lineNum) \"CreatedOnToolsVersion\" \(line)")
                }
            }

        }//next line
        print()
        print("🍎 \(xcodeProj)")
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
        print("✅✅✅✅✅✅")
        print(xcodeProj)
        print("✅✅✅✅✅✅")
    }

    return ( "", xcodeProj)

}//end func analyseXcodeproj


func stripComments(_ line: String) -> String {      //369-401 = 32-lines
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

//MARK:preProcess 258-lines
func preProcess(_ str: String) {        //404-662 = 258-lines
    print("🏄‍♂️")
    print("🏄‍♂️ Uncomment to get a fresh copy of projectpbxproj.txt")
    //print(str)      // Use to copy & paste into text editor for debugging
    print("🏄‍♂️")
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
            if !bufrs[depth].hasSuffix("=") { print("⛔️ NO EQUAL SIGN ⛔️") }
            //print("🐯⬇️ bufrs[\(depth)]: \"\(bufrs[depth])\" { Getting properties ...")
            depth += 1
            bufrs.append("")

        } else if char == "}" {
            if depth > 0 && !bufrs[depth-1].hasSuffix("=") { print("⛔️ NO EQUAL SIGN ⛔️") }
            //print("🐯⬆️ bufrs[\(depth-1)]: \"\(bufrs[depth-1])\"")
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
                    if parts.count < 2 || parts[1].hasPrefix("isa =") { print() }   // blank line before "isa ="

                    if parts.count < 3 || parts[1] != "buildSettings" || !parts[2].contains("GCC") || !parts[2].contains("CLANG") {
                        print("↔️\(linePtr[ptrChar])-\(depth) \(parts)")
                    }

                    let assignee = parts[0]
                    let objKey = String(assignee.dropLast()).trim   // remove " =" from objKey
                    let isa0 = getAssigneeIsa(string: assignee, pbxObjects: pbxObjects)
                    if parts.count == 1 {
                        print(partLast)
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
                        //print("3parts:", parts)

                        if isa0 == "PBXProject" && parts[1] == "attributes =" {     // PBXProject > attributes
                            print("   PBXProject attribute: \(parts[2])")
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
                                print("😡3😡??? Unimplemented attribute: \"\(isa0)\", \"\(parts[1])\", \"\(parts[2])\" 😡😡")
                            }

                        } else if isa0 == "XCBuildConfiguration" && parts[1] == "buildSettings ="   {
                            if !parts[2].contains("GCC") && !parts[2].contains("CLANG") {
                                let (propertyName, vals) = getPropertyAndVals(from: parts[2])
                                let got1: Bool
                                switch propertyName {
                                case "SDKROOT"                   : got1 = true;
                                    print("Got SDKROOT")
                                case "SWIFT_VERSION"             : got1 = true
                                case "MACOSX_DEPLOYMENT_TARGET"  : got1 = true
                                case "IPHONEOS_DEPLOYMENT_TARGET": got1 = true
                                default: got1 = false
                                }
                                if got1 {
                                    print(objKey, pbxObjects[objKey] ?? "???")
                                    PBX.setDictPropertyPBX(dict: &pbxObjects, key: objKey, propertyName: propertyName, vals: vals)
                                    print(objKey, pbxObjects[objKey] ?? "???")
                                    print()
                                } else {
                                    print("😡3😡??? Unimplemented attribute \(isa0), \(parts[1]), \(parts[2]) 😡😡")
                                }

                            }
                        } else {
                            print("😡😡??", isa0, parts[1], parts[2], "😡😡")
                        }

                    } else {    // parts.count > 3
                        if parts[1] != "attributes =" || parts[2] != "TargetAttributes =" {
                            print("😡\(parts.count)😡??? Unimplemented TargetAttributes \(isa0), \(parts[1]), \(parts[2]) 😡😡")
                        }
                        // ↔️183-6 ["26ECD32F1E874B5B00380F56 =", "attributes =", "TargetAttributes =", "26ECD3361E874B5B00380F56 =", "CreatedOnToolsVersion = 8.2.1"]
                        let targetKey = String(parts[3].dropLast()).trim   // remove " =" from objKey
                        let (propertyName, vals) = getPropertyAndVals(from: parts[2])
                        let got1: Bool
                        switch propertyName {
                        case "CreatedOnToolsVersion" : got1 = true
                        case "LastSwiftMigration"    : got1 = true
                        case "TestTargetID"          : got1 = true
                        default: got1 = false
                        }
                        if got1 {
                            PBX.setDictPropertyPBX(dict: &pbxObjects, key: targetKey, propertyName: propertyName, vals: vals)
                        } else {
                            print("😡\(parts.count)😡??? Unimplemented attribute \(isa0), \(parts[1]), \(parts[2]) 😡😡")
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

    //"SDKROOT", "MACOSX_DEPLOYMENT_TARGET = 10.12", "SWIFT_VERSION = 4.2", "CreatedOnToolsVersion = 9.2"
    //xcodeProj.sdkRoot, xcodeProj.deploymentTarget, xcodeProj.swiftVerMin, xcodeProj.swiftVerMax, xcodeProj.createdOnToolsVersion

    //Analyse rootObject

    //RootObject
    print("\n\(#line) ----0 Root Object [PBXProject] ------------------------")
    let rootObject = pbxObjects[rootObjectKey]!
    print(rootObjectKey, rootObject)

    //RootObject > mainGroup
    let mainGroupKey = rootObject.mainGroup
    let mainGroupObj = pbxObjects[mainGroupKey]!
    print()
    print("\n\(#line) --------1 rootObject > mainGroup [PBXGroup] ------------")
    print(mainGroupKey, mainGroupObj)

    let mainGroupChildrenKeys = mainGroupObj.children
    var mainSourceKey = ""
    var mainSourceObj = PBX()

    print("\n\(#line) --------1 RootObject.mainGroup > \(mainGroupChildrenKeys.count)-children [PBXGroup] ------------")
    // find Most likely child to have swift source files
    for ( i, childKey) in mainGroupChildrenKeys.enumerated() {
        let childObj = pbxObjects[childKey]!
        print()
        print("\(#line) ------------2 rootObject.mainGroup.child[\(i)] [PBXGroup] --------")
        print(childKey, pbxObjects[childKey] ?? "⛔️ #line-\(#line)Error: Missing mainGroupChildrenKey")
        if i == 0 {
            mainSourceKey = childKey            // first child is usually the program
            if !isTestOrProductOrFramework(name: childObj.name) { break }
        }
        if !isTestOrProductOrFramework(name: childObj.name) {
            mainSourceKey = childKey
            break
        }
    }

    //RootObject > productRefGroup
    let productRefGroupKey = rootObject.productRefGroup
    print("\n\(#line) --------1 rootObject.productRefGroup [PBXGroup] - children are [PBXFileReference] ------------")
    print("              * Same as mainGroup.child named \"Products\"")
    print(productRefGroupKey, pbxObjects[productRefGroupKey] ?? "⛔️ #line-\(#line)Error: Missing rootObject.productRefGroup")

    //RootObject > buildConfigurationList
    let buildConfigurationListKey = rootObject.buildConfigurationList
    print("\n\(#line) --------1 rootObject.buildConfigurationList [XCConfigurationList] - children are [XCBuildConfiguration] ------------")
    print(buildConfigurationListKey, pbxObjects[buildConfigurationListKey] ?? "⛔️ #line-\(#line)Error: Missing rootObject.buildConfigurationList")

    let rootbuildConfigurationListKey = rootObject.buildConfigurationList
    let rootbuildConfigurationListObj = pbxObjects[rootbuildConfigurationListKey]!
    for (i, buildConfigurationKey) in rootbuildConfigurationListObj.buildConfigurations.enumerated() {
        let buildConfigurationObj = pbxObjects[buildConfigurationKey]!
        print("\n\(#line) ------------2 rootObject.buildConfigurationList.buildConfiguration[\(i)] [PBXBuildConfiguration] --------")
        print(buildConfigurationKey, pbxObjects[buildConfigurationKey] ?? "⛔️ #line-\(#line)Error: Missing rootObject.buildConfigurationKey")
        let sdkroot = buildConfigurationObj.SDKROOT
        print("🔹 \(buildConfigurationKey) SDKROOT = \"\(sdkroot)\"")
        if !sdkroot.isEmpty {
            if !xcodeProj.sdkRoot.isEmpty && xcodeProj.sdkRoot != sdkroot {
                print("⛔️⛔️ sdkRoot mismatch: \(xcodeProj.sdkRoot) != \(sdkroot)  ⛔️⛔️")
            } else {
                xcodeProj.sdkRoot = sdkroot
            }
        }
    }//next


    //RootObject > targets
    let targetKeys = rootObject.targets
    print("\n\(#line) --------1 RootObject > \(targetKeys.count)-targets [PBXNativeTarget] ------------")
    for ( i, targetKey) in targetKeys.enumerated() {
        print("\n\(#line) ------------2 rootObject.target[\(i)] [PBXNativeTarget] --------")
        print(targetKey, pbxObjects[targetKey] ?? "⛔️ #line-\(#line)Error: Missing rootObject.targetKey")
    }

print("----------------------------------------------------------------")

    if !mainSourceKey.isEmpty {
        mainSourceObj = pbxObjects[mainSourceKey]!
        print()
        print("---- Most likely child to have swift source files [PBXGroup]. Children are [PBXFileReference] ----")
        print("mainSourceObj = ",mainSourceObj)
        let dirPath = mainSourceObj.path.replacingOccurrences(of: "\"", with: "")
        print()
        print("😈mainSourceObj.path = \"\(dirPath)\"")
        let sourceFileKeys = mainSourceObj.children
        for sourceFileKey in sourceFileKeys {
            let sourceFileObj = pbxObjects[sourceFileKey]!
            let filePath = sourceFileObj.path
            if filePath.hasSuffix(".swift") {
                let url = xcodeProj.url.deletingLastPathComponent().appendingPathComponent(dirPath).appendingPathComponent(filePath)
                xcodeProj.swiftURLs.append(url)
                print(url.path)
            }
            print("😈", sourceFileObj)
        }
    }

    // Set SDKROOT, SWIFT_VERSION, MACOSX_DEPLOYMENT_TARGET
    for targetKey in rootObject.targets {
        guard let targetObj = pbxObjects[targetKey] else { continue }
        let buildConfigurationListKey = targetObj.buildConfigurationList
        if buildConfigurationListKey.isEmpty { continue }
        guard let buildConfigurationListObj = pbxObjects[buildConfigurationListKey] else { continue }
        for buildConfigurationKey in buildConfigurationListObj.buildConfigurations {
            guard let  buildConfigurationObj = pbxObjects[buildConfigurationKey] else { continue }

            let swiftVer = buildConfigurationObj.SWIFT_VERSION
            let ver = getVersionNumber(text: swiftVer)
            if ver > xcodeProj.swiftVerMax { xcodeProj.swiftVerMax = ver }
            if xcodeProj.swiftVerMin == 0.0 || ver < xcodeProj.swiftVerMin { xcodeProj.swiftVerMin = ver }
            print("🔹 \(buildConfigurationKey) SWIFT_VERSION = \"\(swiftVer)\"")

            let macOSXDeploymentTarget = buildConfigurationObj.MACOSX_DEPLOYMENT_TARGET
            let iPhoneOSDeploymentTarget = buildConfigurationObj.IPHONEOS_DEPLOYMENT_TARGET
            if !iPhoneOSDeploymentTarget.isEmpty {
                if xcodeProj.deploymentTarget == "MacOS" {
                    print("⛔️⛔️ #line \(#line) deploymentTarget mismatch ⛔️⛔️")
                }
                xcodeProj.deploymentTarget = "iPhoneOS"
                print("🔹 \(buildConfigurationKey) IPHONEOS_DEPLOYMENT_TARGET = \"\(iPhoneOSDeploymentTarget)\"")
            }
            if !macOSXDeploymentTarget.isEmpty {
                if xcodeProj.deploymentTarget == "iPhoneOS" {
                    print("⛔️⛔️ #line \(#line) deploymentTarget mismatch ⛔️⛔️")
                }
                xcodeProj.deploymentTarget = "MacOS"
                print("🔹 \(buildConfigurationKey) MACOSX_DEPLOYMENT_TARGET = \"\(macOSXDeploymentTarget)\"")
            }

        }//next buildConfigurationKey
    }//next targetKey

    print("\n--------------------------------------------------\n")
}//end func preProcess

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
func stripCommentsAndNewlines(_ str: String) -> (String, [Int]) {       //702-751 = 49-lines
    if str.contains("//") {
        print("⛔️⛔️⛔️ Contains \" // \"")
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

public func showXcodeproj(_ xcodeProj: XcodeProj) -> NSAttributedString  {
    var text = ""
    text += "          ---------------- \(xcodeProj.name) ----------------\n"
    if xcodeProj.swiftVerMin != xcodeProj.swiftVerMax {
        text += "Multiple Swift Versions: \(xcodeProj.swiftVerMin) & \(xcodeProj.swiftVerMax)\n"
    } else {
        if xcodeProj.swiftVerMin == 0.0 {
            text += "No Swift Version found!\n"
        } else {
            text += "Swift Version used = \(xcodeProj.swiftVerMin)\n"
        }
    }

    text += "ArchiveVersion = \(xcodeProj.archiveVersion)\n"
    text += "ObjectVersion = \(xcodeProj.objectVersion)\n"
    text += "createdOnToolsVersion = \(xcodeProj.createdOnToolsVersion)\n"
    text += "sdkRoot = \(xcodeProj.sdkRoot)\n"
    text += "\(xcodeProj.deploymentTarget)\n"    // deploymentTarget

    var totalCodeLineCount     = 0
    var totalNonCamelCaseCount = 0
    var totalForceUnwrapCount  = 0
    var totalVbCompatCallCount = 0

    text += "\n                           ---- \(xcodeProj.swiftURLs.count) Swift files ----\n"
    text += "------ FileName ------     CodeLines  NonCamelCase  ForceUnwrap VBcompatability\n"
    for swiftSummary in xcodeProj.swiftSummaries {
        let name = swiftSummary.fileName
        let isTest = swiftSummary.url.path.contains("TestSharedCode")
        if isTest || (name != "VBcompatablity.swift" && name != "MyFuncs.swift" && name != "StringExtension.swift") {
            let c1 = swiftSummary.codeLineCount
            totalCodeLineCount      += c1
            let c2 = swiftSummary.nonCamelCases.count
            totalNonCamelCaseCount  += c2
            let c3 = swiftSummary.forceUnwraps.count
            totalForceUnwrapCount   += c3
            let c4 = swiftSummary.vbCompatCalls.count
            totalVbCompatCallCount  += c4
            //text += "\(swiftSummary.url.lastPathComponent)  -  nonCamel \(swiftSummary.nonCamelCases.count)\n"
            text += format2(swiftSummary.url.lastPathComponent,c1,c2,c3,c4)
        } else {
            text += "(\(swiftSummary.url.lastPathComponent))\n"
        }
    }//next
    text += "\n\(format2("  -- Totals --",totalCodeLineCount,totalNonCamelCaseCount,totalForceUnwrapCount,totalVbCompatCallCount))\n"
//    text += "\n\(totalCodeLineCount) total CodeLines.\n"

    text += "\n-------- Possible Issues --------\n"
    text += "\(totalNonCamelCaseCount) total NonCamelCase Variables.\n"
    text += "\(totalForceUnwrapCount) total ForceUnwraps.\n"
    text += "\(totalVbCompatCallCount) total VBcompatabiliy Calls.\n"

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
