//
//  S3Uploader.swift
//  Captured
//
//  Created by Christopher Sexton on 1/4/16.
//  Copyright © 2016 Christopher Sexton. All rights reserved.
//

import Foundation

// This class is just a thin wrapper around the legacy CloudUploader
class S3Uploader: Uploader {
  var settings: [String:String]
  private var linkURL: String?

  required init(account: Account) {
    settings = account.secrets

  }
  func upload(path: String) -> Bool {
    let cloudUploader = CloudUploader(settings: settings)

    print(cloudUploader.testConnection())

    if cloudUploader.uploadFile(path) {
      linkURL = cloudUploader.uploadUrl
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
