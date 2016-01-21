//
//  ShortcutManager.swift
//  Captured
//
//  Created by Christopher Sexton on 11/23/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Cocoa

class ShortcutManager: NSObject {
  static let sharedInstance = ShortcutManager()

  var shortcuts: [NSMutableDictionary] = Array()
  var defaults = NSUserDefaults.standardUserDefaults()

  func load() {
    shortcuts.removeAll()
    if let accts = (defaults.objectForKey("Shortcuts") as? [NSMutableDictionary]) {
      for acct in accts {
        shortcuts.append(acct)
      }
    }
  }

  func count() -> (Int) {
    return shortcuts.count
  }

  func shortcutAtIndex(i: Int) -> (Shortcut) {
    return Shortcut(dictionary: shortcuts[i])
  }

  func update(updated: Shortcut) {
    var newRecord: Bool = true

    for i in 0...(shortcuts.count-1) {
      if shortcuts[i]["Identifier"] as! String == updated.identifier {
        newRecord = false
        shortcuts[i] = updated.toDict()
      }
    }
    if newRecord {
      shortcuts.append(updated.toDict())
    }

    saveAll()
    notifyUpdates()
  }

  func delete(updated: Shortcut) {
    var deathRow = [Int]()

    for i in 0...(shortcuts.count-1) {
      if shortcuts[i]["Identifier"] as! String == updated.identifier {
        deathRow.append(i)
      }
    }

    for i in deathRow {
      shortcuts.removeAtIndex(i)
    }

    saveAll()
    notifyUpdates()

  }

  func each(block: (Shortcut) -> (Void)) {
    for d in shortcuts {
      block(Shortcut(dictionary: d))
    }
  }


  private func saveAll() {
    defaults.setObject(shortcuts, forKey: "Shortcuts")
  }


  private func notifyUpdates() {
    let name = CapturedNotifications.ShortcutsDidUpdate.rawValue
    NSNotificationCenter.defaultCenter().postNotificationName(name, object: self)
  }

}
