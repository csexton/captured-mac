//
//  ShortcutDetailViewController.swift
//  Captured
//
//  Created by Christopher Sexton on 11/22/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Cocoa

class ShortcutsDetailViewController: NSViewController {

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