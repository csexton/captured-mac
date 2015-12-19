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
  dynamic var summary = ""
  var action : String = "SelectArea"
  var identifier : String = NSUUID().UUIDString
  var accountIdentifier : String = ""
  var hotkeyFlags : Int = 0
  var hotkeyCode : Int = 0
  var shortcutValue: MASShortcut?
  dynamic var playSound = Bool(false)
  dynamic var scaleImage = Bool(false)

  override init() {
    super.init()
    name = "New Shortcut"
  }

  // MARK: Marshalling to Plist

  init(dictionary: NSMutableDictionary) {
    name = dictionary.objectForKey("Name") as! String
    summary = dictionary.objectForKey("Summary") as! String
    action = dictionary.objectForKey("Action") as! String
    identifier = dictionary.objectForKey("Identifier") as! String
    accountIdentifier = dictionary.objectForKey("AccountIdentifier") as! String
    playSound = dictionary["PlaySound"] as! Bool
    scaleImage = dictionary["ScaleImage"] as! Bool

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
      "Summary":summary,
      "Action":action,
      "AccountIdentifier":accountIdentifier,
      "Identifier": identifier,
      "HotkeyFlags": String(shortcutValue!.modifierFlags),
      "HotkeyCode": String(shortcutValue!.keyCode),
      "PlaySound": Bool(playSound),
      "ScaleImage": Bool(scaleImage),

    ])
  }

  // MARK: ScreenCapture

  func screenCaptureOptions() -> (ScreenCapture.CommandOptions) {
    switch(action) {
    case "SelectWindow":
      return .WindowSelection
    default:
      return .MouseSelection
    }
  }


}
