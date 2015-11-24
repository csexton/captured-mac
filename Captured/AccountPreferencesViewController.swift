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
    self.performSegueWithIdentifier("imgurSheetSegue", sender: self)
    print("yay")
  }

  var objects : NSMutableArray! = NSMutableArray()

  override func viewDidLoad() {
    super.viewDidLoad()

    self.objects.addObject([ "name": "Default Imgur", "type": "imgur" ])

    self.tableView.reloadData()

    // Do any additional setup after loading the view.
  }

  override var representedObject: AnyObject? {
    didSet {
      // Update the view, if already loaded.
    }
  }

  // MARK: Delegate Methods

  func numberOfRowsInTableView(tableView: NSTableView) -> Int {
    return self.objects.count
  }

  func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
    let cellview = tableView.makeViewWithIdentifier("accountCell", owner: self)

    if let cell = cellview as? AccountTableCellView {
      cell.objectValue = self.objects.objectAtIndex(row) as! NSDictionary
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
      self.performSegueWithIdentifier("s3SheetSegue", sender: self)
    case 2:
      self.performSegueWithIdentifier("dropboxSheetSegue", sender: self)
    case 3:
      self.performSegueWithIdentifier("sftpSheetSegue", sender: self)
    case 4:
      self.performSegueWithIdentifier("imgurSheetSegue", sender: self)
    default:
      print("Unknown Account type. Did you set the tag value on the menu item?")
    }


  }
}
