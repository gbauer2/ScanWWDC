//
//  AnalyseXcodeproj.swift
//  AnalyseSwiftCode
//
//  Created by George Bauer on 11/8/18.
//  Copyright © 2018 Ray Wenderlich. All rights reserved.
//

import Cocoa

public struct XcodeProj {
    var archiveVersion  = ""
    var objectVersion   = ""
    var createdOnToolsVersion = ""
    var swiftVer1       = ""
    var swiftVer2       = ""
    var swiftVerMin     = 0.0
    var sdkRoot         = ""
    var deploymentTarget = ""
}
public var xcodeProj = XcodeProj()

private func keyValDecode(_ str: String) -> (String, String) {
    let comps = str.components(separatedBy: "=")
    if comps.count < 2  { return ("","")}
    let key = comps[0].trim
    var val = comps[1].trim
    if val.hasSuffix(";") { val = String(val.dropLast()).trim }
    return (key, val)
}

public func analyseXcodeproj(url: URL) -> NSAttributedString {
    //let attributesLargeFont  = [NSAttributedStringKey.font: NSFont.systemFont(ofSize: 20), NSAttributedStringKey.paragraphStyle: paragraphStyleA1]
    //let attributesMediumFont = [NSAttributedStringKey.font: NSFont.systemFont(ofSize: 16), NSAttributedStringKey.paragraphStyle: paragraphStyleA1]
    let attributesSmallFont  = [NSAttributedStringKey.font: NSFont.systemFont(ofSize: 12), NSAttributedStringKey.paragraphStyle: paragraphStyleA1]
    var attTxt  = NSMutableAttributedString(string: "", attributes: attributesSmallFont)
    var newURL = url
    var gotNewURL = false

    let fileManager = FileManager.default
    xcodeProj = XcodeProj()
    do {
        let contents = try fileManager.contentsOfDirectory(atPath: url.path)
        print("🤠\(contents)")
        for name in contents {
            if name.contains(".pbxproj") {
                newURL = url.appendingPathComponent(name)
                gotNewURL = true
                break
            }
        }
        if gotNewURL {
            let storedData = try String(contentsOf: newURL)
            print(storedData)
            let xcodeprojLines = storedData.components(separatedBy: "\n")
            var gotBuildSettings = false
            for (idx,line) in xcodeprojLines.enumerated() {
                if gotBuildSettings {
                    if line.contains("SDKROOT") {
                        (_, xcodeProj.sdkRoot) = keyValDecode(line)
                        print("✅ \(line)")
                    } else if line.contains("DEPLOYMENT_TARGET") {
                        let (key, val) = keyValDecode(line)
                        xcodeProj.deploymentTarget = key + " = " + val
                    } else if line.contains("SWIFT_VERSION") {
                        let (_, val) = keyValDecode(line)
                        if val != xcodeProj.swiftVer1 {
                            xcodeProj.swiftVer1 = val
                        } else if val != xcodeProj.swiftVer2 {
                            xcodeProj.swiftVer2 = val
                        }

                        if xcodeProj.swiftVerMin == 0.0 || Double(val)! < xcodeProj.swiftVerMin {
                            xcodeProj.swiftVerMin = Double(val)!
                        }

                        print("✅✅ \(line)")
                    } else if line.lowercased().contains("ver") && !line.contains("NVER") {
                        print("✅✅✅ \(line)")
                    }
                } else {
                    if line.contains("buildSettings =") { gotBuildSettings = true }
                    if line.contains("archiveVersion") { (_, xcodeProj.archiveVersion) = keyValDecode(line) }
                    if line.contains("objectVersion") { (_, xcodeProj.objectVersion) = keyValDecode(line) }
                    if line.contains("CreatedOnToolsVersion") {
                        (_, xcodeProj.createdOnToolsVersion) = keyValDecode(line)
                        print("✅ \(line)")
                    }
                }
            }
            print("🍎 \(xcodeProj)")
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
        } else {
            attTxt  = NSMutableAttributedString(string: "\"project.pbxproj\" not found in \(url.path)", attributes: attributesSmallFont)
            return attTxt
        }
    } catch {
        attTxt  = NSMutableAttributedString(string: "Error in \(url.path)", attributes: attributesSmallFont)
        return attTxt
    }


    var text = "Oldest Swift Version used = \(xcodeProj.swiftVerMin)\n"
    if xcodeProj.swiftVerMin == 0.0 { text = "No Swift Version found!\n" }
    if xcodeProj.swiftVer1 != xcodeProj.swiftVer2 {
        text += "Multiple Swift Versions: \(xcodeProj.swiftVer1) & \(xcodeProj.swiftVer2)\n"
    }
    text += "ArchiveVersion = \(xcodeProj.archiveVersion)\n"
    text += "ObjectVersion = \(xcodeProj.objectVersion)\n"
    text += "createdOnToolsVersion = \(xcodeProj.createdOnToolsVersion)\n"
    text += "sdkRoot = \(xcodeProj.sdkRoot)\n"
    text += "\(xcodeProj.deploymentTarget)\n"    // deploymentTarget
    let attTx  = NSMutableAttributedString(string: "", attributes: attributesSmallFont)
    attTxt  = NSMutableAttributedString(string: text, attributes: attributesSmallFont)
    attTxt.append(attTx)
    return attTxt
}
