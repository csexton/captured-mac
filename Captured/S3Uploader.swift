//
//  S3Uploader.swift
//  Captured
//
//  Created by Christopher Sexton on 1/4/16.
//  Copyright © 2016 Christopher Sexton. All rights reserved.
//

import Foundation

class S3Uploader: Uploader {
  var settings: [String:String]
  private var linkURL: String?

  required init(account: Account) {
    settings = account.secrets

  }
  func upload(path: String) -> Bool {
    let s3Client = S3Client(settings: settings)

    print(s3Client.testConnection())

    if s3Client.uploadFile(path) {
      linkURL = s3Client.uploadUrl
      CapturedState.broadcastStateChange(.Success)
      return true
    } else {
      CapturedState.broadcastStateChange(.Error)
      return false
    }
  }
  func url() -> String? {
    return linkURL
  }
}
