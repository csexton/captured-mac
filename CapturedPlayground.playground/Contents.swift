//: Playground - noun: a place where people can play

import Cocoa

class Account: NSObject {

  var type : String
  var name : String
  var settings = [String: String]()

  init(withType type: String, andName name:String) {
    self.type = type
    self.name = name

  }
  
}

var str = "Hello, playground"
