//
//  Alerts.swift
//  AnalyseSwiftCode
//
//  Created by George Bauer on 6/12/19.
//  Copyright © 2019 Ray Wenderlich. All rights reserved.
//

import Cocoa

public enum AlertStyle {
    case Information
    case OkCancel
    case YesNo
}
public enum AlertResult {
    case None
    case Yes
    case No
    case Ok
    case Cancel
}

public func alert(_ str: String, title: String = "") {
    print("Alert: ", str)
    DispatchQueue.main.async {
        let alert = NSAlert()
        if !title.isEmpty { alert.messageText = title }
        alert.informativeText = str
        alert.runModal()
    }
    return
}

public func alert(_ str: String, style: AlertStyle) -> AlertResult {

    if style == .Information {
        alert(str)
        return .None
    }

    if style == .OkCancel {
        let response = alertOKCancel(question: str, text: "")
        if response {
            return .Ok
        }
        return .Cancel
    }

    if style == .YesNo {
        let response = alertYesNo(question: str, text: "")
        if response {
            return .Yes
        }
        return .No
    }

    return .None                            // Unknown Style
}

//---- alertOKCancel - OKCancel dialog box. Returns true if OK
private func alertOKCancel(question: String, text: String) -> Bool {
    let alert = NSAlert()
    alert.messageText       = question
    alert.informativeText   = text
    alert.alertStyle        = .warning
    alert.addButton(withTitle: "OK")
    alert.addButton(withTitle: "Cancel")
    return alert.runModal() == .alertFirstButtonReturn
}

//---- alertYesNo - YesNo dialog box. Returns true? if Yes
private func alertYesNo(question: String, text: String) -> Bool {
    let alert = NSAlert()
    alert.messageText       = question
    alert.informativeText   = text
    alert.alertStyle        = .warning
    alert.addButton(withTitle: "Yes")
    alert.addButton(withTitle: "No")
    return alert.runModal() == .alertFirstButtonReturn
}


//func showSimpleAlertWithMessage(message: String!) {
//
//    let alertController = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
//    let cancel = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
//
//    alertController.addAction(cancel)
//
//    if self.presentedViewController == nil {
//        self.presentViewController(alertController, animated: true, completion: nil)
//    }
//}


//---- InputBox - returns text
func inputBox(_ msg: String) -> String {
    let alert = NSAlert()
    alert.messageText = msg
    alert.addButton(withTitle: "Ok")
    alert.addButton(withTitle: "Cancel")
    let input = NSTextField(frame: NSMakeRect(0, 0, 60, 30))
    input.stringValue = ""
    input.font = NSFont(name: "HelveticaNeue-Bold", size: 16)!
    alert.accessoryView = input
    //alert.accessoryView?.window!.makeFirstResponder(input)
    //self.view.window!.makeFirstResponder(input)               //????? How do I make "input" the FirstResponder
    //input.becomeFirstResponder()
    let button: NSApplication.ModalResponse = alert.runModal()
    alert.buttons[0].setAccessibilityLabel("InputBox OK")

    //input.becomeFirstResponder()
    if button == .alertFirstButtonReturn {
        let str = input.stringValue
        return str
    }
    return ""                               // anything else
}

func smootherStep(value: CGFloat) -> CGFloat {
    let x = value < 0 ? 0 : value > 1 ? 1 : value
    return x * x * x * (x * (x * 6 - 15) + 10) // x3 * (6x2 - 15x + 10)
}
//Excerpt From: Paul Hudson. “Pro Swift.” Apple Books.
