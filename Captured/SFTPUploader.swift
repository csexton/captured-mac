//
//  SFTPUploader.swift
//  Captured
//
//  Created by Christopher Sexton on 1/15/16.
//  Copyright © 2016 Christopher Sexton. All rights reserved.
//

class SFTPUploader: Uploader {
  var settings: [String:String]
  private var linkURL: String?

  required init(account: Account) {
    settings = account.secrets

  }
  func upload(path: String) -> Bool {
    let client = SFTPClient(settings: settings)

    if client.uploadFile(path) {
      linkURL = client.uploadUrl
      return true
    }
    return false
  }
  func url() -> String? {
    return linkURL
  }
}
