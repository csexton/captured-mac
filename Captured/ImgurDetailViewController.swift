//
//  ImgurDetailViewController.swift
//  Captured
//
//  Created by Christopher Sexton on 11/22/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Cocoa
import Just

class ImgurDetailViewController: NSViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.
  }


  @IBOutlet weak var pinField: NSTextField!
  @IBOutlet weak var confirmButton: NSButton!
  @IBAction func linkAccount(sender: AnyObject) {
    let cid = defaults("ImgurClientID")
    NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://api.imgur.com/oauth2/authorize?client_id=\(cid)&response_type=pin")!)
    pinField.hidden = false
    confirmButton.hidden = false

  }
  @IBAction func confirmAccount(sender: AnyObject) {

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
        if (result.ok) { /* success! */ }
    })


  }
  @IBAction func urlOption(sender: AnyObject) {
  }
  @IBAction func cancelButton(sender: AnyObject) {
    self.dismissController(self)
  }
  @IBAction func saveButton(sender: AnyObject) {
    self.dismissController(self)
  }


  func defaults(key:String) -> String {
    return NSUserDefaults.standardUserDefaults().objectForKey(key) as! String
  }


}
