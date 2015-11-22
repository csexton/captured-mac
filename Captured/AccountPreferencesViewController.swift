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
    self.performSegueWithIdentifier("accountSheetSegue", sender: self)
    print("yay")
  }

  var objects : NSMutableArray! = NSMutableArray()
  override func viewDidLoad() {
    super.viewDidLoad()

    self.objects.addObject("imgur")
    self.objects.addObject("s3")
    self.objects.addObject("imgur")
    self.objects.addObject("sftp")

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
      cell.nameField!.stringValue = self.objects.objectAtIndex(row) as! String
      cell.typeField!.stringValue = self.objects.objectAtIndex(row) as! String
    }

    return cellview
  }

  func selectionShouldChangeInTableView(tableView: NSTableView) -> Bool {
    return false
  }

}
