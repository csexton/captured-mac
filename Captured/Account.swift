//
//  Account.swift
//  Captured
//
//  Created by Christopher Sexton on 11/21/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Cocoa

class Account:  NSObject {

  var type = "none"
  var name = ""
  var readOnly:Bool = Bool(false)
  var identifier:String = ""
  var options = [String:String]()

  // MARK: Initers

  init (type:String, name:String, readOnly:Bool, identifier:String, options:[String:String]) {
    self.type = type
    self.name = name
    self.readOnly = readOnly
    self.identifier = identifier
    self.options = options

  }

  override init() {
    super.init()
  }

  // MARK: Methods
  func mergeOptions(dict: [String:String]) {
    for (key, value) in dict {
      options[key] = value
    }
  }


  // MARK: Martialing to Plist

  required convenience init(dictionary: NSMutableDictionary) {
    self.init()
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
