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
  let firstRunPopover = NSPopover()
  var firstRunTimer = NSTimer()
  var eventMonitor: EventMonitor?

  //let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSSquareStatusItemLength)
  let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)


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

    setDefaultDefaults()
    accountManager.load()
    shortcutManager.load()

    createStatusMenu()

    registerShortcuts()
    setupNotificationListeners()
    setupDockIcon()
    registerCustomURL()

    NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self

    showPopoverOnFirstRun()

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
        let defaults = NSUserDefaults.standardUserDefaults()
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

        let defaults = NSUserDefaults.standardUserDefaults()
        if let identifier = defaults.objectForKey("DragAccountIdentifier") as? String {

          let account = AccountManager.sharedInstance.accountWithIdentifier(identifier)!

          dispatch_async(queue) {
            Command().run(account, path:path)
          }
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
    #if DEBUG
    menu.addItem(NSMenuItem.separatorItem())
    menu.addItem(NSMenuItem(title: "First Run...",
      action: #selector(togglePopover), keyEquivalent: ""))
    #endif
    menu.addItem(NSMenuItem.separatorItem())
    menu.addItem(NSMenuItem(title: "Quit Captured",
      action: #selector(terminate), keyEquivalent: ""))

    statusItem.menu = menu

    if let button = statusItem.button, window = button.window {
      window.registerForDraggedTypes([NSFilenamesPboardType])
      window.delegate = self
    }

  }

  func statusMenuClicked(sender: AnyObject?) {
    closePopover(sender)
    let menu = statusItem.menu!
    statusItem.popUpStatusItemMenu(menu)
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

  // MARK: First Run

  func showPopoverOnFirstRun() {
    if NSUserDefaults.standardUserDefaults().boolForKey("FirstRun") {
    firstRunTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target:self, selector: #selector(showPopover), userInfo: nil, repeats: false)
    }
  }

  func showPopover(sender: AnyObject?) {
    if firstRunPopover.contentViewController == nil {
      firstRunPopover.contentViewController = FirstRunViewController(nibName: "FirstRunViewController", bundle: nil)
    }
    if let button = statusItem.button {
      firstRunPopover.showRelativeToRect(button.bounds, ofView: button, preferredEdge: NSRectEdge.MinY)
    }

//    eventMonitor = EventMonitor(mask: [.LeftMouseDownMask, .RightMouseDownMask]) { [unowned self] event in
//      if self.firstRunPopover.shown {
//        self.closePopover(event)
//      }
//    }
//    eventMonitor?.start()
  }
  func closePopover(sender: AnyObject?) {
    firstRunPopover.performClose(sender)
    NSUserDefaults.standardUserDefaults().setValue(false, forKey: "FirstRun")
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

  // MARK: Custom URL Scheme

  func registerCustomURL() {
    let appleEventManager: NSAppleEventManager = NSAppleEventManager.sharedAppleEventManager()
    appleEventManager.setEventHandler(self, andSelector: #selector(AppDelegate.handleURLEvent(_:withReply:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))

  }

  func handleURLEvent(event: NSAppleEventDescriptor, withReply reply: NSAppleEventDescriptor) {
    if let urlString = event.paramDescriptorForKeyword(AEKeyword(keyDirectObject))?.stringValue {
      if let url = NSURL(string: urlString) where "captured" == url.scheme && "oauth" == url.host {
        print(url)
//        NSNotificationCenter.defaultCenter().postNotificationName(OAuth2AppDidReceiveCallbackNotification, object: url)
      }
      showPreferences(self)
    } else {
      NSLog("No valid URL to handle")
    }
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
