//
//  AccountPreferencesViewController.swift
//  Captured
//
//  Created by Christopher Sexton on 11/20/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Cocoa

class AccountPreferencesViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

  @IBOutlet weak var tableView: NSTableView!
  @IBAction func editAccount(sender: AnyObject) {

    let row = tableView.rowForView(sender as! NSView)
    self.performSegueWithIdentifier("imgurSheetSegue", sender: accounts.accountAtIndex(row))
    print("yay")
  }

  var accounts = AccountManager.sharedInstance

  override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.reloadData()

    // Do any additional setup after loading the view.
    let nc = NSNotificationCenter.defaultCenter()
    nc.addObserver(self.tableView, selector: "reloadData", name: "AccountsUpdated", object: nil)

  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self.tableView)
  }

  override var representedObject: AnyObject? {
    didSet {
      // Update the view, if already loaded.
    }
  }

  // MARK: Delegate Methods

  func numberOfRowsInTableView(tableView: NSTableView) -> Int {
    return accounts.count()
  }

  func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
    let cellview = tableView.makeViewWithIdentifier("accountCell", owner: self)

    if let cell = cellview as? AccountTableCellView {
      cell.objectValue = accounts.accountAtIndex(row)
    }

    return cellview
  }

  func selectionShouldChangeInTableView(tableView: NSTableView) -> Bool {
    return false
  }

  @IBOutlet var newAccountMenu: NSMenu!
  @IBAction func newAccountButton(sender: AnyObject) {
    newAccountMenu.popUpMenuPositioningItem(newAccountMenu.itemAtIndex(0), atLocation: NSEvent.mouseLocation(), inView: nil)
  }

  @IBAction func createNewAccountFromMenu(sender: NSMenuItem) {
    print(sender)
    // Choose which segue to show based on the tag for the menu item
    switch sender.tag {
    case 1:
      self.performSegueWithIdentifier("s3SheetSegue", sender: nil)
    case 2:
      self.performSegueWithIdentifier("dropboxSheetSegue", sender: nil)
    case 3:
      self.performSegueWithIdentifier("sftpSheetSegue", sender: nil)
    case 4:
      self.performSegueWithIdentifier("imgurSheetSegue", sender: nil)
    default:
      print("Unknown Account type. Did you set the tag value on the menu item?")
    }
  }

  override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
    if let controller = segue.destinationController as? NSViewController {
      if let account = sender as? Account {
        controller.representedObject = account
      }
    }
  }

}
