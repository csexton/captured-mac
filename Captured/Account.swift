//
//  Account.swift
//  Captured
//
//  Created by Christopher Sexton on 11/21/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Cocoa

class Account:  NSObject {

  dynamic var type : String
  dynamic var name : String
  var preventDelete : Bool
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
    type = opts["Type"] as! String
    name  = opts["Name"] as! String
    preventDelete = opts["PreventDelete"] as! Bool
    identifier = opts["Identifier"] as! String
    options = opts["Options"] as! [String:AnyObject]

  }

  func toDict() -> (NSMutableDictionary) {
    return [
      "Type": type,
      "Name": name,
      "Identifier": identifier,
      "Options": options
    ]
  }

}
