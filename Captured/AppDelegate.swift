//
//  AppDelegate.swift
//  Captured

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
    let icon = NSImage(named: "StatusMenu")
    icon?.template = true

    self.statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)

    if let item = self.statusItem {
      item.menu = self.statusMenu
      item.image = icon
      item.highlightMode = true
    }

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
    print("Action pressed")
    showSettings(sender)
  }


  func showSettings(sender: AnyObject?) {
    if settingsWindow == nil {
      settingsWindow = SettingsWindowController(windowNibName: "Settings")
    }

    settingsWindow!.window?.orderFront(nil)

    //    settingsWindow!.showWindow(sender)


    print(settingsWindow);
  }


}

