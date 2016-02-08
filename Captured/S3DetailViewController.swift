//
//  S3DetailViewController.swift
//  Captured
//
//  Created by Christopher Sexton on 12/9/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Cocoa

class S3DetailViewController: AccountDetailViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.
  }

  @IBOutlet weak var accessKeyField: NSTextField!
  @IBOutlet weak var secretKeyField: NSTextField!
  @IBOutlet weak var bucketNameField: NSTextField!
  @IBOutlet weak var publicURLField: NSTextField!
  @IBOutlet weak var nameLengthBox: NSComboBox!
  @IBOutlet weak var reducedRedundancyStorageButton: NSButton!
  @IBOutlet weak var testConnectionSpinner: NSProgressIndicator!

  @IBAction func testConnectionButton(sender: AnyObject) {
    testConnectionSpinner.hidden = false
    testConnectionSpinner.startAnimation(nil)
    if validateFields() {
      if let account = representedObject as? S3Account {

        // Run the upload test in a different thread as to not block the UI

        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
          let msg = S3Uploader.init(account: account).test()

          dispatch_async(dispatch_get_main_queue()) {
           self.testConnectionSpinner.hidden = true
            self.testConnectionSpinner.stopAnimation(nil)
            let myPopup: NSAlert = NSAlert()
            myPopup.messageText = "Test S3 Connecton"
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
      if let account = representedObject as? S3Account {
        account.summary = "Upload to S3 Bucket \"\(bucketNameField.stringValue)\""
      }
      super.saveButton(sender)
    }
  }

  func validateFields() -> Bool {
    endEditing()
    return (
      validatePresence(accessKeyField)
      &&
      validatePresence(secretKeyField)
      &&
      validatePresence(bucketNameField)
    )
  }
}
