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
    var createdOnToolsVersion = ""  //???? from targets
    var swiftVerMin     = 0.0       // from XCBuildConfiguration.buildSettings."SWIFT_VERSION = 4.2"
    var swiftVerMax     = 0.0
    var sdkRoot         = ""        // from XCBuildConfiguration.buildSettings.SDKROOT = macosx
    var deploymentTarget = ""       // from XCBuildConfiguration.buildSettings."MACOSX_DEPLOYMENT_TARGET = 10.12"
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

struct XCBuildConfiguration {
    var name = ""                               // Release or Debug
    var buildSettingSDKROOT = ""                // macosx
    var buildSettingSWIFT_VERSION = ""          // SWIFT_VERSION = 4.2
    var buildSettingTEST_HOST = ""              // \"$(BUILT_PRODUCTS_DIR)/AnalyseSwiftCode.app/Contents/MacOS/AnalyseSwiftCode\""
    var buildSettingMACOSX_DEPLOYMENT_TARGET = "" // MACOSX_DEPLOYMENT_TARGET = 10.12
    var buildSettingPRODUCT_BUNDLE_IDENTIFIER = "" // PRODUCT_BUNDLE_IDENTIFIER = com.georgebauer.analyseswiftcode
}

/*
"name =" occurs in PBXFileReference, PBXGroup, PBXNativeTarget, PBXVariantGroup, XCBuildConfiguration
 */

// Struct to hold values set by .xcodeproj > project.pbxproj file
// To Add property:
//  1) "var XXX ="         (1 place);
//  2) func changeProperty (2 places)           case "XXX": self.XXX = vals.first ?? ""
//  3) "debugDescription"  (3 places) if !self.XXX.isEmpty    { str += ", XXX=" + self.XXX }
public struct PBX: CustomDebugStringConvertible {       //64-239 = 175-lines
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


