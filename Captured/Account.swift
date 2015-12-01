//
//  Account.swift
//  Captured
//
//  Created by Christopher Sexton on 11/21/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Cocoa

class Account:  NSObject {

  var type : String
  var name : String
  var readOnly : Bool
  var identifier : String
  var options : [String:AnyObject]

  var settings = [String: String]()

  convenience init(withType type: String, name:String, identifier:String, opts:[String:AnyObject]) {
    let d = [
      "Type": type,
      "Name": name,
      "Identifier": identifier,
      "Options": opts,
    ]
    self.init(withDict: d as! NSMutableDictionary)
  }

  init(withDict opts: NSMutableDictionary) {
    type = "Default"
    name  = ""
    identifier = ""
    readOnly = false
    options = [:]

    if let o = opts["Type"] as? String { type = o }
    if let o = opts["Name"] as? String { name = o }
    if let o = opts["ReadOnly"] as? Bool {readOnly = o }
    if let o = opts["Identifier"] as? String { identifier = o }
    if let o = opts["Options"] as? [String:AnyObject] { options = o }
  }

  func toDict() -> (NSMutableDictionary) {
    return [
      "Type": type,
      "Name": name,
      "ReadOnly": readOnly,
      "Identifier": identifier,
      "Options": options
    ]
  }

}
