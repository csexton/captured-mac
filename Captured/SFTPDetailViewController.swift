//
//  SFTPDetailViewController.swift
//  Captured
//
//  Created by Christopher Sexton on 1/15/16.
//  Copyright © 2016 Christopher Sexton. All rights reserved.
//

import Cocoa

class SFTPDetailViewController: AccountDetailViewController {

  @IBOutlet weak var displayNameField: NSTextField!
  @IBOutlet weak var usernameField: NSTextField!
  @IBOutlet weak var hostnameField: NSTextField!
  @IBOutlet weak var publicURLField: NSTextField!

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.
  }


  @IBAction func testConnectionButton(sender: AnyObject) {
  }

  override func saveButton(sender: AnyObject) {
    if validateFields() {
      if let account = representedObject as? SFTPAccount {
        account.summary = "Upload to SFTP Server \"\(usernameField.stringValue)@\(hostnameField.stringValue)\""
        print(account)
      }
      super.saveButton(sender)
    }
  }

  func validateFields() -> Bool {
    endEditing()
    return (
      validatePresence(displayNameField)
      &&
      validatePresence(usernameField)
      &&
      validatePresence(hostnameField)
      &&
      validatePresence(publicURLField)
    )
  }
}
