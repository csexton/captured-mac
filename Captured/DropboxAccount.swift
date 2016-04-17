//
//  DropboxAccount.swift
//  Captured
//
//  Created by Christopher Sexton on 4/5/16.
//  Copyright © 2016 Christopher Sexton. All rights reserved.
//

//
//  S3Account.swift
//  Captured
//
//  Created by Christopher Sexton on 12/9/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Cocoa

class DropboxAccount: Account {

  let dropboxSession = DropboxSessionManager.sharedSession

  override func accountType() -> String {
    return "Dropbox"
  }

  override init() {
    super.init()
    name = "Dropbox"
    summary = "Linked Dropbox Account"
  }

  func isAuthenticated() -> Bool {
    return dropboxSession.isLinked()
  }

}
