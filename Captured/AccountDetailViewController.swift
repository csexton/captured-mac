//
//  AccountDetailsViewController.swift
//  Captured
//
//  Created by Christopher Sexton on 11/21/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Cocoa

class AccountDetailViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    

  @IBAction func cancelButton(sender: AnyObject) {
    self.dismissController(self)
  }

  @IBAction func saveButton(sender: AnyObject) {
    endEditing()

    AccountManager.sharedInstance.update(representedObject as! Account)
    self.dismissController(self)
  }
  @IBAction func deleteButton(sender: AnyObject) {
    if dialogOKCancel("Confirm Delete",
      text: "Are you sure you want to delete this account?",
      buttonOk: "Yep, delete it.",
      buttonCancel: "Nevermind") {
        if let account = representedObject as? Account {
          AccountManager.sharedInstance.delete(account)
        }
        self.dismissController(self)
    }
  }
  
  func endEditing() {
    // http://pinkstone.co.uk/how-to-remove-focus-from-an-nstextfield/
    //   Give up first repsonder status and therefore end editing
    self.view.window?.makeFirstResponder(nil)
  }

  // MARK: Helpful methods
  
  func defaults(key:String) -> String {
    return NSUserDefaults.standardUserDefaults().objectForKey(key) as! String
  }

  func dialogOKCancel(question: String, text: String, buttonOk: String = "OK", buttonCancel: String = "Cancel") -> Bool {
    let myPopup: NSAlert = NSAlert()
    myPopup.messageText = question
    myPopup.informativeText = text
    myPopup.alertStyle = NSAlertStyle.WarningAlertStyle
    myPopup.addButtonWithTitle(buttonOk)
    myPopup.addButtonWithTitle(buttonCancel)
    let res = myPopup.runModal()
    if res == NSAlertFirstButtonReturn {
      return true
    }
    return false
  }

}
