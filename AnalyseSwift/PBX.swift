//
//  PBX.swift
//  AnalyseSwiftCode
//
//  Created by George Bauer on 4/2/19.
//  Copyright © 2019 Ray Wenderlich. All rights reserved.
//

import Foundation

// Struct to hold values set by .xcodeproj/project.pbxproj file
// To Add property:
//  1) "var XXX ="         (1 place);
//  2) func changeProperty (2 places)           case "XXX": self.XXX = vals.first ?? ""
//  3) "debugDescription"  (3 places) if !self.XXX.isEmpty    { str += ", XXX=" + self.XXX }
public struct PBX: CustomDebugStringConvertible {       //60-275 = 215-lines
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
    var WATCHOS_DEPLOYMENT_TARGET  = ""
    var TVOS_DEPLOYMENT_TARGET     = ""
    var ENABLE_STRICT_OBJC_MSGSEND = ""
    var PRODUCT_BUNDLE_IDENTIFIER  = ""

    mutating func changeProperty(propertyName: String, vals: [String]) {    //114-185 = 71-lines
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
        case "WATCHOS_DEPLOYMENT_TARGET":   self.WATCHOS_DEPLOYMENT_TARGET  = vals.first ?? ""
        case "TVOS_DEPLOYMENT_TARGET":      self.TVOS_DEPLOYMENT_TARGET     = vals.first ?? ""
        case "PRODUCT_BUNDLE_IDENTIFIER":   self.PRODUCT_BUNDLE_IDENTIFIER  = vals.first ?? ""
        case "ENABLE_STRICT_OBJC_MSGSEND":  self.ENABLE_STRICT_OBJC_MSGSEND = vals.first ?? ""
        default:
            let ignore =
                ["remoteGlobalIDString","remoteInfo","defaultConfigurationName",
                 "explicitFileType","includeInIndex","buildActionMask","runOnlyForDeploymentPostprocessing",
                 "developmentRegion","hasScannedForEncodings","knownRegions","buildPhases",
                 "projectDirPath","projectRoot","targetProxy","defaultConfigurationIsVisible",
                 "indentWidth","tabWidth","plistStructureDefinitionIdentifier",
                 "inputPaths","outputPaths","shellPath","shellScript","PODS_PODFILE_DIR_PATH",
                 "xcLanguageSpecificationIdentifier","baseConfigurationReference","FRAMEWORK_SEARCH_PATHS",
                 "showEnvVarsInLog","SYMROOT","lineEnding","usesTabs","PRODUCT_BUNDLE_IDENTIFIER",
                 "currentVersion","versionGroupType","dstPath","dstSubfolderSpec"
            ]
            if !ignore.contains(propertyName) {
                print("⛔️⛔️⛔️⛔️ #\(#line) property \"\(propertyName) = \(vals[0])\" not handled! ⛔️⛔️⛔️⛔️")
            }

        }//end switch
    }//end func

    //---- debugDescription - used for print
    public var debugDescription: String {       //188-248 = 60-lines
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
        if !self.WATCHOS_DEPLOYMENT_TARGET.isEmpty  { str += "\(sep)WATCHOS_DEPLOYMENT_TARGET = "  + self.WATCHOS_DEPLOYMENT_TARGET }
        if !self.TVOS_DEPLOYMENT_TARGET.isEmpty     { str += "\(sep)TVOS_DEPLOYMENT_TARGET = "     + self.TVOS_DEPLOYMENT_TARGET }
        if !self.PRODUCT_BUNDLE_IDENTIFIER.isEmpty  { str += "\(sep)PRODUCT_BUNDLE_IDENTIFIER = "  + self.PRODUCT_BUNDLE_IDENTIFIER }
        if !self.ENABLE_STRICT_OBJC_MSGSEND.isEmpty { str += "\(sep)ENABLE_STRICT_OBJC_MSGSEND = " + self.ENABLE_STRICT_OBJC_MSGSEND }

        return str
    }

    // Used by debugDescription
    private func showArray(name: String, array: [String]) -> String {
        var desc = name
        var comma = " ="
        for item in array {
            desc += "\(comma) \(item)"
            comma = ","
        }
        return desc
    }

    static func setDictPropertyPBX(dict: inout [String: PBX], key: String, propertyName: String, vals: [String]) {
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
    }//end func

}//end struct PBX
