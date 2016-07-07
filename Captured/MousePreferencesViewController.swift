//
//  MousePreferencesViewController.swift
//  Captured
//
//  Created by Christopher Sexton on 3/26/16.
//  Copyright © 2016 Christopher Sexton. All rights reserved.
//

import Cocoa

class MousePreferencesViewController: NSViewController {

  @IBOutlet weak var accountPopUp: NSPopUpButton!

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.
  }

  override func viewWillAppear() {
    populateAccountPopUp()
  }

  func populateAccountPopUp() {
    let am = AccountManager.sharedInstance
    accountPopUp.menu?.removeAllItems()

    am.eachAccount {
      let item = NSMenuItem(title: $0.name, action: nil, keyEquivalent: "")
      item.representedObject = $0.identifier
      self.accountPopUp.menu?.addItem(item)
    }

    if let identifier = NSUserDefaults.standardUserDefaults().objectForKey("DragAccountIdentifier") as? String {
      let idx = am.indexForAccountWithIdentifier(identifier)
      accountPopUp.selectItemAtIndex(idx)
    }
  }

  func defaults(key: String) -> String {
    return NSUserDefaults.standardUserDefaults().objectForKey(key) as! String
  }
}
