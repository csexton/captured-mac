//
//  AccountManager.swift
//  Captured
//
//  Created by Christopher Sexton on 11/23/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Cocoa

class AccountManager: NSObject {

  var accounts : [[String:AnyObject]] = Array()
  var defaults = NSUserDefaults.standardUserDefaults()

  static let sharedInstance = AccountManager()

  func load() {
    accounts.removeAll()
    if let accts = (defaults.objectForKey("Accounts") as? [[String:AnyObject]]) {
      for acct in accts {
        print(acct)
        accounts.append(acct)
      }
    }
  }

  func count() -> (Int) {
    return accounts.count
  }

  func dictonaryAtIndex(i:Int) -> ([String:AnyObject]) {
    return accounts[i]
  }

  func update(updated:[String:AnyObject]) {
    if let identifier = updated["Identifier"] as? String {
      for i in 0...(accounts.count-1) {
        if accounts[i]["Identifier"] as! String == identifier {
          accounts[i] = updated
        }
      }
    }
    else {
      accounts.append(updated)
    }

    defaults.setObject(accounts, forKey: "Accounts");
  }

}
