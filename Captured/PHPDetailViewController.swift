//
//  PHPDetailViewController.swift
//  Captured
//
//  Created by Christopher Sexton on 2/8/16.
//  Copyright © 2016 Christopher Sexton. All rights reserved.
//

import Cocoa

class PHPDetailViewController: AccountDetailViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.
  }

  @IBOutlet weak var nameField: NSTextField!
  @IBOutlet weak var apiTokenField: NSTextField!
  @IBOutlet weak var endpointURLField: NSTextField!
  @IBOutlet weak var testConnectionSpinner: NSProgressIndicator!

  @IBAction func testConnectionButton(sender: AnyObject) {
    testConnectionSpinner.hidden = false
    testConnectionSpinner.startAnimation(nil)
    if validateFields() {
      if let account = representedObject as? PHPAccount {

        // Run the upload test in a different thread as to not block the UI

        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
          let msg = PHPUploader.init(account: account).test()

          dispatch_async(dispatch_get_main_queue()) {
            self.testConnectionSpinner.hidden = true
            self.testConnectionSpinner.stopAnimation(nil)
            let myPopup: NSAlert = NSAlert()
            myPopup.messageText = "Test PHP Connecton"
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
      if let account = representedObject as? PHPAccount {
        account.summary = "Upload \"\(endpointURLField.stringValue)\""
      }
      super.saveButton(sender)
    }
  }

  func validateFields() -> Bool {
    endEditing()
    return (validatePresence(endpointURLField) && validatePresence(apiTokenField))
  }
}