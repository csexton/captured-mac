//
//  ScreenCapture.swift
//  Captured
//
//  Created by Christopher Sexton on 11/28/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Cocoa

class ScreenCapture  {

  var path = ""
  var status : Int32 = 1
  var success : Bool = false

  enum CommandOptions: String {
    case MouseSelection = "-i"
    case WindowSelection = "-W"
  }

  func run(option:CommandOptions) -> (success:Bool, path:String) {
    
    NSLog("%@", "Start Capture Screen")
    let dateFormat: NSDateFormatter = NSDateFormatter()
    dateFormat.dateFormat = "yyyy-MM-dd-HH-mm-ss-SSSSSS"
    
    let timestamp: String = dateFormat.stringFromDate(NSDate())
    
    path = "\(NSTemporaryDirectory())-\(timestamp).png"
    let task = NSTask()
    task.launchPath = "/usr/sbin/screencapture"
    task.arguments = [option.rawValue, path]
    task.launch()
    task.waitUntilExit()
    status = task.terminationStatus
    success = (status==0)

    return (success, path)
  }

}
