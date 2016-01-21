//
//  AboutPreferencesViewController.swift
//  Captured
//
//  Created by Christopher Sexton on 12/15/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Cocoa

class AboutPreferencesViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

  @IBAction func visitWebpageButton(sender: AnyObject) {
    NSWorkspace.sharedWorkspace().openURL(NSURL(string: "http://www.capturedapp.com")!)
  }
}
