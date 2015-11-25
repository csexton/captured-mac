//
//  AccountManager.swift
//  Captured
//
//  Created by Christopher Sexton on 11/23/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Cocoa

class AccountManager: NSObject {

  var array : [Account] = Array()
  var defaults = NSUserDefaults.standardUserDefaults()

  func load() {
    if let accts = (defaults.objectForKey("Accounts") as? [[String:AnyObject]]) {

      for acct in accts {
        print(acct)
        array.append(Account(withDict: acct))
      }
    }
  }

}
