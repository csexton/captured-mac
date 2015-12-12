//
//  Account.swift
//  Captured
//
//  Created by Christopher Sexton on 11/21/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Cocoa

class Account:  NSObject {

  dynamic var name = ""
  var readOnly = Bool(false)
  var identifier : String = NSUUID().UUIDString
  var options = [String:String]()
  var type : String = ""

  var displayType : String {
    get {
      return "\(type) Account"
    }
  }
  

  // MARK: Initers

  override init() {
    super.init()
    type = accountType()
  }

  // MARK: Methods
  func mergeOptions(dict: [String:String]) {
    for (key, value) in dict {
      options[key] = value
    }
  }

  func accountType() -> String {
    return "None"
  }

  // MARK: Marshalling to Plist

  init(dictionary: NSMutableDictionary) {
    type = dictionary.objectForKey("Type") as! String
    name = dictionary.objectForKey("Name") as! String
    readOnly = dictionary["ReadOnly"] as! Bool
    identifier = dictionary.objectForKey("Identifier") as! String
    options = dictionary.objectForKey("Options") as! [String:String]
  }

  func toDict() -> NSMutableDictionary {
    return NSMutableDictionary(dictionary: [
      "Type":type,
      "Name":name,
      "ReadOnly": Bool(readOnly),
      "Identifier": identifier,
      "Options": options
    ])
  }



}
