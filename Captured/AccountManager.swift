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
        print("Loading accounts:")
        print(acct)
        accounts.append(acct)
      }
    }
  }
  
  func count() -> (Int) {
    return accounts.count
  }
  
  func accountAtIndex(i:Int) -> (Account) {
    return accountFactory(accounts[i])
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
    
    notifyUpdates()
  }
  
  func delete(updated:Account) {
    
    var deathRow = [Int]()
    
    for i in 0...(accounts.count-1) {
      if accounts[i]["Identifier"] as! String == updated.identifier {
        deathRow.append(i)
      }
    }
    
    for i in deathRow {
      accounts.removeAtIndex(i)
    }
    
    saveAll()
    notifyUpdates()
    
  }
  
  func accountFactory(dictionary:NSMutableDictionary) -> (Account) {
    if let type = dictionary["Type"] as? String {
      switch (type) {
      case "AnonImgur":
        return AnonImgurAccount(dictionary: dictionary)
      case "Imgur":
        return ImgurAccount(dictionary: dictionary)
      case "S3":
        return S3Account(dictionary: dictionary)
      default:
        return Account(dictionary: dictionary)
      }
    }
    return Account(dictionary: dictionary)
  }
  
  private func saveAll() {
    defaults.setObject(accounts, forKey: "Accounts");
  }
  
  private func notifyUpdates() {
    NSNotificationCenter
      .defaultCenter()
      .postNotificationName("AccountsUpdated", object: self)
  }
  
}
