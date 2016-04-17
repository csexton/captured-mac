//
//  DropboxSessionManager.swift
//  Captured
//
//  Created by Christopher Sexton on 4/5/16.
//  Copyright © 2016 Christopher Sexton. All rights reserved.
//

import Foundation

class DropboxSessionManager: NSObject {

  static let sharedSession = DBSession(appKey: "sdwn0x826rg36vi", appSecret: "m76zwlhnz169yib", root: kDBRootAppFolder)

  override init() {
    DBSession.setSharedSession(DropboxSessionManager.sharedSession)
  }

  dynamic var isLinked: Bool {
    get { return DBSession.sharedSession().isLinked() }
  }

  class func setGlobalSession() {
    // This is just a way to set the shared session the the DBSession. Because
    // the Dropbox SDK <3 globals
    _ = DropboxSessionManager.init()
  }
}
