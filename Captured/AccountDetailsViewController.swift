//
//  AccountDetailsViewController.swift
//  Captured
//
//  Created by Christopher Sexton on 11/21/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Cocoa

class AccountDetailsViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
  @IBAction func dismiss(sender: AnyObject) {
    self.dismissController(self)
  }
}
