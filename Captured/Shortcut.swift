//
//  Shortcut.swift
//  Captured
//
//  Created by Christopher Sexton on 11/23/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Cocoa
import MASShortcut

class Shortcut: NSObject {

  dynamic var name = ""
  var action : String = "Select Area to Capture"
  var identifier : String = NSUUID().UUIDString
  var accountIdentifier : String = ""
  var hotkeyFlags : Int = 0
  var hotkeyCode : Int = 0
  var shortcutValue: MASShortcut?

  var displayDescription: String {
    get {
      return "I am a Shortcut"
    }
  }

  override init() {
    super.init()
    name = "New Shortcut"
  }

  // MARK: Marshalling to Plist

  init(dictionary: NSMutableDictionary) {
    name = dictionary.objectForKey("Name") as! String
    action = dictionary.objectForKey("Action") as! String
    identifier = dictionary.objectForKey("Identifier") as! String
    accountIdentifier = dictionary.objectForKey("AccountIdentifier") as! String

    if (dictionary.objectForKey("HotkeyFlags") != nil) && (dictionary.objectForKey("HotkeyFlags") != nil) {
      let flags = UInt((dictionary.objectForKey("HotkeyFlags")?.integerValue)!)
      let code = UInt((dictionary.objectForKey("HotkeyCode")?.integerValue)!)
      shortcutValue = MASShortcut(keyCode: code, modifierFlags: flags)
    }
    else {
      shortcutValue = MASShortcut(keyCode: 23, modifierFlags: 1179648)
    }
  }

  func toDict() -> NSMutableDictionary {
    return NSMutableDictionary(dictionary: [
      "Name":name,
      "Action":action,
      "AccountIdentifier":accountIdentifier,
      "Identifier": identifier,
      "HotkeyFlags": String(shortcutValue!.modifierFlags),
      "HotkeyCode": String(shortcutValue!.keyCode)
    ])
  }

}
