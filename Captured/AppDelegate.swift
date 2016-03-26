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
import MASShortcut
import StartAtLoginController



@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate,
  NSUserNotificationCenterDelegate {

  var accountManager = AccountManager.sharedInstance
  var shortcutManager = ShortcutManager.sharedInstance
  var shortcutMonitor = MASShortcutMonitor.sharedMonitor()

  var annotatedWindow: AnnotatedImageController?
  let enabledMenuItem = NSMenuItem()

  private let queue = dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)

  // The magic tag that is used to denote a menu item is for a "shortcut." This
  // is used to remove all menu items associated with a tag.
  let magicShortcutMenuItemTag = 13
  let magicEnabledMenuItemTag = 13

  // MARK: App Delegates

  func applicationWillFinishLaunching(notification: NSNotification) {
    // Prevent launching and process the command line
  }

  func applicationDidFinishLaunching(aNotification: NSNotification) {

    // RVNValidateAndRunApplication(Process.argc, Process.unsafeArgv)

    setDefaultDefaults()
    accountManager.load()
    shortcutManager.load()
    createStatusMenu()

    registerShortcuts()
    setupNotificationListeners()
    setupDockIcon()

    NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self

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

  // MARK: Drag and Drop

  func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
    let pboard = sender.draggingPasteboard()
    if let urls = pboard.readObjectsForClasses([NSURL.self], options:nil) {
      if urls.count == 1 {
        return .Copy
      }
    }
    return .None
  }

  func performDragOperation(sender: NSDraggingInfo) -> Bool {
    let pboard = sender.draggingPasteboard()
    if let urls = pboard.readObjectsForClasses([NSURL.self], options:nil) {
      for url in urls {

        let path = url.relativePath!!
        let amanager = AccountManager()
        amanager.load()
        let account = AccountManager.sharedInstance.accountWithIdentifier("C93D5479-6BA1-4E04-9C5D-978EF4174B8F")!

        dispatch_async(queue) {
          Command().run(account, path:path)
        }

        print("Dragged URLS: \(url.relativePath)")

        return true
      }
    }
    return false
  }

  // MARK: Notification Delegate

  func userNotificationCenter(center: NSUserNotificationCenter,
    didActivateNotification notification: NSUserNotification) {
    if let userInfo = notification.userInfo, let url = userInfo["url"] as? String {
      NSWorkspace.sharedWorkspace().openURL(NSURL(string: url)!)
    }

  }

  // MARK: Preferences Window

  var preferencesController: NSWindowController?

  @IBAction func showPreferences(sender: AnyObject) {
    NSApplication.sharedApplication().activateIgnoringOtherApps(true)
    if preferencesController == nil {
      let storyboard = NSStoryboard(name: "Preferences", bundle: nil)
      preferencesController = storyboard.instantiateInitialController() as? NSWindowController
    }
    if preferencesController != nil {
      preferencesController!.showWindow(sender)
    }
  }

  // MARK: Status Menu

  let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSSquareStatusItemLength)

  func createStatusMenu() {
    setGlobalState(.Normal)
    let menu = NSMenu()

    menu.addItem(NSMenuItem.separatorItem())
    //    enabledMenuItem = NSMenuItem(title: "Enabled", action: Selector("toggleEnabled:"), keyEquivalent: "")
    //    enabledMenuItem!.state = NSUserDefaults.standardUserDefaults().integerForKey("EnableUploads")
    let defaults = NSUserDefaults.standardUserDefaults()

    enabledMenuItem.title = "Enabled"
    enabledMenuItem.bind("value", toObject: defaults, withKeyPath: "EnableUploads", options: nil)

    menu.addItem(enabledMenuItem)
    menu.addItem(NSMenuItem(title: "Preferences...",
      action: #selector(AppDelegate.showPreferences(_:)), keyEquivalent: ""))
    menu.addItem(NSMenuItem(title: "Quit Captured",
      action: #selector(terminate), keyEquivalent: ""))

    if let button = statusItem.button, let window = button.window {
      window.registerForDraggedTypes([NSFilenamesPboardType])
      window.delegate = self
    }

    statusItem.menu = menu
  }

  func terminate() {
    NSApplication.sharedApplication().terminate(self)
  }


  func setGlobalState(state: CapturedState.States) {
    playSoundForState(state)
    if let button = statusItem.button {
      let image = imageForState(state)
      button.image = image
    }
  }

  func playSoundForState(status: CapturedState.States) {
    if NSUserDefaults.standardUserDefaults().boolForKey("PlaySoundAfterUpload") {
      if status == .Success {
        if let sound = NSSound(named: "Hero") { sound.play() }
      }
      if status == .Error {
        if let sound = NSSound(named: "Sosumi") { sound.play() }
      }
    }
  }

  func imageForState(status: CapturedState.States) -> NSImage {
    var img: NSImage?

    switch status {
    case .Normal:
      img = NSImage(named: "StatusMenu")!
      img!.template = true
    case .Disabled:
      img = NSImage(named: "StatusMenuDisabled")!
      img!.template = true
    case .Active:
      img = NSImage(named: "StatusMenuActive")!
    case .Success:
      img = NSImage(named: "StatusMenuSuccess")!
    case .Error:
      img = NSImage(named: "StatusMenuError")!
    }

    return img!
  }

  // MARK: Dock Icon

  func setupDockIcon() {
    if NSUserDefaults.standardUserDefaults().boolForKey("EnableDockIcon") {
      let transformState = ProcessApplicationTransformState(kProcessTransformToForegroundApplication)
      var psn = ProcessSerialNumber(highLongOfPSN: 0, lowLongOfPSN: UInt32(kCurrentProcess))
      TransformProcessType(&psn, transformState)
    }
  }

  // MARK: Global App State

  func stateDidChange(state: CapturedState) {
    setGlobalState(state.current)
  }

  // MARK: Manage Global HotKey and Shortcuts

  private func setupNotificationListeners() {
    let nc = NSNotificationCenter.defaultCenter()
    let shortcut = CapturedNotifications.ShortcutsDidUpdate.rawValue
    let state = CapturedNotifications.StateDidChange.rawValue

    nc.addObserver(self, selector: #selector(AppDelegate.registerShortcuts), name: shortcut, object: nil)
    nc.addObserverForName(shortcut, object: nil, queue: nil) { _ in
      self.registerShortcuts()
    }

    nc.addObserverForName(state, object: nil, queue: nil) { notification in
      if let info = notification.userInfo as? [String:AnyObject] {
//        if let s = info["state"] as? Int, newState = CapturedState(rawValue: s) {
//          self.stateDidChange(newState)
//        }
        if let s = info["state"] as? CapturedState {
          self.stateDidChange(s)
        }
      }
    }
  }

  func registerShortcuts() {
    var items = [NSMenuItem]()
    for item in statusItem.menu!.itemArray {
      if item.tag == magicShortcutMenuItemTag {
        items.append(item)
      }
    }

    for item in items {
      statusItem.menu!.removeItem(item)
    }

    shortcutMonitor.unregisterAllShortcuts()
    shortcutManager.each { (shortcut) -> (Void) in
      self.registerHotKey(shortcut)
      self.createShortcutMenu(shortcut)
    }
  }

  private func registerHotKey(shortcut: Shortcut) {
    if let sc = shortcut.shortcutValue {
      shortcutMonitor.registerShortcut(sc) {
        self.runShortcut(shortcut)
      }
    }
  }

  private func createShortcutMenu(shortcut: Shortcut) {
    if let sc = shortcut.shortcutValue {
      let menuItem = NSMenuItem(title: shortcut.name, action: #selector(AppDelegate.menuShortcut(_:)), keyEquivalent: sc.keyCodeString)
      menuItem.keyEquivalentModifierMask = Int(sc.modifierFlags)
      menuItem.representedObject = shortcut
      menuItem.tag = magicShortcutMenuItemTag

      statusItem.menu!.insertItem(menuItem, atIndex: 0)
    }
  }

  private func runShortcut(shortcut: Shortcut) {
    dispatch_async(queue) {
      Command().run(shortcut)
    }
  }

  @IBAction func menuShortcut(sender: NSMenuItem) {
    if let shortcut = sender.representedObject as? Shortcut {
      runShortcut(shortcut)
    }
  }

}
