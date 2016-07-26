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

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate,
  NSUserNotificationCenterDelegate {
  let defaults = NSUserDefaults.standardUserDefaults()
  var accountManager = AccountManager.sharedInstance
  var shortcutManager = ShortcutManager.sharedInstance
  var shortcutMonitor = MASShortcutMonitor.sharedMonitor()

  var annotatedWindow: AnnotatedImageController?
  let enabledMenuItem = NSMenuItem()
  let firstRunPopover = NSPopover()
  var firstRunTimer = NSTimer()
  var eventMonitor: EventMonitor?

  var statusItem: NSStatusItem?
  let statusMenu = NSMenu()

  private let queue = dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)

  // The magic tag that is used to denote a menu item is for a "shortcut." This
  // is used to remove all menu items associated with a tag.
  let magicShortcutMenuItemTag = 13

  // MARK: App Delegates

  func applicationWillFinishLaunching(notification: NSNotification) {
    setDefaultDefaults()
    accountManager.load()
    shortcutManager.load()

    // Prevent launching and process the command line
    CLI.run_and_terminate(Process.arguments)
  }

  func applicationDidFinishLaunching(aNotification: NSNotification) {
    setupStatusMenu()
    setupStatusItem()
    registerShortcuts()
    setupNotificationListeners()
    setupDockIcon()
    showPopoverOnFirstRun()
    NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
  }

  func applicationWillTerminate(aNotification: NSNotification) {
    // Insert code here to tear down your applicat
  }

  func setDefaultDefaults() {
    if let path = NSBundle.mainBundle().pathForResource("Defaults", ofType: "plist") {
      let defaultDict: [String : AnyObject] = NSDictionary(contentsOfFile: path)! as! [String : AnyObject]
      defaults.registerDefaults(defaultDict)
    }
  }

  // MARK: Drag and Drop

  func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
    let pboard = sender.draggingPasteboard()
    if let urls = pboard.readObjectsForClasses([NSURL.self], options:nil) {
      if urls.count == 1 {
        if defaults.boolForKey("EnableDrag") == true {
          return .Copy
        }
      }
    }
    return .None
  }

  func performDragOperation(sender: NSDraggingInfo) -> Bool {
    let pboard = sender.draggingPasteboard()
    if let urls = pboard.readObjectsForClasses([NSURL.self], options:nil) {
      for url in urls {
        let path = url.relativePath!!
        if let identifier = defaults.objectForKey("DragAccountIdentifier") as? String {
          let account = AccountManager.sharedInstance.accountWithIdentifier(identifier)!
          dispatch_async(queue) {
            Command().run(account, path:path)
          }
        }

        NSLog("Dragged URLS: \(url.relativePath)")
        return true
      }
    }
    return false
  }

  // MARK: Notification Delegate

  func userNotificationCenter(center: NSUserNotificationCenter,
    didActivateNotification notification: NSUserNotification) {
    if let userInfo = notification.userInfo, url = userInfo["url"] as? String {
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

  func setupStatusMenu() {

    statusMenu.addItem(NSMenuItem.separatorItem())
    enabledMenuItem.title = "Enabled"
    enabledMenuItem.bind("value", toObject: defaults, withKeyPath: "EnableUploads", options: nil)

    statusMenu.addItem(enabledMenuItem)
    statusMenu.addItem(NSMenuItem(title: "Preferences...",
      action: #selector(AppDelegate.showPreferences(_:)), keyEquivalent: ""))
    if AppMode.debug() {
      statusMenu.addItem(NSMenuItem.separatorItem())
      statusMenu.addItem(NSMenuItem(title: "Debug Mode",
        action: nil, keyEquivalent: ""))
      statusMenu.addItem(NSMenuItem(title: "First Run...",
        action: #selector(self.togglePopover), keyEquivalent: ""))
    }
    statusMenu.addItem(NSMenuItem.separatorItem())
    statusMenu.addItem(NSMenuItem(title: "Quit Captured",
      action: #selector(terminate), keyEquivalent: ""))

  }

  func setupStatusItem() {
    if defaults.boolForKey("EnableMenuBarIcon") {
      statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSSquareStatusItemLength)
      statusItem!.menu = statusMenu
      setGlobalState(.Normal)

      if let button = statusItem!.button, window = button.window {
        window.registerForDraggedTypes([NSFilenamesPboardType])
        window.delegate = self
      }
    } else {
      if let statusItem = statusItem {
        NSStatusBar.systemStatusBar().removeStatusItem(statusItem)
      }
    }
  }

  func statusMenuClicked(sender: AnyObject?) {
    closePopover(sender)
    statusItem?.popUpStatusItemMenu(statusMenu)
  }

  func terminate() {
    NSApplication.sharedApplication().terminate(self)
  }

  func setGlobalState(state: CapturedState.States) {
    playSoundForState(state)
    if let statusItem = statusItem, button = statusItem.button {
      let image = imageForState(state)
      button.image = image
    }
  }

  func playSoundForState(status: CapturedState.States) {
    if defaults.boolForKey("PlaySoundAfterUpload") {
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

  // MARK: First Run

  func showPopoverOnFirstRun() {
    if defaults.boolForKey("FirstRun") {
    firstRunTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target:self, selector: #selector(showPopover), userInfo: nil, repeats: false)
    }
  }

  func showPopover(sender: AnyObject?) {
    if firstRunPopover.contentViewController == nil {
      firstRunPopover.contentViewController = FirstRunViewController(nibName: "FirstRunViewController", bundle: nil)
    }
    if let statusItem = statusItem, button = statusItem.button {
      firstRunPopover.showRelativeToRect(button.bounds, ofView: button, preferredEdge: NSRectEdge.MinY)
    }
  }
  func closePopover(sender: AnyObject?) {
    firstRunPopover.performClose(sender)
    defaults.setValue(false, forKey: "FirstRun")
  }

  func togglePopover(sender: AnyObject?) {
    if firstRunPopover.shown {
      closePopover(sender)
    } else {
      showPopover(sender)
    }
  }

  // MARK: Dock Icon

  func setupDockIcon() {
    if defaults.boolForKey("EnableDockIcon") {
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
        if let s = info["state"] as? CapturedState {
          self.stateDidChange(s)
        }
      }
    }
  }

  func registerShortcuts() {
    var items = [NSMenuItem]()
    for item in statusMenu.itemArray {
      if item.tag == magicShortcutMenuItemTag {
        items.append(item)
      }
    }

    for item in items {
      statusMenu.removeItem(item)
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

      statusMenu.insertItem(menuItem, atIndex: 0)
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
