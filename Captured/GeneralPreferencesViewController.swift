//
//  GeneralPreferencesViewController.swift
//  Captured
//
//  Created by Christopher Sexton on 7/16/16.
//  Copyright © 2016 Christopher Sexton. All rights reserved.
//

import Cocoa

class GeneralPreferencesViewController: NSViewController {
  @IBOutlet weak var startAtLoginCheckBox: NSButton!
  @IBOutlet weak var showMenuBarIconCheckBox: NSButton!

  let loginItem = LoginItem(identifier: "com.codeography.captured-mac.helper")
  let defaults = NSUserDefaults.standardUserDefaults()

  override func viewDidLoad() {
    super.viewDidLoad()

    // Check if we are running in debug mode (e.g. from Xcode) disable the
    // "start at login box" since it won't work properly anyway due to
    // SMLoginItemSetEnabled requirements
    if AppMode.debug() {
      startAtLoginCheckBox.enabled = false
      startAtLoginCheckBox.state = NSOffState
    } else {
      // TODO: If validate fails (returns false) it means that we were unable to
      // call `SMLoginItemSetEnabled` successfully. This probably means we are
      // not running sandboxed.
      loginItem.validate()
      if loginItem.enabled {
        startAtLoginCheckBox.state = NSOnState
      } else {
        startAtLoginCheckBox.state = NSOffState
      }
    }

    if defaults.boolForKey("EnableMenuBarIcon") {
      showMenuBarIconCheckBox.state = NSOnState
    } else {
      showMenuBarIconCheckBox.state = NSOffState
    }

  }

  @IBAction func startAtLoginChanged(sender: NSButton) {
    let newState = (sender.state == NSOnState)
    loginItem.setEnabled(newState)
  }

  @IBAction func showMenuBarIconChanged(sender: NSButton) {
    if let delegate = NSApplication.sharedApplication().delegate as? AppDelegate {
      if sender.state == NSOnState {
        defaults.setBool(true, forKey: "EnableMenuBarIcon")
        delegate.setupStatusItem()
      } else {
        defaults.setBool(false, forKey: "EnableMenuBarIcon")
        delegate.setupStatusItem()
      }
    }
  }
}
