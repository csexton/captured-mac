//
//  Command.swift
//  Captured
//
//  Created by Christopher Sexton on 12/18/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Foundation
import Cocoa

class Command {
  
  var shortcut : Shortcut
  
  init(shortcut:Shortcut) {
    self.shortcut = shortcut
  }
  
  private func run(){
    ScreenCapture().run(shortcut.screenCaptureOptions()) { path in
      CapturedState.broadcastStateChange(.Active)

      if let account = self.shortcut.getAccount() {
        Upload(account: account, path: path).run() { upload in
          print(upload)
          if let url = upload.url {
            self.copyToPasteboard(url)
          }
          self.resetGlobalStateAfterDelay()
        }
      }
    }
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

  private func copyToPasteboard(text: String) {
      let pasteboard = NSPasteboard.generalPasteboard()
      pasteboard.clearContents()
      pasteboard.setString(text, forType: NSPasteboardTypeString)
  }


  
}

