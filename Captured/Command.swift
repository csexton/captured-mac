//
//  Command.swift
//  Captured
//
//  Created by Christopher Sexton on 12/18/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Foundation


class Command {
  
  var shortcut : Shortcut
  
  init(shortcut:Shortcut) {
    self.shortcut = shortcut
  }
  
  private func run(){
    print(self.shortcut.accountIdentifier)
    runScreenCapture()
    runUpload()
    resetGlobalStateAfterDelay()
  }

  private func runScreenCapture() {
    print("run screen capture for \(shortcut.name)")
    let sc = ScreenCapture()
    sc.run(shortcut.screenCaptureOptions()) { path in
      CapturedState.broadcastStateChange(.Active)
      print("captured \(path)")
    }
  }

  private func runUpload() {
    print("run upload for \(shortcut.accountIdentifier)")
  }
  
  
  func runAsync(){
    dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {
      self.run()
    }
  }
  
  private func resetGlobalStateAfterDelay() {
    // Delay 5 seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(5.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
      CapturedState.broadcastStateChange(.Normal)
    }
  }
  
}

