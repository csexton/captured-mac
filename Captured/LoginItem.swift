//
//  LoginItem.swift
//  Captured
//
//  Created by Christopher Sexton on 7/16/16.
//  Copyright © 2016 Christopher Sexton. All rights reserved.
//
// Inspired by Erik Aigner on Stack Overflow
// http://stackoverflow.com/questions/32546893/smcopyalljobdictionaries-and-smjobcopydictionary-is-deprecated-so-what-are-thei

import Foundation
import ServiceManagement

// We no longer have a way to look up the current state of the of the login item
// since Apple deprecated both `SMCopyAllJobDictionaries` and
// `SMJobCopyDictionary`.
//
// Luckily we don't need this. Simply use `SMLoginItemSetEnabled`, if it succeeds,
// store the value in `NSUserDefaults`. Upon startup, call `SMLoginItemSetEnabled`
// with the stored value. If it fails, reset the default, otherwise the status is
// still the old one.
//
// When loading the NSView that has the checkbox for Start at Login we need to
// call `validate()` to confirm the state.
class LoginItem {
  let identifier: String
  private let defaults = NSUserDefaults.standardUserDefaults()

  init(identifier: String) {
    self.identifier = identifier
  }

  var enabled: Bool {
    return defaults.boolForKey(defaultKey)
  }

  func setEnabled(enabled: Bool) -> Bool {
    if SMLoginItemSetEnabled(identifier as NSString, enabled) {
      NSLog("Set Login Item Enabled \(enabled) for \(identifier)")
      defaults.setBool(enabled, forKey: defaultKey)
      return true
    }
    return false
  }

  func validate() -> Bool {
    if setEnabled(enabled) {
      return true
    }
    defaults.removeObjectForKey(defaultKey)
    return false
  }

  private var defaultKey: String {
    return "SMLoginItem-" + identifier
  }
}
