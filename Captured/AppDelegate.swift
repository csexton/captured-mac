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

  // MARK: App Delegates

  func applicationWillFinishLaunching(notification: NSNotification) {
    // Prevent launching and process the command line
  }

  func applicationDidFinishLaunching(aNotification: NSNotification) {
    // Insert code here to initialize your application



    setDefaultDefaults()
    accountManager.load()
    createStatusMenu()

    //accountManager.arrayController = accountsArrayController

//    var sc = ScreenCapture()
//    sc.run(.MouseSelection)
//    print(sc.path)

//    if (false) {
//      let oauthOpts = [
//        "access_token":"2e40ee182ffc627094a9ce2d7e929f9182a6f646",
//        "expires_in": "2419200",
//        "token_type":"bearer",
//        "refresh_token":"564a90a92dd7e71ed6ff38a9b327fb63c94dcecc",
//        "account_id": "147584",
//        "account_username":"csexton",
//      ]
//      let anonOpts = [
//        "client_id": (NSUserDefaults.standardUserDefaults().objectForKey("ImgurClientID") as! String)
//      ]
//      
//      let i = "/Users/csexton/src/captured-mac/Captured/Assets.xcassets/AppIcon.appiconset/icon_128x128@2x.png"
//      let u = ImgurUploader(withOptions: anonOpts)
//      let b = u.upload(i as String)
//      
//    }

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

