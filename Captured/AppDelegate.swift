//
//  AppDelegate.swift
//  Captured
//
//  Created by Christopher Sexton on 11/20/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Cocoa
import AppKit
import Carbon


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  var hotKeyCenter = DDHotKeyCenter.sharedHotKeyCenter()
  var accountManager = AccountManager.sharedInstance
  var shortcutManager = ShortcutManager.sharedInstance

  // MARK: App Delegates

  func applicationWillFinishLaunching(notification: NSNotification) {
    // Prevent launching and process the command line
  }

  func applicationDidFinishLaunching(aNotification: NSNotification) {

    setDefaultDefaults()
    accountManager.load()
    shortcutManager.load()
    createStatusMenu()


    if (true) {
      //asyncCompletionHandler: { (result: HTTPResult!) -> Void in

      hotKeyCenter.registerHotKeyWithKeyCode(UInt16(kVK_ANSI_V), modifierFlags: (NSEventModifierFlags.ControlKeyMask.rawValue), task: { _ in

        print("hot")

        })

    }
    
  }

  func applicationWillTerminate(aNotification: NSNotification) {
    // Insert code here to tear down your applicat
  }

  func setDefaultDefaults() {
    if let path = NSBundle.mainBundle().pathForResource("Defaults", ofType: "plist") {
      let defaultDict: [String : AnyObject] = NSDictionary(contentsOfFile: path)! as! [String : AnyObject]
      NSUserDefaults.standardUserDefaults().registerDefaults(defaultDict)
    }
  }

  // MARK: Preferences Window

  var preferencesController: NSWindowController?

  @IBAction func showPreferences(sender : AnyObject) {

    NSApplication.sharedApplication().activateIgnoringOtherApps(true)
    if (preferencesController == nil) {
      let storyboard = NSStoryboard(name: "Preferences", bundle: nil)
      preferencesController = storyboard.instantiateInitialController() as? NSWindowController
    }
    if (preferencesController != nil) {
      preferencesController!.showWindow(sender)
    }
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

