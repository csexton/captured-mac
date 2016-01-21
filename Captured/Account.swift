//
//  Account.swift
//  Captured
//
//  Created by Christopher Sexton on 11/21/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Cocoa
import Locksmith

class Account: NSObject {
  dynamic var name = ""
  dynamic var summary = ""
  var readOnly = Bool(false)
  var identifier: String = NSUUID().UUIDString
  var type: String = ""

  var secrets = [String:String]()

  private let locksmithService = "Captured"
  private var locksmithUserAccount: String {
    get {
      return "\(type): \(identifier)"
    }
  }

  // MARK: Initers

  override init() {
    super.init()
    loadSecrets()
    type = accountType()
  }

  // MARK: Methods

  func accountType() -> String {
    return "None"
  }

  // MARK: Marshalling to Plist

  init(dictionary: NSMutableDictionary) {
    super.init()

    type = dictionary.objectForKey("Type") as! String
    name = dictionary.objectForKey("Name") as! String
    summary = dictionary.objectForKey("Summary") as! String
    readOnly = dictionary["ReadOnly"] as! Bool
    identifier = dictionary.objectForKey("Identifier") as! String

    loadSecrets()
  }

  func toDict() -> NSMutableDictionary {
    return NSMutableDictionary(dictionary: [
      "Type":type,
      "Name":name,
      "Summary":summary,
      "ReadOnly": Bool(readOnly),
      "Identifier": identifier,
    ])
  }

  func saveSecrets() {
    do {
      if secrets.count > 0 {
        try Locksmith.updateData(secrets, forUserAccount: locksmithUserAccount,
          inService: locksmithService)
      }
    } catch {
      NSLog("Locksmith Error: \(error)")
    }
  }

  func loadSecrets() {
    if let s = Locksmith.loadDataForUserAccount(locksmithUserAccount,
      inService: locksmithService) as? [String:String] {
        secrets = s
    }
  }

}