    mutating func changeProperty(propertyName: String, vals: [String]) {
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
        case "productReference":    self.productReference = vals.first ?? ""
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
        case "LastSwiftUpdateCheck":  self.LastSwiftUpdateCheck = vals.first ?? ""
        case "LastUpgradeCheck":  self.LastUpgradeCheck = vals.first ?? ""
        case "ORGANIZATIONNAME":  self.ORGANIZATIONNAME = vals.first ?? ""

        // buildSettings
        case "CreatedOnToolsVersion":  self.CreatedOnToolsVersion = vals.first ?? ""
        case "LastSwiftMigration":  self.LastSwiftMigration = vals.first ?? ""
        case "TestTargetID":  self.TestTargetID = vals.first ?? ""

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
    public var debugDescription: String {       //72-105
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
        if !self.CreatedOnToolsVersion.isEmpty { str += "\(sep)CreatedOnToolsVersion = " + self.CreatedOnToolsVersion }
        if !self.LastSwiftMigration.isEmpty    { str += "\(sep)LastSwiftMigration = " + self.LastSwiftMigration }
        if !self.TestTargetID.isEmpty          { str += "\(sep)TestTargetID = " + self.TestTargetID }
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

//MARK: analyseXcodeproj 81-lines
//---- analyseXcodeproj - Analyse a .xcodeproj file, returning an errorText and an XcodeProj instance
public func analyseXcodeproj(url: URL, goDeep: Bool) -> (String, XcodeProj) {   //245-326 = 81-lines
    xcodeProj = XcodeProj()
    xcodeProj.url = url
    xcodeProj.name = url.lastPathComponent
    let pbxprojURL = url.appendingPathComponent("project.pbxproj")

    do {
        let storedData = try String(contentsOf: pbxprojURL)

        preProcess(storedData)

        let xcodeprojLines = storedData.components(separatedBy: "\n")
        var gotBuildSettings = false
        for (idx, line) in xcodeprojLines.enumerated() {
            let lineNum = idx+1

            if gotBuildSettings {       // In BuildSettings
                if line.contains("SDKROOT") {
                    (_, xcodeProj.sdkRoot) = keyValDecode(line)             // ???? xcodeProj.sdkRoot
                    if idx < 11 { print("✅ \(lineNum) \"SDKROOT\" \(line)") }
                } else if line.contains("DEPLOYMENT_TARGET") {
                    print("✅ \(lineNum) \"DEPLOYMENT_TARGET\" \(line)")
                    let (key, val) = keyValDecode(line)
                    xcodeProj.deploymentTarget = key + " = " + val          // ???? xcodeProj.deploymentTarget
                } else if line.contains("SWIFT_VERSION") {
                    print("✅ \(lineNum) \"SWIFT_VERSION\" \(line)")
                    let (_, val) = keyValDecode(line)
                    let ver = getVersionNumber(text: val)
                    if val.count > 3 && ver == 0 {
                        print("😡 Could not decode Version: \(val)")    //Debug Trap
                    }

                    if xcodeProj.swiftVerMin == 0.0 || ver < xcodeProj.swiftVerMin {
                        xcodeProj.swiftVerMin = ver                         // ???? xcodeProj.swiftVerMin
                    }
                    if ver > xcodeProj.swiftVerMax {
                        xcodeProj.swiftVerMax = ver                         // ???? xcodeProj.swiftVerMax
                    }

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

            //let (isa, dict) = disectLine(line)


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
                print("😡analyseContentsButtonClicked error: \(error)")
            }//end try catch
        }
        print("✅✅✅✅✅✅")
        print(xcodeProj)
        print("✅✅✅✅✅✅")
    }

    return ( "", xcodeProj)

}//end func analyseXcodeproj


func stripComments(_ line: String) -> String {      //329-361 = 32-lines
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

//MARK:preProcess 201-lines
func preProcess(_ str: String) {        //364-565 = 201-lines
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
                            default                     : got1 = false; print("😡😡??? \(propertyName) = \(vals[0]) 😡😡")
                            }
                            if got1 {
                                PBX.setDictPropertyPBX(dict: &pbxObjects, key: objKey, propertyName: propertyName, vals: vals)
                            } else {
                                print("😡😡??? Unimplemented attribute \(isa0), \(parts[1]), \(parts[2]) 😡😡")
                            }

                        } else if isa0 == "XCBuildConfiguration" && parts[1] == "buildSettings ="   {
                            if !parts[2].contains("GCC") && !parts[2].contains("CLANG") {
                                print("😡??? Unimplemented buildSetting \(isa0), \(parts[1]), \(parts[2]) 😡")
                            }
                        } else {
                            print("😡😡??", isa0, parts[1], parts[2], "😡😡")
                        }

                    } else {
                        if parts[1] != "attributes =" || parts[2] != "TargetAttributes =" {
                            print("😡😡??? Unimplemented TargetAttributes \(isa0), \(parts[1]), \(parts[2]) 😡😡")
                        }
                        // ↔️183-6 ["26ECD32F1E874B5B00380F56 =", "attributes =", "TargetAttributes =", "26ECD3361E874B5B00380F56 =", "CreatedOnToolsVersion = 8.2.1"]
                        let targetKey = String(parts[3].dropLast()).trim   // remove " =" from objKey
                        let (propertyName, vals) = getPropertyAndVals(from: parts[2])
                        let got1: Bool
                        switch propertyName {
                        case "CreatedOnToolsVersion" : got1 = true
                        case "LastSwiftMigration"    : got1 = true
                        case "TestTargetID"          : got1 = true
                        default                      : got1 = false; print("😡😡??? \(propertyName) = \(vals[0]) 😡😡")
                        }
                        if got1 {
                            PBX.setDictPropertyPBX(dict: &pbxObjects, key: targetKey, propertyName: propertyName, vals: vals)
                        } else {
                            print("😡😡??? Unimplemented attribute \(isa0), \(parts[1]), \(parts[2]) 😡😡")
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

    // rootObject -> mainGroup              -> 3-children (prog, unit-tests, product)
    //            -> productRefGroup
    //            -> buildConfigurationList
    //            -> targets

    //Analyse rootObject
    print()
    print("----------- Root Object ------------")
    let rootObject = pbxObjects[rootObjectKey]!
    print(rootObjectKey, rootObject)

    let mainGroupKey = rootObject.mainGroup
    let mainGroupObj = pbxObjects[mainGroupKey]!
    print()
    print("rootObject.mainGroup",mainGroupObj)

    let mainGroupChildrenKeys = mainGroupObj.children
    var mainSourceKey = ""
    var mainSourceObj = PBX()

    print("\nrootObject.mainGroup", mainGroupObj)

    let productRefGroupKey = rootObject.productRefGroup
    print()
    print("rootObject.productRefGroup",pbxObjects[productRefGroupKey]!)

print("\n------------ RootObject > mainGroup > \(mainGroupChildrenKeys.count)-children ------------")
    for ( i, childKey) in mainGroupChildrenKeys.enumerated() {
        let childObj = pbxObjects[childKey]!
        print()
        print("rootObject.mainGroup.child[\(i)]")
        print(childKey, pbxObjects[childKey]!)
        if i == 0 || ( childObj.name != "Products" && !childObj.path.hasSuffix("Tests") ) {
            mainSourceKey = childKey
        }
    }
    print("----------------------------------------------------------------")


    if !mainSourceKey.isEmpty {
        mainSourceObj = pbxObjects[mainSourceKey]!
        print()
        print("---- Most likely child to have swift source files ----")
        print("mainSourceObj = ",mainSourceObj)
        let dirPath = mainSourceObj.path
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

    let targetKeys = rootObject.targets
    print("\n------------ RootObject > \(targetKeys.count)-targets ------------")
    for ( i, targetKey) in targetKeys.enumerated() {
        print()
        print("rootObject.target[\(i)]")
        print(targetKey, pbxObjects[targetKey]!)
    }

    print("\n--------------------------------------------------\n")
}//end func preProcess

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
    var valStr = comps[1].trim
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
func stripCommentsAndNewlines(_ str: String) -> (String, [Int]) {       //605-654 = 49-lines
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

//let attributesLargeFont  = [NSAttributedStringKey.font: NSFont.systemFont(ofSize: 20), NSAttributedStringKey.paragraphStyle: paragraphStyleA1]
//let attributesMediumFont = [NSAttributedStringKey.font: NSFont.systemFont(ofSize: 16), NSAttributedStringKey.paragraphStyle: paragraphStyleA1]
//let attributesSmallFont  = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 12), NSAttributedString.Key.paragraphStyle: paragraphStyleA1]
//var attTxt  = NSMutableAttributedString(string: "", attributes: attributesSmallFont)

public func showXcodeproj(_ xcodeProj: XcodeProj) -> NSAttributedString  {
    var text = "Oldest Swift Version used = \(xcodeProj.swiftVerMin)\n"
    if xcodeProj.swiftVerMin == 0.0 { text = "No Swift Version found!\n" }
    if xcodeProj.swiftVerMin != xcodeProj.swiftVerMax {
        text += "Multiple Swift Versions: \(xcodeProj.swiftVerMin) & \(xcodeProj.swiftVerMax)\n"
    }
    text += "ArchiveVersion = \(xcodeProj.archiveVersion)\n"
    text += "ObjectVersion = \(xcodeProj.objectVersion)\n"
    text += "createdOnToolsVersion = \(xcodeProj.createdOnToolsVersion)\n"
    text += "sdkRoot = \(xcodeProj.sdkRoot)\n"
    text += "\(xcodeProj.deploymentTarget)\n"    // deploymentTarget
    text += "\(xcodeProj.swiftURLs.count) Swift files."


    let textAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font: NSFont.systemFont(ofSize: 18),
        NSAttributedString.Key.paragraphStyle: NSParagraphStyle.default
    ]
    let formattedText = NSMutableAttributedString(string: text, attributes: textAttributes)
    return formattedText
}
