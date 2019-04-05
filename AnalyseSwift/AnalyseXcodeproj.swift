//
//  AnalyseXcodeproj.swift
//  AnalyseSwiftCode
//
//  Created by George Bauer on 11/8/18.
//  Copyright © 2018,2019 George Bauer. All rights reserved.//

import Cocoa

//MARK:- Globals

private var pbxObjects = [String: PBX]()
private var xcodeProj  = XcodeProj()
private var rootObjectKey  = ""

//MARK:- structs

//TODO: Move to another file. Change to caseless enum
public struct IssuePreferences {
    // swift file
    static var maxFileCodeLines = 500
    static var maxFuncCodeLines = 130
    static var underscoreAllowed = false
    // xcodeproj file
    static var diffentProductNameAllowed = false
    static var allowedOrganizations = ["GeorgeBauer","georgebauer"]
    static var minumumSwiftVersion = 4.0
}

public struct XcodeProj {
    var filename             = ""   // from URL
    var appName              = ""   // from app target
    var productName          = ""   // from app target
    var archiveVersion       = ""   // base level
    var objectVersion        = ""   // base level
    var organizationName     = ""   // root object
    var compatibilityVersion = ""   // root object
    var lastSwiftUpdateCheck = ""   // root object
    var lastUpgradeCheck     = ""   // root object
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
    var name                = ""    // "AnalyseSwiftCode"
    var productName         = ""    // "FileSpy"
    var productType         = ""    // "com.apple.product-type.application" or "com.apple.product-type.bundle.unit-test"
    var productReference    = ""    // key - PBXFileReference
    var buildConfigurationListKey = "" // key - XCConfigurationList contains 2 buildConfigurations(Debug & Release) >
// PBXProject section > attributes > TargetAttributes
    var TestTargetID        = ""    // 26ECD3361E874B5B00380F56
    var DevelopmentTeam     = ""    // XD8UZ6484B
    var LastSwiftMigration  = ""    // 1010
    var createdOnToolsVersion = ""  // 8.2.1
    var ORGANIZATIONNAME    = ""    // ORGANIZATIONNAME = "Ray Wenderlich"
}

//MARK:- funcs

