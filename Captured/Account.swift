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
  var secrets = [String:String]()
  var type: String = ""

  private let locksmithService = "Captured"
  private var locksmithUserAccount: String {
    get {
      return "\(type): \(identifier)"
    }
  }

  // MARK: Initers

  override init() {
    super.init()
    type = accountType()
    loadSecrets()
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
    self.saveSecrets()
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
      try Locksmith.updateData(secrets, forUserAccount: locksmithUserAccount,
        inService: locksmithService)
    } catch {
      print(error)
    }
  }

  func loadSecrets() {
    if let s = Locksmith.loadDataForUserAccount(locksmithUserAccount,
      inService: locksmithService) as? [String:String] {
      secrets = s
    }
  }



}
