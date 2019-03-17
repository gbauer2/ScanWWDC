//
//  AnalyseXcodeproj.swift
//  AnalyseSwiftCode
//
//  Created by George Bauer on 11/8/18.
//  Copyright © 2018,2019 George Bauer. All rights reserved.//

import Cocoa


private var pbxObjects = [String : PBX]()

public struct XcodeProj {
    var url: URL?
    var name            = ""
    var archiveVersion  = ""
    var objectVersion   = ""
    var createdOnToolsVersion = ""
    var swiftVerMin     = 0.0
    var swiftVerMax     = 0.0
    var sdkRoot         = ""
    var deploymentTarget = ""
    var pbxDict         = [String : String]()
}

// Stuff to be returned by AnalyseSwift (not yet used)
public struct SwiftSummary {
    var fileName        = ""
    var url: URL?
    var codeLineCount   = 0
    var importName      = ""
    var importCount     = 0
    var classCount      = 0
    var structCount     = 0
    // issues
    var nonCamelCaseCnt = 0
    var vbCompatCallCnt = 0
    var forceUnwrapCnt  = 0
}

// Struct to hold values set by .xcodeproj > project.pbxproj file
// To Add property:
//  1) "var XXX ="      (1 place);
//  2) "debugDescription"(3 places) if !self.XXX.isEmpty    { str += ", XXX=" + self.XXX }
//  3) func changeProperty (2 places)           case "XXX": self.XXX = vals.first ?? ""
public struct PBX: CustomDebugStringConvertible {       //41-170 = 129-lines
    var isa         = ""
    var fileRef     = ""
    var name        = ""
    var path        = ""
    var target      = ""
    var mainGroup   = ""
    var proxyType   = ""
    var sourceTree  = ""

    var productName     = ""
    var productType     = ""
    var fileEncoding    = ""

    var containerPortal     = ""
    var productRefGroup     = ""
    var productReference    = ""
    var lastKnownFileType   = ""

    var compatibilityVersion    = ""
    var remoteGlobalIDString    = ""
    var buildConfigurationList  = ""

    var files   = [String]()
    var targets = [String]()
    var children    = [String]()
    var buildRules  = [String]()
    var dependencies        = [String]()
    var buildConfigurations = [String]()

