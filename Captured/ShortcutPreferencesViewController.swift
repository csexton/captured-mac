//
//  ShortcutPreferencesViewController.swift
//  Captured
//
//  Created by Christopher Sexton on 11/21/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Cocoa
import MASShortcut


class ShortcutPreferencesViewController : NSViewController, NSTableViewDataSource, NSTableViewDelegate {

  var shortcuts = ShortcutManager.sharedInstance

  @IBOutlet weak var tableView: NSTableView!

  @IBAction func editAccount(sender: AnyObject) {

    let row = tableView.rowForView(sender as! NSView)
    let shortcut = shortcuts.shortcutAtIndex(row)
    super.performSegueWithIdentifier("shortcutSheetSegue", sender: shortcut)
  }

  // Pragma Mark: View Controller Delegates
  
  override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.reloadData()

    let nc = NSNotificationCenter.defaultCenter()
    nc.addObserver(self.tableView, selector: "reloadData", name: "AccountsUpdated", object: nil)
  }

  override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
    if let controller = segue.destinationController as? NSViewController {
      if let shortcut = sender as? Shortcut {
        controller.representedObject = shortcut
      }
      else {
        controller.representedObject = Shortcut()
      }
    }
  }

  // MARK: Table Delegate Methods

  func numberOfRowsInTableView(tableView: NSTableView) -> Int {
    return shortcuts.count()
  }

  func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
    let cellview = tableView.makeViewWithIdentifier("shortcutCell", owner: self)

    if let cell = cellview as? ShortcutTableCellView {
      cell.objectValue = shortcuts.shortcutAtIndex(row)
    }

    return cellview
  }

  func selectionShouldChangeInTableView(tableView: NSTableView) -> Bool {
    return false
  }
  
}