//MARK: analyseXcodeproj 40-lines
//---- analyseXcodeproj - Analyse a .xcodeproj file, returning an errorText and an XcodeProj instance
public func analyseXcodeproj(url: URL, goDeep: Bool, deBug: Bool = true) -> (String, XcodeProj) {   //72-112 = 40-lines
    xcodeProj = XcodeProj()
    xcodeProj.url       = url
    xcodeProj.filename  = url.lastPathComponent
    let pbxprojURL    = url.appendingPathComponent("project.pbxproj")
    let urlFile       = URL(fileURLWithPath: #file)
    let swiftFilename = urlFile.lastPathComponent
    print("\n🔷 \(swiftFilename) line#\(#line) Start processing 😃\(xcodeProj.filename)😃")

    do {
        let storedData = try String(contentsOf: pbxprojURL)
        pbxToXcodeProj(storedData, deBug: deBug)
        if deBug {print("\n🍎 \(xcodeProj)")}
    } catch {
        return  ( "Error: Could not read \"\(pbxprojURL.lastPathComponent)\"\n\(pbxprojURL.path)", xcodeProj)
    }

    // Read & analyse the individual Swift files.
    if goDeep {
        xcodeProj.swiftSummaries = []
        for url in xcodeProj.swiftURLs {
            let fileInfo = FileAttributes.getFileInfo(url: url)       // set selecFileInfo (name,dates,size,type)

            do {
                let contentFromFile = try String(contentsOf: url, encoding: String.Encoding.utf8)
                let (swiftSummary, _) = analyseSwiftFile(contentFromFile: contentFromFile, selecFileInfo: fileInfo, deBug: false )
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

//MARK: pbxToXcodeProj 218-lines
//TODO: Needs to retrurn xcodeProj, errorMsg, pbxObjects, rootObjectKey
func pbxToXcodeProj(_ xcodeprojRaw: String, deBug: Bool = true) {        //116-334 = 218-lines
    if deBug {
        print("Start pbxToXcodeProj")
        print("🏄‍♂️")
        print("🏄‍♂️ Uncomment to get a fresh copy of projectpbxproj.txt")
        //print(xcodeprojRaw)      // Use to copy & paste into text editor for debugging
        print("🏄‍♂️")
        //altParser(xcodeprojRaw)
    }
    pbxObjects.removeAll()
    let (strClean,linePtr) = cleanRawText(xcodeprojRaw)
    let chars = Array(strClean)
    var depth = 0
    var bufrs = [String]()
    bufrs.append("")

    // Go through file char by char
    for ptrChar in 0..<chars.count {    //133-165 = 32-lines
        let char = chars[ptrChar]

        if char == "{" {                                    // ------ "{"
            bufrs[depth] = bufrs[depth].trim    //cleanup parent
            if !bufrs[depth].hasSuffix("=") && !bufrs[depth].isEmpty  {
                print("⛔️ #\(#line) NO EQUAL SIGN in \"\(bufrs[depth])\" ⛔️")
            }
            //if deBug { print("🐯⬇️ bufrs[\(depth)]: \"\(bufrs[depth])\" { Getting properties ...")}
            depth += 1              // go deeper
            bufrs.append("")        // make an empty bufr for this new depth

        } else if char == "}" {                             // ------ "}"
            // done with this bufr
            if depth > 0 && !bufrs[depth-1].isEmpty && !bufrs[depth-1].hasSuffix("=") {
                print("⛔️ #\(#line) NO EQUAL SIGN in \"\(bufrs[depth])\" ⛔️")
            }
            //if deBug {print("🐯⬆️ bufrs[\(depth-1)]: \"\(bufrs[depth-1])\"")}
            bufrs.removeLast()
            depth -= 1

        } else if char == ";" {                             // ------ ";"
            // process the item in this bufr
            let lineNumber = linePtr[ptrChar]
            gotSemicolon(lineNumber: lineNumber, depth: depth, bufrs: bufrs, deBug: deBug)
            bufrs[depth] = ""   // empty this bufr

        } else {                                            // ------ not "{" or "}" or ";"
            // keep building this bufr
            bufrs[depth].append(char)
        }

    }//next ptrChar

    //=========================================

    // rootObject[pbxObjects] -> mainGroup[pbxGroup]    -> children (prog, unit-tests, product, framework)[pbxGroup]
    //        -> productRefGroup[pbxGroup]      name=Products   -> 3-children (.app, .xctest, .xctest)[PBXFileReference]
    //        -> buildConfigurationList
    //        -> targets[PBXNativeTarget]

    //Analyse rootObject

    //RootObject
    let rootObject = pbxObjects[rootObjectKey]!                 // Root Object

    if deBug {
        print("\n\(#line) ----0 Root Object [PBXProject] ------------------------")
        print(rootObjectKey, rootObject)
    }

    //RootObject > mainGroup
    let mainGroupKey = rootObject.mainGroup
    let mainGroupObj = pbxObjects[mainGroupKey]!                // MainGroup Object
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
    xcodeProj.lastSwiftUpdateCheck = rootObject.LastSwiftUpdateCheck
    xcodeProj.lastUpgradeCheck     = rootObject.LastUpgradeCheck
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
        let xcodeSourcesURL = xcodeProj.url.deletingLastPathComponent().appendingPathComponent(dirPath)
        for sourceFileKey in sourceFileKeys {
            let sourceFileObj = pbxObjects[sourceFileKey]!
            let fileName = sourceFileObj.path.replacingOccurrences(of: "\"", with: "")
            if sourceFileObj.children.isEmpty {
                if fileName.hasSuffix(".swift") {
                    let url = xcodeSourcesURL.appendingPathComponent(fileName)
                    xcodeProj.swiftURLs.append(url)
                    if deBug {print(url.path)}
                }
            } else {
                addSourceURLsFromSubFolder(thisURL: xcodeSourcesURL, sourceFileObj: sourceFileObj, deBug: deBug)
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
                if deBug {print("⚠️ MACOSX_DEPLOYMENT_TARGET found in Target buildConfiguration")}
                //xcodeProj.deploymentTarget = "macOS Deployment Target = " + macOSXDeploymentTarget
            }
            if !iPhoneOSDeploymentTarget.isEmpty {
                if deBug {print("⚠️ IPHONEOS_DEPLOYMENT_TARGET found in Target buildConfiguration")}
                //xcodeProj.deploymentTarget = "iPhoneOS Deployment Target = " + iPhoneOSDeploymentTarget
            }

        }//next buildConfigurationKey
    }//next targetKey

    if deBug {print("\n--------------------------------------------------\n")}
}//end func pbxToXcodeProj

//---- addSourceURLsFromSubFolder - Recursive to get source files from subdirectories
private func addSourceURLsFromSubFolder(thisURL: URL, sourceFileObj: PBX, deBug: Bool) {
    let folderName = sourceFileObj.path.replacingOccurrences(of: "\"", with: "")
    if folderName.isEmpty { return }
    let folderURL = thisURL.appendingPathComponent(folderName)
    //let folderPath = folderURL.path
    for childKey in sourceFileObj.children {
        if let childFileObj = pbxObjects[childKey] {
            if childFileObj.children.isEmpty {
                let fileName = childFileObj.path
                if fileName.hasSuffix(".swift") {
                    let url = folderURL.appendingPathComponent(fileName)
                    if deBug {print(url.path)}
                    xcodeProj.swiftURLs.append(url)
                }
            } else {
                print("⛔️ Error #line \(#line) files more tha 2 deep \"\(folderURL)\": \"\(childFileObj.path)\"")
                addSourceURLsFromSubFolder(thisURL: folderURL, sourceFileObj: childFileObj, deBug: deBug)
            }
        } else {
            print("⛔️ Error #line \(#line)")
        }//nil
    }//next childKey
}//end func

//---- gotSemicolon - Process the item in this bufr. 362-477 = 115-lines
private func gotSemicolon(lineNumber: Int, depth: Int, bufrs: [String], deBug: Bool) {
    // Modifys xcodeProj, pbxObjects
    var parts = [String]()
    var start = 1
    if depth >= 1 && bufrs[1] == "objects =" { start = 2 }

    if depth >= start {
        for d in start...depth {
            parts.append(bufrs[d].trim)
        }//next
    }
    guard  let partLast = parts.last else { return }
    if !partLast.hasSuffix("=") {

        if deBug {
            if parts.count < 2 || parts[1].hasPrefix("isa =") { print() }   // blank line before "isa ="
            if parts.count < 3 || parts[1] != "buildSettings" || !parts[2].contains("GCC") || !parts[2].contains("CLANG") {
                print("↔️\(lineNumber)-\(depth) \(parts)")
            }
        }

        let assignee = parts[0]
        let objKey   = String(assignee.dropLast()).trim   // remove " =" from objKey
        let isa0     = getAssigneeIsa(string: assignee, pbxObjects: pbxObjects)
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
                print("😡 Unhandled line \(lineNumber) \"\(partLast)\" 😡😡")
            }
        } else if parts.count == 2 {
            if assignee.hasSuffix("=") {
                let (propertyName, vals) = getPropertyAndVals(from: parts[1])
                PBX.setDictPropertyPBX(dict: &pbxObjects, key: objKey, propertyName: propertyName, vals: vals)
            }
        } else if parts.count == 3 {

            // PBXProject > attributes
            if isa0 == "PBXProject" && parts[1] == "attributes =" {     // PBXProject > attributes
                if deBug { print("   PBXProject attribute: \(parts[2])") }
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

                // XCBuildConfiguration" > buildSetting >
            } else if isa0 == "XCBuildConfiguration" && parts[1] == "buildSettings ="   {
                if !parts[2].contains("GCC") && !parts[2].contains("CLANG") {
                    let (propertyName, vals) = getPropertyAndVals(from: parts[2])
                    let got1: Bool
                    switch propertyName {
                    case "SDKROOT"                   : got1 = true
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

            // PBXProject > attributes > TargetAttributes > objKey >
            if parts[1] != "attributes =" || parts[2] != "TargetAttributes =" {
                if deBug {print("😡\(parts.count)😡??? Unimplemented TargetAttributes \(isa0), \(parts[1]), \(parts[2]) 😡😡")}
            }
            // ↔️183-6 ["26ECD32F1E874B5B00380F56 =", "attributes =", "TargetAttributes =", "26ECD3361E874B5B00380F56 =", "CreatedOnToolsVersion = 8.2.1"]
            let targetKey = String(parts[3].dropLast()).trim   // remove " =" from objKey
            let (propertyName, vals) = getPropertyAndVals(from: parts[4])
            let got1: Bool
            switch propertyName {
            case "CreatedOnToolsVersion": got1 = true   //"CreatedOnToolsVersion = 8.2.1"
            case "LastSwiftMigration"   : got1 = true   //"LastSwiftMigration = 1010"
            case "TestTargetID"         : got1 = true   //"TestTargetID = 26ECD3361E874B5B00380F56" (only for unit or UI Testing)
            default: got1 = false
            }
            if got1 {
                PBX.setDictPropertyPBX(dict: &pbxObjects, key: targetKey, propertyName: propertyName, vals: vals)
            } else {
                if deBug {print("😡\(parts.count)😡??? Unimplemented attribute \(isa0), \(parts[1]), \(parts[2]) 😡😡")}
            }

            /* Other TargetAttributes
             "DevelopmentTeam = XD8UZ6484B"
             "ProvisioningStyle = Automatic"
             */
        }
    }
}//end func gotSemicolon

//---- updateDeploymentTarget - to macOS, iPhoneOS, WatchOS, tvOS
private func updateDeploymentTarget(buildConfigurationObj: PBX) {
    // Modifys xcodeProj
    var os = "macOS"    //    "macOS Deployment Target = "
    var deploymentTarget = buildConfigurationObj.MACOSX_DEPLOYMENT_TARGET
    if deploymentTarget.isEmpty {
        os = "iPhoneOS"
        deploymentTarget = buildConfigurationObj.IPHONEOS_DEPLOYMENT_TARGET
    }
    if deploymentTarget.isEmpty {
        deploymentTarget = buildConfigurationObj.WATCHOS_DEPLOYMENT_TARGET
        os = "WatchOS"
    }
    if deploymentTarget.isEmpty {
        deploymentTarget = buildConfigurationObj.TVOS_DEPLOYMENT_TARGET
        os = "tvOS"
    }

    if !deploymentTarget.isEmpty {
        xcodeProj.deploymentTarget = os + " Deployment Target = " + deploymentTarget
    }
}//end func

private func isTestOrProductOrFramework(name: String) -> Bool {
    return name == "Frameworks" || name == "Products" || name.hasSuffix("Tests")
}

// Get the isa of the pbxObject refered to by string
private func getAssigneeIsa(string: String, pbxObjects: [String: PBX]) -> String {
    var objKey = string
    var isa = ""
    if objKey.hasSuffix("=") { objKey = String(string.dropLast()).trim }
    isa = pbxObjects[objKey]?.isa ?? ""
    return isa
}

// Decode " xxx = yyy ; " into ("xxx","yyy")
private func keyValDecode(_ equateLine: String) -> (String, String) {
    let comps = equateLine.components(separatedBy: "=")
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

//---- cleanRawText -
//Returns String stripped of block comments, newLines, tabs & double-spaces.
//Also returns linePointer that contains a Line-Number for each Character.
//TODO: Change to a single pass for performance
func cleanRawText(_ rawText: String) -> (String, [Int]) {       //550-606 = 56-lines
    var pStart = 1
    if rawText.hasPrefix("//") {
        pStart = rawText.IndexOf("\n") + 1
    }
    if rawText.contains("//") {
        //print("⛔️⛔️⛔️  #\(#line) Contains \" // \"")
    }
    if !rawText.contains("/*") { return (rawText, [Int]() ) }
    if !rawText.contains("*/") {
        print("⛔️ BlockComment-Start with no BlockComment-end\n\"\(rawText)\"")
        return (rawText, [Int]() )
    }

    let chars = Array(rawText)
    var newStr = String(chars[pStart-1])
    var inBlock = false
    var ignorePrev = false
    var prevChar = Character("\t")      // This will be ignored
    for i in pStart..<chars.count {
        let char = chars[i]
        if prevChar == "/" && char == "*" {         // "/*"
            inBlock = true
            ignorePrev = true
        } else if prevChar == "*" && char == "/" {  // "*/"
            inBlock = false
            ignorePrev = true
        } else {                                        // all the rest
            if ignorePrev {
                ignorePrev = false
            } else if !inBlock {
                if prevChar != "\t" { newStr.append(prevChar) }
            }
        }
        prevChar = char
    }//next i
    newStr.append(chars.last ?? Character(" "))      //???? Get that last Character

    newStr = newStr.replacingOccurrences(of: "  ", with: " ") // Remove Double-Spaces

    // Now build outputStr & Line-Number array, removing newLines.
    var outputStr = ""
    var linePtrs = [Int]()
    let lines = newStr.components(separatedBy: "\n")
    for (num, line) in lines.enumerated() {
        outputStr.append(line)                 // append the line without \n
        //if num < 5 { print(num, line)}
        if line.count > 0 {
            for _ in 0..<line.count { // Set Line-Number for each Character position.
                linePtrs.append(num+1)
            }
            //p1 = p1 + line.count
        }
    }//next line

    return (outputStr, linePtrs)
}//end func cleanRawText


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

    if hexObj.hasPrefix("=") { hexObj = hexObj.dropFirst().trim }
    if hexObj.hasSuffix("=") { hexObj = hexObj.dropLast().trim }

    if hexObj.count != 24 { return false }  // must be exactly 24-characters

    for char in hexObj {
        if !char.isHexDigit { return false }
    }
    return true
}

//MARK: NSAttributedString stuff - Called from ViewController

//let attributesLargeFont  = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 20), NSAttributedString.Key.paragraphStyle: paragraphStyleA1]
//let attributesMediumFont = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 16), NSAttributedString.Key.paragraphStyle: paragraphStyleA1]
//let attributesSmallFont  = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 12), NSAttributedString.Key.paragraphStyle: paragraphStyleA1]
//var attTxt  = NSMutableAttributedString(string: "", attributes: attributesSmallFont)

//---- showXcodeproj - from an XcodeProj, generate an NSAttributedString to display
public func showXcodeproj(_ xcodeProj: XcodeProj) -> NSAttributedString  {      //646-753 = 107-lines

    var text = ""
    var issues = [String]()
    text += "----------------- \(xcodeProj.filename) -----------------\n"
    text += "Application Name         = \(xcodeProj.appName)\n"
    if xcodeProj.appName != xcodeProj.productName {
        text += "Product Name             = \(xcodeProj.productName)\n"
        if !IssuePreferences.diffentProductNameAllowed {
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
            if xcodeProj.swiftVerMin < IssuePreferences.minumumSwiftVersion {
                issues.append("Obsolete Swift Version \(xcodeProj.swiftVerMin)")
            }
            text += "Swift Version used       = \(xcodeProj.swiftVerMin)\n"
        }
    }
    text += "Archive Version          = \(xcodeProj.archiveVersion)\n"
    text += "Object Version           = \(xcodeProj.objectVersion)\n"
    text += "Compatibility Version    = \(xcodeProj.compatibilityVersion)\n"
    text += "Last Swift Update Check  = \(xcodeProj.lastSwiftUpdateCheck)\n"
    text += "Last Upgrade Check       = \(xcodeProj.lastUpgradeCheck)\n"
    text += "Organization Name        = \(xcodeProj.organizationName)\n"
    text += "Created On Tools Version = \(xcodeProj.createdOnToolsVersion)\n"
    text += "SDK Root                 = \(xcodeProj.sdkRoot)\n"
    text += "\(xcodeProj.deploymentTarget)\n"    // deploymentTarget

    if !IssuePreferences.allowedOrganizations.isEmpty {
        if !IssuePreferences.allowedOrganizations.contains(xcodeProj.organizationName) {
            issues.append("External Organization \"\(xcodeProj.organizationName)\"")
        }
    }
    var totalCodeLine     = 0
    var totalNonCamelCase = 0
    var totalForceUnwrap  = 0
    var totalVbCompatCall = 0
    var totalBig          = 0

    text += "\n------------ \(showCount(count: xcodeProj.swiftURLs.count, name: "Swift file")) in \(xcodeProj.filename) ------------\n"   // "Swift files"
    text += "       FileName            CodeLines  NonCamel ForceUnwrap  VB    Big\n"

    for swiftSummary in xcodeProj.swiftSummaries {
        let name = swiftSummary.fileName
        let isTest = swiftSummary.url.path.contains("TestSharedCode")
        if isTest || (name != "VBcompatablity.swift" && name != "MyFuncs.swift" && name != "StringExtension.swift") {
            let clCt = swiftSummary.codeLineCount
            totalCodeLine += clCt
            if clCt > IssuePreferences.maxFileCodeLines {
                issues.append("\"\(name)\" has \(clCt) code-lines (>\(IssuePreferences.maxFileCodeLines)).")
            }
            let ccCt = swiftSummary.nonCamelCases.count
            totalNonCamelCase += ccCt
            let fuCt = swiftSummary.forceUnwraps.count
            totalForceUnwrap += fuCt
            let vbCt = swiftSummary.vbCompatCalls.count
            totalVbCompatCall += vbCt
            let bigCt = swiftSummary.massiveFile + swiftSummary.massiveFuncs.count
            for afunc in swiftSummary.massiveFuncs {
                issues.append("\"\(name)\" has a func \"\(afunc.name)\" with \(afunc.codeLineCount) code-lines (>\(IssuePreferences.maxFuncCodeLines)).")
            }
            totalBig += bigCt
            //text += "\(swiftSummary.url.lastPathComponent)  -  nonCamel \(swiftSummary.nonCamelCases.count)\n"
            text += format2(swiftSummary.url.lastPathComponent,clCt,ccCt,fuCt,vbCt,bigCt)
        } else {
            text += "(\(swiftSummary.url.lastPathComponent))\n"
        }
    }//next
    text += "\n\(format2("  -- Totals --",totalCodeLine,totalNonCamelCase,totalForceUnwrap,totalVbCompatCall, totalBig))\n"

    //------------------------------------------------------------------
    //------------- Issues --------------
    let totalIssueCount = totalNonCamelCase + totalForceUnwrap + totalVbCompatCall + totalBig + issues.count

    if totalIssueCount == 0 {
        text += "\n-------- No Issues --------\n"
    } else {
        text += "\n--------- \(totalIssueCount) Possible \("Issue".pluralize(totalIssueCount)) in \(xcodeProj.filename) ---------\n"
        if totalNonCamelCase > 0 {text += "\(showCount(count: totalNonCamelCase, name: "NonCamelCase Variable")).\n"}
        if totalForceUnwrap  > 0 {text += "\(showCount(count: totalForceUnwrap,  name: "ForceUnwrap")).\n"}
        if totalVbCompatCall > 0 {text += "\(showCount(count: totalVbCompatCall, name: "VBcompatability Call")).\n"}
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

private func format2(_ name: String, _ c1: Int, _ c2: Int, _ c3: Int, _ c4: Int, _ c5: Int) -> String {
    let txt = name.PadRight(26) + fmtI(c1, wid: 8) + fmtI(c2, wid: 9) + fmtI(c3, wid: 10)
                                + fmtI(c4, wid: 9) + fmtI(c5, wid: 7) + "\n"
    return txt
}
private func fmtI(_ number: Int, wid: Int) -> String {
    if number == 0 { return "-".PadLeft(wid) }
    return formatInt(number: number, fieldLen: wid)
}

// not used - Alternative parser
func altParser(_ xcodeprojRaw: String) {
    let raw1 = xcodeprojRaw.replacingOccurrences(of: "\n", with: "")
    var raw2 = raw1.replacingOccurrences(of: "\t", with: "")
    raw2 = raw2.replacingOccurrences(of: "{", with: ";{;")
    let lines = raw2.components(separatedBy: ";")
    var depth = 0
    for lineRaw in lines{
        var line = lineRaw.trim
        line = stripComments(line)
        if line == "{" {depth += 1}
        let tabs = String(repeating: "\t", count: depth)    // for print
        print("\(tabs)\(line)")                             // for print
        if line == "}" {depth -= 1}
        if line.count > 1 && (line.contains("{") || line.contains("}")) {
            //print()
            print()
        }
    }
    print()

}

// used by altParser
private func stripComments(_ lineIn: String) -> String {
    var line = lineIn
    var index1 = line.firstIntIndexOf("/*", startingAt: 0)
    while index1 >= 0 {
        let index2 = line.firstIntIndexOf("*/", startingAt: index1+2) + 2
        line = String(line.prefix(index1) + line.suffix(line.count - index2))
        index1 = line.firstIntIndexOf("/*", startingAt: 0)
    }
    return line
}
