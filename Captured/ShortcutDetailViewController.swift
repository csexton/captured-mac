//
//  ShortcutDetailViewController.swift
//  Captured
//
//  Created by Christopher Sexton on 11/22/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Cocoa
import MASShortcut

class ShortcutsDetailViewController: NSViewController {

  @IBOutlet weak var errorLabel: NSTextField!
  @IBOutlet weak var actionPopUp: NSPopUpButton!
  @IBOutlet weak var accountPopUp: NSPopUpButton!
  @IBOutlet weak var shortcutField: MASShortcutView!
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.

    populateAccountPopUp()


    if let shortcut = representedObject as? Shortcut {
      actionPopUp.selectItemWithTag(tagForActionType(shortcut.action))
    }

  }

  @IBAction func deleteButton(sender: AnyObject) {
    if dialogOKCancel("Confirm Delete",
      text: "Are you sure you want to delete this shortcut?",
      buttonOk: "Yep, delete it.",
      buttonCancel: "Nevermind") {
        if let shortcut = representedObject as? Shortcut {
          ShortcutManager.sharedInstance.delete(shortcut)
        }
        self.dismissController(self)
    }
  }
  @IBAction func cancelButton(sender: AnyObject) {
    self.dismissController(self)
  }
  @IBAction func saveButton(sender: AnyObject) {
    if !validateForm() {
      return
    }

    if let shortcut = representedObject as? Shortcut {
      shortcut.shortcutValue = shortcutField.shortcutValue
      shortcut.action = actionTypeForTag(actionPopUp.selectedItem!.tag)
      shortcut.name = actionPopUp.selectedItem!.title

      if let account = accountPopUp.selectedItem?.representedObject as? Account {
        shortcut.accountIdentifier = account.identifier
        shortcut.name = "\(shortcut.name) - \(account.name)"
        shortcut.summary = "Upload to \(account.name) on \(shortcut.shortcutValue!)"
      }

      ShortcutManager.sharedInstance.update(shortcut)

      self.dismissController(self)
    }
  }

  func validateForm() -> Bool {
    if shortcutField.shortcutValue == nil {
      errorLabel.stringValue = "Shortcut Cannot Be Blank"
      errorLabel.hidden = false
      return false
    } else if actionPopUp.selectedItem == nil {
      errorLabel.stringValue = "Action Cannot Be Blank"
      errorLabel.hidden = false
      return false
    } else if accountPopUp.selectedItem == nil {
      errorLabel.stringValue = "Account Cannot Be Blank"
      errorLabel.hidden = false
      return false
    } else {
      return true
    }
  }


  func endEditing() {
    // http://pinkstone.co.uk/how-to-remove-focus-from-an-nstextfield/
    //   Give up first repsonder status and therefore end editing
    self.view.window?.makeFirstResponder(nil)
  }


  func populateAccountPopUp() {
    let am = AccountManager.sharedInstance
    accountPopUp.menu?.removeAllItems()

    am.eachAccount {
      let item = NSMenuItem(title: $0.name, action: nil, keyEquivalent: "")
      item.representedObject = $0
      self.accountPopUp.menu?.addItem(item)
    }

    if let shortcut = representedObject as? Shortcut {
      shortcutField.shortcutValue = shortcut.shortcutValue
      let idx = am.indexForAccountWithIdentifier(shortcut.accountIdentifier)
      accountPopUp.selectItemAtIndex(idx)
    }
  }

  func actionTypeForTag(tag: Int) -> String {
    switch tag {
    case 2:
      return "FullScreen"
    case 1:
      return "SelectWindow"
    default:
      return "SelectArea"
    }
  }
  func tagForActionType(type: String) -> Int {
    switch type {
    case "FullScreen":
      return 2
    case "SelectWindow":
      return 1
    default:
      return 0
    }
  }


  func dialogOKCancel(question: String, text: String, buttonOk: String = "OK", buttonCancel: String = "Cancel") -> Bool {
    let myPopup: NSAlert = NSAlert()
    myPopup.messageText = question
    myPopup.informativeText = text
    myPopup.alertStyle = NSAlertStyle.Warning
    myPopup.addButtonWithTitle(buttonOk)
    myPopup.addButtonWithTitle(buttonCancel)
    let res = myPopup.runModal()
    if res == NSAlertFirstButtonReturn {
      return true
    }
    return false
  }
}
