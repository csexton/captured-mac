//
//  FirstRunViewController.swift
//  Captured
//
//  Created by Christopher Sexton on 6/12/16.
//  Copyright © 2016 Christopher Sexton. All rights reserved.
//

import Cocoa

class FirstRunViewController: NSViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  @IBAction func close(sender: AnyObject) {
    if let delegate = NSApplication.sharedApplication().delegate as? AppDelegate {
      delegate.closePopover(sender)
    }
  }
}
