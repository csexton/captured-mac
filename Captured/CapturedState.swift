//
//  CapturedState.swift
//  Captured
//
//  Created by Christopher Sexton on 12/19/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Cocoa

class CapturedState {
  enum States {
    case Normal
    case Disabled
    case Active
    case Success
    case Error
  }

  var current : CapturedState.States

  init(state:CapturedState.States) {
    current = state
  }

  class func broadcastStateChange(state:States){
    let name = CapturedNotifications.StateDidChange.rawValue
    NSNotificationCenter.defaultCenter().postNotificationName(name, object: self,
      userInfo: ["state": CapturedState(state: state)]
    )
  }
}