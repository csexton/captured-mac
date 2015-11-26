//
//  AccountManager.swift
//  Captured
//
//  Created by Christopher Sexton on 11/23/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Cocoa

class AccountManager: NSObject {

  var accounts : [NSMutableDictionary] = Array()
  var defaults = NSUserDefaults.standardUserDefaults()

  static let sharedInstance = AccountManager()

  func load() {
    accounts.removeAll()
    if let accts = (defaults.objectForKey("Accounts") as? [NSMutableDictionary]) {
      for acct in accts {
        print(acct)
        accounts.append(acct)
      }
    }
  }

  func count() -> (Int) {
    return accounts.count
  }

  func accountAtIndex(i:Int) -> (Account) {
    return Account(withDict: accounts[i])
  }

  func update(updated:Account) {

    var newRecord: Bool = true

      for i in 0...(accounts.count-1) {
        if accounts[i]["Identifier"] as! String == updated.identifier {
          newRecord = false
          accounts[i] = updated.toDict()
        }
      }
    if (newRecord) {
      accounts.append(updated.toDict())
    }

    defaults.setObject(accounts, forKey: "Accounts");
  }

}
