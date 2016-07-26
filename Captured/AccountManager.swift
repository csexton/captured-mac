//
//  AccountManager.swift
//  Captured
//
//  Created by Christopher Sexton on 11/23/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Cocoa

class AccountManager: NSObject {

  enum AccountTypes: String {
    case Imgur = "Imgur"
    case S3 = "Amazon S3"
    case AnonImgur = "anonymous Imgur"
  }

  static let sharedInstance = AccountManager()

  var accounts: [NSMutableDictionary] = Array()
  var defaults = NSUserDefaults.standardUserDefaults()

  func load() {
    accounts.removeAll()
    if let accts = (defaults.objectForKey("Accounts") as? [NSMutableDictionary]) {
      for acct in accts {
        accounts.append(acct)
      }
    }
  }

  func count() -> (Int) {
    return accounts.count
  }

  func accountAtIndex(index: Int) -> (Account) {
    return accountFactory(accounts[index])
  }

  func update(updated: Account) {

    var newRecord: Bool = true

    if accounts.count > 0 {
      for i in 0...(accounts.count-1) {
        if accounts[i]["Identifier"] as! String == updated.identifier {
          newRecord = false
          accounts[i] = updated.toDict()
        }
      }
    }
    if newRecord {
      accounts.append(updated.toDict())
    }

    updated.saveSecrets()
    saveAll()
    notifyUpdates()
  }

  func delete(updated: Account) {

    var deathRow = [Int]()

    for i in 0...(accounts.count-1) {
      if accounts[i]["Identifier"] as? String == updated.identifier {
        deathRow.append(i)
      }
    }

    for i in deathRow {
      accounts.removeAtIndex(i)
    }

    saveAll()
    notifyUpdates()

  }

  func accountWithIdentifier(identifier: String) -> (Account?) {
    for i in 0...(accounts.count-1) {
      if accounts[i]["Identifier"] as? String == identifier {
        return accountFactory(accounts[i])
      }
    }
    return nil
  }


  func indexForAccountWithIdentifier(identifier: String) -> (Int) {
    for i in 0...(accounts.count-1) {
      if accounts[i]["Identifier"] as? String == identifier {
        return i
      }
    }
    return -1
  }

  func eachAccount(block: (Account) -> (Void)) {
    for d in accounts {
      block(accountFactory(d))
    }
  }

  func accountFactory(dictionary: NSMutableDictionary) -> (Account) {
    if let type = dictionary["Type"] as? String {
      switch type {
      case "Imgur":
        return ImgurAccount(dictionary: dictionary)
      case "SFTP":
        return SFTPAccount(dictionary: dictionary)
      case "Amazon S3":
        return S3Account(dictionary: dictionary)
      case "Captured PHP":
        return PHPAccount(dictionary: dictionary)
      default:
        return Account(dictionary: dictionary)
      }
    }
    return Account(dictionary: dictionary)
  }

  private func saveAll() {
    defaults.setObject(accounts, forKey: "Accounts")
  }

  private func notifyUpdates() {
    let name = CapturedNotifications.AccountsDidUpdate.rawValue
    NSNotificationCenter.defaultCenter().postNotificationName(name, object: self)
  }

}
