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
    self.dismissController(self)
  }
}
