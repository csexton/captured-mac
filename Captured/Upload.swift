//
//  Upload.swift
//  Captured
//
//  Created by Christopher Sexton on 12/19/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

class Upload {

  var path: String?
  var url: String?
  var account: Account

  init(account: Account, path: String) {
    self.account = account
    self.path = path
  }

  func run(success:(upload:Upload) -> (Void)) {
    let uploader = uploadFactory(account.type)

    if uploader.upload(path!) {
      url = uploader.url()
      success(upload: self)
    }
  }

  func uploadFactory(type: String) -> (Uploader) {
    return ImgurUploader(account: account)
  }
}
