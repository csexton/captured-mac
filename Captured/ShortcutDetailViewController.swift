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

  @IBOutlet weak var accountPopUp: NSPopUpButton!
  @IBOutlet weak var shortcutField: MASShortcutView!
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.
    accountPopUp.menu?.removeAllItems()

    let am = AccountManager.sharedInstance

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

  @IBAction func cancelButton(sender: AnyObject) {
    self.dismissController(self)
  }
  @IBAction func saveButton(sender: AnyObject) {
    self.dismissController(self)



    if let shortcut = representedObject as? Shortcut {
      print(shortcutField.shortcutValue)
      if let a = accountPopUp.selectedItem?.representedObject as? Account {
        shortcut.accountIdentifier = a.identifier
      }
      shortcut.shortcutValue = shortcutField.shortcutValue

      ShortcutManager.sharedInstance.update(shortcut)
    }
    self.dismissController(self)
    
    
  }


  func endEditing() {
    // http://pinkstone.co.uk/how-to-remove-focus-from-an-nstextfield/
    //   Give up first repsonder status and therefore end editing
    self.view.window?.makeFirstResponder(nil)
  }
}