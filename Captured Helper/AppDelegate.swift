//
//  AppDelegate.swift
//  Captured Helper
//
//  Created by Christopher Sexton on 7/16/16.
//  Copyright © 2016 Christopher Sexton. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  @IBOutlet weak var window: NSWindow!


  func applicationDidFinishLaunching(aNotification: NSNotification) {
    NSLog("Running Helper for \(NSBundle.mainBundle().bundlePath)")
    let bundlePath = NSURL(fileURLWithPath: NSBundle.mainBundle().bundlePath)
    let pathToMainApp = bundlePath.URLByDeletingLastPathComponent!
      .URLByDeletingLastPathComponent!
      .URLByDeletingLastPathComponent!
      .URLByDeletingLastPathComponent!

    //if NSRunningApplication.runningApplicationsWithBundleIdentifier("com.codeography.captured-mac").count > 1 {
    //  NSWorkspace.sharedWorkspace().launchApplication("Captured.app")
    NSWorkspace.sharedWorkspace().launchApplication(pathToMainApp.path!)
    //}

    NSApplication.sharedApplication().terminate(self)
  }

  func applicationWillTerminate(aNotification: NSNotification) {
    // Insert code here to tear down your application
  }

}

