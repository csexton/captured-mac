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
    self.init(withDict: d as! [String : AnyObject])
  }

  init(withDict opts: [String: AnyObject]) {
    type = opts["Type"] as! String
    name  = opts["Name"] as! String
    preventDelete = opts["PreventDelete"] as! Bool
    identifier = opts["Identifier"] as! String
    options = opts["Options"] as! [String:AnyObject]

  }

}