    mutating func changeProperty(propertyName: String, vals: [String]) {
        switch propertyName {
        case "isa":         self.isa        = vals.first ?? ""
        case "fileRef":     self.fileRef    = vals.first ?? ""
        case "name":        self.name       = vals.first ?? ""
        case "path":        self.path       = vals.first ?? ""
        case "target":      self.target     = vals.first ?? ""
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

        case "files":   self.files      = vals
        case "targets": self.targets    = vals
        case "children":    self.children   = vals
        case "buildRules":  self.buildRules = vals
        case "dependencies":    self.dependencies           = vals
        case "buildConfigurations": self.buildConfigurations = vals

        default:
            let ignore =
            ["attributes","remoteGlobalIDString","remoteInfo","defaultConfigurationName",
             "explicitFileType","includeInIndex","buildActionMask","runOnlyForDeploymentPostprocessing",
             "developmentRegion","hasScannedForEncodings","knownRegions","buildPhases",
             "projectDirPath","projectRoot","targetProxy","buildSettings","defaultConfigurationIsVisible",
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

        if !self.files.isEmpty     { str += "\(sep)\(showArray(name: "files", array: self.files))" }
        if !self.targets.isEmpty     { str += "\(sep)\(showArray(name: "targets", array: self.targets))" }
        if !self.children.isEmpty     { str += "\(sep)\(showArray(name: "children", array: self.children))" }

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

    static func getOrCreate(dict: [String : PBX], propertyName: String) -> PBX {
        if let pbx = dict[propertyName] {
            return pbx
        } else {
            return PBX()
        }
    }

}//end struct PBX

// Decode " xxx = yyy ; " into ("xxx","yyy")
private func keyValDecode(_ str: String) -> (String, String) {
    let comps = str.components(separatedBy: "=")
    if comps.count < 2  { return ("","")}
    let key = comps[0].trim
    var val = comps[1].trim
    if val.hasSuffix(";") { val = String(val.dropLast()).trim }
    return (key, val)
}

//---- analyseXcodeproj - Analyse a .xcodeproj file, returning an errorText and an XcodeProj instance
public func analyseXcodeproj(_ url: URL) -> (String, XcodeProj) {   //183-290 = 107-lines
    //let attributesLargeFont  = [NSAttributedStringKey.font: NSFont.systemFont(ofSize: 20), NSAttributedStringKey.paragraphStyle: paragraphStyleA1]
    //let attributesMediumFont = [NSAttributedStringKey.font: NSFont.systemFont(ofSize: 16), NSAttributedStringKey.paragraphStyle: paragraphStyleA1]
    //let attributesSmallFont  = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 12), NSAttributedString.Key.paragraphStyle: paragraphStyleA1]
    //var attTxt  = NSMutableAttributedString(string: "", attributes: attributesSmallFont)
    var newURL = url
    var gotNewURL = false
    let fileManager = FileManager.default
    var xcodeProj = XcodeProj()
    xcodeProj.url = url
    xcodeProj.name = url.lastPathComponent
    do {
        let contents = try fileManager.contentsOfDirectory(atPath: url.path)

        //print("🤠\(contents)")

        for name in contents {
            if name.contains(".pbxproj") {
                newURL = url.appendingPathComponent(name)
                gotNewURL = true
                break
            }
        }
        if !gotNewURL {
            return ( "\"project.pbxproj\" not found in \(url.path)",xcodeProj)
        }

        let storedData = try String(contentsOf: newURL)
        //print(storedData)

        preProcess(storedData)

        let xcodeprojLines = storedData.components(separatedBy: "\n")
        var gotBuildSettings = false
        for (idx, line) in xcodeprojLines.enumerated() {
            let lineNum = idx+1
            if gotBuildSettings {
                if line.contains("SDKROOT") {
                    (_, xcodeProj.sdkRoot) = keyValDecode(line)             // xcodeProj.sdkRoot
                    if idx < 11 { print("✅ \(lineNum) \"SDKROOT\" \(line)") }
                } else if line.contains("DEPLOYMENT_TARGET") {
                    print("✅ \(lineNum) \"DEPLOYMENT_TARGET\" \(line)")
                    let (key, val) = keyValDecode(line)
                    xcodeProj.deploymentTarget = key + " = " + val          // xcodeProj.deploymentTarget
                } else if line.contains("SWIFT_VERSION") {
                    print("✅ \(lineNum) \"SWIFT_VERSION\" \(line)")
                    let (_, val) = keyValDecode(line)
                    let ver = getVersionNumber(text: val)
                    if val.count > 3 && ver == 0 {
                        print("😡 Could not decode Version: \(val)")    //Debug Trap
                    }

                    if xcodeProj.swiftVerMin == 0.0 || ver < xcodeProj.swiftVerMin {
                        xcodeProj.swiftVerMin = ver                         // xcodeProj.swiftVerMin
                    }
                    if ver > xcodeProj.swiftVerMax {
                        xcodeProj.swiftVerMax = ver                         // xcodeProj.swiftVerMax
                    }

                } else if line.lowercased().contains("ver") && !line.contains("NVER") {
                    print("✅ \(lineNum) \"ver\" \(line)")
                }
            } else {
                if line.contains("buildSettings =") { gotBuildSettings = true }
                if line.contains("archiveVersion") { (_, xcodeProj.archiveVersion) = keyValDecode(line) }
                if line.contains("objectVersion") { (_, xcodeProj.objectVersion) = keyValDecode(line) }
                if line.contains("CreatedOnToolsVersion") {
                    (_, xcodeProj.createdOnToolsVersion) = keyValDecode(line)
                    print("✅ \(lineNum) \"CreatedOnToolsVersion\" \(line)")
                }
            }

            let (isa, dict) = disectLine(line)

            switch isa {
            case "PBXBuildFile":
                //print("✅✅ \(lineNum) \(line)")
                if let fileRef = dict["fileRef"] {
                    print("🔹 \(lineNum) \(isa) FileRef: \"\(fileRef)\"")
                    xcodeProj.pbxDict[fileRef] = "?"
                } else {
                    print("⛔️ \(lineNum) \"\(isa)\" \(line)")
                }

            case "PBXFileReference":
                //print("✅✅ \(lineNum) \(line)")
                if let path = dict["path"] {
                    print("🔹 \(lineNum) \"\(isa)\" path: \"\(path)\"")
                    xcodeProj.pbxDict[path] = "?"
                } else {
                    print("⛔️ \(lineNum) \"\(isa)\" \(line)")
                }

            default:
                if isa.isEmpty {break}
                print("🔹🔹🔹 \(lineNum) \"\(isa)\"")
                break
            }

        }//next line
        print("🍎 \(xcodeProj)")
    } catch {
        return  ( "Error in \(url.path)",xcodeProj)
    }

    return ( "", xcodeProj)

}//end func analyseXcodeproj

func disectLine(_ line: String) -> (String, [String : String]) {
    let separators = CharacterSet(charactersIn: ";(){}[]").union(.whitespacesAndNewlines)
    var dict = [String : String]()
    var isa  = ""
    if !line.contains("isa =") { return (isa, dict) }
    let cleanLine = stripComments(line)
    let comps = cleanLine.components(separatedBy: separators)
    let words = comps.filter { !$0.isEmpty }
    for (i, word) in words.enumerated() {
        if i > 0 && i < words.count-1 && word == "=" {
            let key = words[i-1]
            let val = words[i+1]
            if key == "isa" { isa = val }
            dict[key] = val
           // print("🔹🔹 \(key): \"\(val)\"")
        }
    }//next
    return (isa, dict)
}//end func

//---- getKeyVals - returns a key & an array of values from a Sting like "key = val" or "key = (val1, val2, ...)"
func getKeyVals(from text: String) -> (key: String, vals: [String]) {
    let comps = text.components(separatedBy: "=")
    let key = comps[0].trim
    let vals: [String]
    var valStr = comps[1].trim
    if valStr.hasPrefix("(") && valStr.hasSuffix(")") {
        valStr = String(valStr.dropFirst().dropLast()).trim
        if valStr.hasSuffix(",") { valStr = String(valStr.dropLast()) }
        vals = valStr.components(separatedBy: ",").map {$0.trim}
    } else {
        vals = [valStr]
    }
    return (key, vals)
}

func stripComments(_ line: String) -> String {      //328-360 = 32-lines
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

func preProcess(_ str: String) {        //362-520 = 158-lines
    pbxObjects.removeAll()
    var archiveVersion = ""
    var objectVersion  = ""
    var rootObjectKey  = ""
    let (strClean,linePtr) = stripCommentsAndNewlines(str)
    let chars = Array(strClean)
    var depth = 0
    var bufrs = [String]()
    bufrs.append("")
//    var hexObj = ""
//    var gotEqualB4 = false
    for cp in 1..<chars.count {
        let char = chars[cp]

        //        if (char >= "0" && char <= "9") || (char >= "A" && char <= "F") {
        //            if hexObj.isEmpty && cp > 1 && chars[cp-2] == "=" {
        //                gotEqualB4 = true
        //            }
        //            hexObj.append(char)
        //            if hexObj.count == 24 {
        //                if !gotEqualB4 && ( cp >= chars.count-2 || chars[cp+2] != "=" ) {
        //                    let i1 = max(cp-25, 0)
        //                    let i2 = min(cp+11, chars.count-1)
        //                    let s = String(chars[i1...i2])
        //                    print("⛔️⛔️ obj \(hexObj) without equal: \"\(s)\"")
        //                }
        //                print("😈 obj = \"\(hexObj)\"")
        //                hexObj = ""
        //            }
        //        } else {
        //            if char != " " { gotEqualB4 = false }
        //            hexObj = ""
        //        }

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
                    let part = bufrs[d].trim
                    parts.append(part)
                }//next d
            }

            if let part = parts.last {
                if !part.hasSuffix("=") {
                    print("↔️\(linePtr[cp])-\(depth) \(parts)")

                    if parts.count == 1 {
                        print(part)
                        let (key, val) = keyValDecode(part)
                        switch key {
                        case "archiveVersion":
                            archiveVersion = val
                        case "objectVersion":
                            objectVersion = val
                        case "rootObject":
                            rootObjectKey = val
                        default:
                            print("😡 Unhandled line \(linePtr[cp]) \"\(part)\" 😡")
                        }
                    } else if parts.count == 2 {
                        let assignee = parts[0]
                        if assignee.hasSuffix("=") {
                            let objKey = String(assignee.dropLast()).trim
                            let (key, vals) = getKeyVals(from: parts[1])
                            var obj = PBX.getOrCreate(dict: pbxObjects, propertyName: objKey)
                            obj.changeProperty(propertyName: key, vals: vals)
                            pbxObjects[objKey] = obj
                        }
                    }
                }
            }//parts not nil
            bufrs[depth] = ""

        } else {                                        // not "{" or "}" or ";"
            bufrs[depth].append(char)
        }

    }//next cp

    // print a list of objects
    for obj in pbxObjects {
        let o = obj.value
        var pr = "\(obj.key) \(o.isa)"
        if !o.fileRef.isEmpty { pr += "; fileRef=\(pbxObjects[o.fileRef]!.path)" }
        if !o.name.isEmpty { pr += "; name=\(o.name)" }
        if !o.children.isEmpty  { pr += "; children=\(o.children)" }
        print(pr)
    }//next obj

    //Analyse rootObject
    print()

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
        let path = mainSourceObj.path
        print()
        print("😈mainSourceObj.path = \"\(path)\"")
        let sourceFileKeys = mainSourceObj.children
        for sourceFileKey in sourceFileKeys {
            print("😈", pbxObjects[sourceFileKey]!)
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


//---- stripCommentsAndNewlines -
//Returns String stripped of comments, newLines, tabs & double-spaces.
//Also returns linePointer witch contains a Line-Number for each Character.
func stripCommentsAndNewlines(_ str: String) -> (String, [Int]) {       //525-574 = 49-lines
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
    newStr.append(chars.last!)      // Get that last Character

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

/*
 obj = { isa = ...
 ️10  PBXBuildFile          >13     fileRef = obj
 ️27  PBXContainerItemProxy >1      containerPortal = obj; proxyType = 1;remoteGlobalIDString = obj;remoteInfo = AnalyseSwiftCode;
 ️36  PBXFileReference      >17     explicitFileType = wrapper.application; includeInIndex = 0; path = AnalyseSwiftCode.app; sourceTree = BUILT_PRODUCTS_DIR
 ️57  PBXFrameworksBuildPhase >2    buildActionMask = 2147483647;files = ()
 ️74  PBXGroup              >5      children = ( obj /* AnalyseSwift */, obj /* AnalyseSwiftCodeUnitTests */,obj /* Products */,);sourceTree = "<group>"
 ️132 PBXNativeTarget}      >2      buildConfigurationList = obj;
                                    buildPhases = (obj /* Sources */, obj /* Frameworks */, obj /* Resources */, );
                                    buildRules = ();
                                    dependencies = ();
                                    name = AnalyseSwiftCode;
                                    productName = FileSpy;
                                    productReference = obj /* AnalyseSwiftCode.app */;
                                    productType = "com.apple.product-type.application";

 ️170 PBXProject    attributes = {
                                    LastSwiftUpdateCheck = 1010;
                                    LastUpgradeCheck = 0930;
                                    ORGANIZATIONNAME = "Ray Wenderlich";
                                    TargetAttributes = {obj = { CreatedOnToolsVersion = 8.2.1;
                                                                DevelopmentTeam = XD8UZ6484B;
                                                                LastSwiftMigration = 1010;
                                                                ProvisioningStyle = Automatic; };
                                                        obj = { CreatedOnToolsVersion = 10.1;
                                                                DevelopmentTeam = XD8UZ6484B;
                                                                ProvisioningStyle = Automatic;
                                                                TestTargetID = obj;
                    buildConfigurationList = obj
                    compatibilityVersion = "Xcode 3.2";
                    developmentRegion = English;
                    hasScannedForEncodings = 0;
                    knownRegions = (en, Base, );
                    mainGroup = obj;
                    productRefGroup = obj /* Products */;
                    projectDirPath = "";
                    projectRoot = "";
                    targets = (obj /* AnalyseSwiftCode */, obj /* AnalyseSwiftCodeUnitTests */,);
                    };

 ️211 PBXResourcesBuildPhase} >2    buildActionMask = 2147483647;
                                    files = (obj /* Assets.xcassets in Resources */, obj /* Main.storyboard in Resources */,);
                                    runOnlyForDeploymentPostprocessing = 0;

 ️230 PBXSourcesBuildPhase  >2      buildActionMask = 2147483647;
                                    files = (obj, obj, ... );   /* .swift files in Sources */,
                                    runOnlyForDeploymentPostprocessing = 0;

 ️258 PBXTargetDependency           target = obj /* AnalyseSwiftCode */; targetProxy = obj /* PBXContainerItemProxy */;

 ️266 PBXVariantGroup               children = (obj /* Base */,);
                                    name = Main.storyboard;
                                    sourceTree = "<group>";

 ️277 XCBuildConfiguration    >6    buildSettings = {... many ...}
                                    name = Debug;  or name = Realease

 ️471 XCConfigurationList}    >3    buildConfigurations = (obj /* Debug */, obj /* Release */, );
                                    defaultConfigurationIsVisible = 0;
                                    defaultConfigurationName = Release;
 */

func getVersionNumber(text: String) -> Double {
    var txt = text
    if txt.hasPrefix("\"") { txt.removeFirst() }
    if txt.hasSuffix("\"") { txt.removeLast()  }

    let comps = txt.components(separatedBy: ".")
    if comps.count > 2 {
        txt = comps[0] + "." + comps[1]
    }
    let version = Double(txt) ?? 0
    return version
}

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

    let textAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font: NSFont.systemFont(ofSize: 18),
        NSAttributedString.Key.paragraphStyle: NSParagraphStyle.default
    ]
    let formattedText = NSMutableAttributedString(string: text, attributes: textAttributes)
    return formattedText
}

