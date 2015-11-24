//
//  Account.swift
//  Captured
//
//  Created by Christopher Sexton on 11/21/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Cocoa

class Account {

  var type : String
  var name : String
  var settings = [String: String]()

  init(withType type: String, andName name:String) {
    self.type = type
    self.name = name

  }

}
