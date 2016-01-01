//
//  ImgurDetailViewController.swift
//  Captured
//
//  Created by Christopher Sexton on 11/22/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Cocoa
import Just

class ImgurDetailViewController: AccountDetailViewController {
  enum Tabs: Int {
    case Login = 0
    case Link = 1
    case Spinner = 2
    case Edit = 3
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let a = self.representedObject as! ImgurAccount
    if a.isAuthenticated() {
      showTab(.Edit)
    } else {
      showTab(.Login)
    }
  }

  @IBOutlet weak var spinner: NSProgressIndicator!
  @IBOutlet weak var tabView: NSTabView!
  @IBOutlet weak var pinField: NSTextField!
  @IBOutlet weak var confirmButton: NSButton!
  @IBOutlet weak var errorLabel: NSTextField!
  @IBAction func linkAccount(sender: AnyObject) {
    let cid = defaults("ImgurClientID")
    NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://api.imgur.com/oauth2/authorize?client_id=\(cid)&response_type=pin")!)

    showTab(.Link)
  }

  @IBAction func confirmAccount(sender: AnyObject) {

    showTab(.Spinner)

    // curl -X POST -F "client_id=252eab4a4dee27d" -F "client_secret=c99183d23bc09116999bdfb30974d53805f34feb" -F "grant_type=pin" -F "pin=e0a4eb5feb" https://api.imgur.com/oauth2/token
    Just.post(
      "https://api.imgur.com/oauth2/token",
      data: [
        "client_id": defaults("ImgurClientID"),
        "client_secret": defaults("ImgurClientSecret"),
        "grant_type": "pin",
        "pin": pinField.stringValue,
      ],
      asyncCompletionHandler: { (result: HTTPResult!) -> Void in
        if result.ok {
          if let r = self.representedObject as? ImgurAccount {
            if let jsonData = result.json as? [String:AnyObject] {
              r.secrets["account_id"] = jsonData["account_id"] as? String
              r.secrets["access_token"] = jsonData["access_token"] as? String
              r.secrets["refresh_token"] = jsonData["refresh_token"] as? String
              r.secrets["account_username"] = jsonData["account_username"] as? String
              r.name = "\(jsonData["account_username"]!)'s Imgur"
              dispatch_async(dispatch_get_main_queue()) {
                self.showTab(.Edit)
              }
            }
          }
        } else {
          dispatch_async(dispatch_get_main_queue()) {
            self.showTab(.Login)
            self.errorLabel.stringValue = "Error linking Imgur account\n\(result)"
          }
          NSLog("Error requesting oauth token from Imgur: \(result)")
        }
    })
  }

  @IBAction func urlOption(sender: AnyObject) {
  }

  func showTab(index: Tabs) {
    if index == .Spinner {
      spinner.startAnimation(self)
      spinner.hidden = false
    } else {
      spinner.hidden = true
      spinner.stopAnimation(self)
    }
    self.tabView.selectTabViewItemAtIndex(index.rawValue)
  }

}
