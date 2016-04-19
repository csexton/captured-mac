//
//  DropboxDetailViewController.swift
//  Captured
//
//  Created by Christopher Sexton on 4/5/16.
//  Copyright © 2016 Christopher Sexton. All rights reserved.
//

import Foundation
import Cocoa

class DropboxDetailViewController: AccountDetailViewController {
  enum Tabs: Int {
    case Login = 0
    case Spinner = 1
    case Edit = 2
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    if DBSession.sharedSession().isLinked() {
      showTab(.Edit)
    } else {
      showTab(.Login)
    }
  }

  @IBOutlet weak var spinner: NSProgressIndicator!
  @IBOutlet weak var tabView: NSTabView!
  @IBOutlet weak var errorLabel: NSTextField!
  @IBAction func linkAccount(sender: AnyObject) {
    showTab(.Spinner)
  }

  @IBAction func unlinkAccount(sender: AnyObject) {
    DBSession.sharedSession().unlinkAll()
    showTab(.Login)
  }


  func showTab(index: Tabs) {
    if index == .Spinner {
      startLink()
    } else {
      stopLink()
    }
    self.tabView.selectTabViewItemAtIndex(index.rawValue)
  }

  override func performDelete() {
    DBSession.sharedSession().unlinkAll()
    super.performDelete()
  }

  func startLink(){
    NSNotificationCenter.defaultCenter().addObserver(
      self,
      selector: #selector(dropboxAuthStateChanged),
      name: DBAuthHelperOSXStateChangedNotification,
      object: nil)

    spinner.startAnimation(self)
    spinner.hidden = false

    DBSession.sharedSession().unlinkAll()
    DBAuthHelperOSX.sharedHelper().authenticate()
  }

  func stopLink() {
    NSNotificationCenter.defaultCenter().removeObserver(self)
    spinner.hidden = true
    spinner.stopAnimation(self)
  }

  func dropboxAuthStateChanged(notification: NSNotification) {
    if DBSession.sharedSession().isLinked() {
      showTab(.Edit)
    }
  }

}
