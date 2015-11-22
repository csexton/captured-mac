//
//  AppDelegate.swift
//  Captured
//
//  Created by Christopher Sexton on 11/20/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  // MARK: App Delegates

  func applicationDidFinishLaunching(aNotification: NSNotification) {
    // Insert code here to initialize your application
    createStatusMenu()

  }

  func applicationWillTerminate(aNotification: NSNotification) {
    // Insert code here to tear down your application
  }

  // MARK: Preferences Window

  var preferencesController: NSWindowController?

  @IBAction func showPreferences(sender : AnyObject) {
    if (preferencesController == nil) {
      let storyboard = NSStoryboard(name: "Preferences", bundle: nil)
      preferencesController = storyboard.instantiateInitialController() as? NSWindowController
    }
    if (preferencesController != nil) { preferencesController!.showWindow(sender) }
  }

  // MARK: Status Menu

  let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSSquareStatusItemLength)

  func createStatusMenu() {
    if let button = statusItem.button {
      if let image = NSImage(named: "StatusMenu") {
        image.template = true
        button.image = image
      }
    }
    let menu = NSMenu()

    menu.addItem(NSMenuItem(title: "Preferences...", action: Selector("showPreferences:"), keyEquivalent: ""))
    menu.addItem(NSMenuItem.separatorItem())
    menu.addItem(NSMenuItem(title: "Preferences...", action: Selector("showPreferences:"), keyEquivalent: ""))

    statusItem.menu = menu

  }




}

