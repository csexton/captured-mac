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
  @IBOutlet weak var passwordField: NSTextField!
  @IBOutlet weak var hostnameField: NSTextField!
  @IBOutlet weak var publicURLField: NSTextField!
  @IBOutlet weak var spinner: NSProgressIndicator!

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.
  }


  @IBAction func testConnectionButton(sender: AnyObject) {
    spinner.hidden = false
    spinner.startAnimation(nil)
    if validateFields() {
      if let account = representedObject as? SFTPAccount {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
          let msg = SFTPUploader.init(account: account).test()

          dispatch_async(dispatch_get_main_queue()) {
            self.spinner.hidden = true
            self.spinner.stopAnimation(nil)
            let myPopup: NSAlert = NSAlert()
            myPopup.messageText = "Test SFTP Connecton"
            myPopup.informativeText = msg
            myPopup.alertStyle = NSAlertStyle.WarningAlertStyle
            myPopup.addButtonWithTitle("OK")
            myPopup.runModal()
          }
        }
      }
    }
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
      validatePresence(passwordField)
      &&
      validatePresence(hostnameField)
      &&
      validatePresence(publicURLField)
    )
  }
}
