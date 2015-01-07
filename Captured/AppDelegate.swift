//
//  AppDelegate.swift
//  Captured
//
//  Created by Christopher Sexton on 12/13/14.
//  Copyright (c) 2014 Codeography. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  var settingsWindow: SettingsWindowController?

  @IBOutlet var statusMenu: NSMenu!
  var statusItem: NSStatusItem? = nil




  func applicationDidFinishLaunching(aNotification: NSNotification) {
    // Insert code here to initialize your application
  }

  func applicationWillTerminate(aNotification: NSNotification) {
    // Insert code here to tear down your application
  }


  override func awakeFromNib() {
    self.statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
    self.statusItem!.menu = self.statusMenu
    var icon = NSImage(named: "StatusMenu")
    icon?.setTemplate(true)
    self.statusItem!.image = icon
    self.statusItem!.highlightMode = true

    /*
    NSImage *icon = [NSImage imageNamed:@"iconName"];
    //This is the only way to be compatible to all ~30 menu styles (e.g. dark mode) available in Yosemite
    [normalImage setTemplate:YES];
    statusItem.button.image = normalImage;

    // register with an array of types you'd like to accept
    [statusItem.button.window registerForDraggedTypes:@[NSFilenamesPboardType]];
    statusItem.button.window.delegate = self;
*/
  }

  @IBAction func doSomethingWithMenuSelection(sender : AnyObject?) {
    println("Action pressed")
    showSettings(sender)
  }


  func showSettings(sender: AnyObject?) {
    settingsWindow = SettingsWindowController(windowNibName: "Settings");
    println(settingsWindow);

    settingsWindow!.showWindow(sender)
  }


}

