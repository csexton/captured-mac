//
//  AccountPreferencesViewController.swift
//  Captured
//
//  Created by Christopher Sexton on 11/20/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Cocoa

class AccountPreferencesViewController: NSViewController,
  NSTableViewDataSource, NSTableViewDelegate {

  enum Segues: String {
    case Imgur = "imgurSheetSegue"
    case S3 = "s3SheetSegue"
    case SFTP = "sftpSheetSegue"
    case Dropbox = "dropboxSheetSegue"
    case PHP = "phpSheetSegue"
  }

  var accounts = AccountManager.sharedInstance

  // Pragma Mark: Outlets and Actions

  @IBOutlet weak var tableView: NSTableView!
  @IBOutlet var newAccountMenu: NSMenu!

  @IBAction func editAccount(sender: AnyObject) {

    let row = tableView.rowForView(sender as! NSView)
    let account = accounts.accountAtIndex(row)

    switch account.type {
    case "Imgur":
      self.performSegue(.Imgur, sender: account)
    case "Amazon S3":
      self.performSegue(.S3, sender: account)
    case "SFTP":
      self.performSegue(.SFTP, sender: account)
    case "Captured PHP":
      self.performSegue(.PHP, sender: account)
    default:
      print("Unknown Account type. Make sure the type field is set for this account.")
    }
  }
  @IBAction func newAccountButton(sender: AnyObject) {
    newAccountMenu.popUpMenuPositioningItem(newAccountMenu.itemAtIndex(0), atLocation: NSEvent.mouseLocation(), inView: nil)
  }

  @IBAction func createNewAccountFromMenu(sender: NSMenuItem) {
    // Choose which segue to show based on the tag for the menu item
    switch sender.tag {
    case 1:
      self.performSegue(.S3, sender: S3Account())
    case 2:
      self.performSegue(.Dropbox, sender: nil)
    case 3:
      self.performSegue(.SFTP, sender: SFTPAccount())
    case 4:
      self.performSegue(.Imgur, sender: ImgurAccount())
    case 5:
      self.performSegue(.PHP, sender: PHPAccount())
    default:
      print("Unknown Account type. Did you set the tag value on the menu item?")
    }
  }



  override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.reloadData()

    // Do any additional setup after loading the view.
    let nc = NSNotificationCenter.defaultCenter()
    let name = CapturedNotifications.AccountsDidUpdate.rawValue
    nc.addObserver(self.tableView, selector: "reloadData", name: name, object: nil)

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

  func performSegue(identifier: Segues, sender: AnyObject?) {
    super.performSegueWithIdentifier(identifier.rawValue, sender: sender)
  }

  override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
    if let controller = segue.destinationController as? NSViewController {
      if let account = sender as? Account {
        controller.representedObject = account
      }
    }
  }

}