/*
 18 CE83F8BB1FFD329D00C39EC8 /* MyFuncs.swift in Sources */ = {isa = PBXBuildFile; fileRef = CE83F8BA1FFD329C00C39EC8 /* MyFuncs.swift */; };
 18 CE83F8BB1FFD329D00C39EC8 = {isa = PBXBuildFile; fileRef = CE83F8BA1FFD329C00C39EC8; };

 48 CE83F8BA1FFD329C00C39EC8 /* MyFuncs.swift */ = {isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.swift; path = MyFuncs.swift; sourceTree = "<group>"; };
 48 CE83F8BA1FFD329C00C39EC8 = {isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.swift; path = MyFuncs.swift; sourceTree = "<group>"; };

 CEE7D49A2197560D005B0559 /* MyLibrary */ = {
 isa = PBXGroup;
 children = (
 122 CE83F8BA1FFD329C00C39EC8 /* MyFuncs.swift */,
 CE67A6A31FFA066B00BD57BD /* StringExtension.swift */,
 );
 path = MyLibrary;
 sourceTree = "<group>";
 };
 */

// PRODUCT_BUNDLE_IDENTIFIER = com.georgebauer.PorfolioSummary;
/*

 /* Begin PBXBuildFile section */               10
 12 files
 /* Begin PBXContainerItemProxy section */      25
 /* Begin PBXFileReference section */           42
 19 files
 /* Begin PBXFrameworksBuildPhase section */    64
 /* Begin PBXGroup section */                   88
 /* Begin PBXNativeTarget section */            148
 /* Begin PBXProject section */                 204
 .      CreatedOnToolsVersion = 9.2;                213,223,229
 /* Begin PBXResourcesBuildPhase section */     256
 /* Begin PBXSourcesBuildPhase section */       282
 /* Begin PBXTargetDependency section */        316
 /* Begin PBXVariantGroup section */            329
 /* Begin XCBuildConfiguration section */       340
 /* Begin XCConfigurationList section */        549

 archiveVersion = 1;                             4
 objectVersion = 48;                             7
 340-399 400-450 451-465 466-480 481-497 498-514 515-530 531-546
 buildSettings =                                    343,    402,    453,    468,    483,    500,    517,    533
 MACOSX_DEPLOYMENT_TARGET = 10.13;                  391,    444
 MTL_ENABLE_DEBUG_INFO = YES;                       392,    445
 ONLY_ACTIVE_ARCH = YES;
 SDKROOT = macosx;                                  394,    446
 SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;       395
 SWIFT_OPTIMIZATION_LEVEL = "-Onone";               396,    (447)
 SWIFT_OPTIMIZATION_LEVEL = "-Owholemodule";        (396)   447
 ALWAYS_SEARCH_USER_PATHS = NO;
 MACOSX_DEPLOYMENT_TARGET = 10.13;                  391,    444
 name = Debug;                                      398,    (449)   464,    (479)   496,    (513)   529,    (545)
 name = Release;                                    (398)   449,    (464)   479,    (496)   513,    (529)   545

 CE064A5520B5FED600070CD7 /* Debug */ = {
 .  INFOPLIST_FILE = TestSharedCode/Info.plist;                     458,    473     (489)   (506)   (522)   (538)
 .  PRODUCT_BUNDLE_IDENTIFIER = com.georgebauer.TestSharedCode;     460,    475     (491)   (508)   (524)   (540)
 .  PRODUCT_NAME = "$(TARGET_NAME)";                                461,    476
 .  SWIFT_VERSION = 4.2;                                            462,    477,    493,    510,    526,    542

 CE064A5820B5FED600070CD7 /* Debug */ = {
 .  INFOPLIST_FILE = TestSharedCodeTests/Info.plist;                                489,    506,    (522)   (538)
 .  PRODUCT_BUNDLE_IDENTIFIER = com.georgebauer.TestSharedCodeTests;                491,    508
 .  PRODUCT_NAME = "$(TARGET_NAME)";
 .  SWIFT_VERSION = 4.2;
 .  TEST_HOST =
 "$(BUILT_PRODUCTS_DIR)/PorfolioSummary.app/Contents/MacOS/PorfolioSummary";        494,    511

 CE064A5920B5FED600070CD7 /* Release */ = {
 .  INFOPLIST_FILE = TestSharedCodeUITests/Info.plist;                              (489)   (506)   522,    538
 .  PRODUCT_BUNDLE_IDENTIFIER = com.georgebauer.TestSharedCodeUITests;                              524,    540

 */
