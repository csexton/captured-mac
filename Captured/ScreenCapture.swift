//
//  ScreenCapture.swift
//  Captured
//
//  Created by Christopher Sexton on 11/28/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Cocoa

class ScreenCapture  {
  enum CommandOptions: String {
    case MouseSelection = "-i"
    case WindowSelection = "-W"
  }

  var path : String?

  func run(option:CommandOptions, success:(path:String) -> (Void)) {
    NSLog("%@", "Start Capture Screen")
    let dateFormat: NSDateFormatter = NSDateFormatter()
    dateFormat.dateFormat = "yyyy-MM-dd-HH-mm-ss-SSSSSS"
    
    let timestamp: String = dateFormat.stringFromDate(NSDate())
    
    let path = "\(NSTemporaryDirectory())-\(timestamp).png"
    let task = NSTask()
    task.launchPath = "/usr/sbin/screencapture"
    task.arguments = [option.rawValue, path]
    task.launch()
    task.waitUntilExit()
    if (task.terminationStatus==0) {
      success(path: path)
    }
  }

}
