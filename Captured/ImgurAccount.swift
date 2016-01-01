//
//  ImgurAccount.swift
//  Captured
//
//  Created by Christopher Sexton on 12/2/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Cocoa

class ImgurAccount: Account {

  override func accountType() -> String {
    return "Imgur"
  }

  func isAuthenticated() -> Bool {
    if secrets["access_token"] != nil {
      return true
    } else {
      return false
    }
  }

  override func loadSecrets() {
    super.loadSecrets()

    if let cid = NSUserDefaults.standardUserDefaults().stringForKey("ImgurClientID") {
      secrets["client_id"] = cid
    }
  }
}
