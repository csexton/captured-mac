//
//  Shortcut.swift
//  Captured
//
//  Created by Christopher Sexton on 11/23/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Cocoa

class Shortcut: NSObject {

  dynamic var name = ""
  var identifier : String = NSUUID().UUIDString
  var accountIdentifier : String = ""
  var hotkeyFlags : Int = 0
  var hotkeyCode : Int = 0

  var displayDescription: String {
    get {
      return "I am a Shortcut"
    }
  }


  // MARK: Marshalling to Plist

  init(dictionary: NSMutableDictionary) {
    name = dictionary.objectForKey("Name") as! String
    identifier = dictionary.objectForKey("Identifier") as! String
    accountIdentifier = dictionary.objectForKey("Identifier") as! String
    hotkeyFlags = (dictionary.objectForKey("HotkeyFlags")?.integerValue)!
    hotkeyCode = (dictionary.objectForKey("HotkeyCode")?.integerValue)!
  }

  func toDict() -> NSMutableDictionary {
    return NSMutableDictionary(dictionary: [
      "Name":name,
      "AccountIdentifier":accountIdentifier,
      "Identifier": identifier,
      "HotkeyFlags": String(hotkeyFlags),
      "HotkeyCode": String(hotkeyCode)
    ])
  }

}
