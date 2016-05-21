//
//  Upload.swift
//  Captured
//
//  Created by Christopher Sexton on 12/19/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

class UploadManager {

  var path: String?
  var url: String?
  var account: Account

  init(account: Account, path: String) {
    self.account = account
    self.path = path
  }

  func run(success:(upload: UploadManager) -> (Void), error:(upload: UploadManager) -> (Void)) {
    let uploader = uploadFactory(account.type)

    if uploader.upload(path!) {
      url = uploader.url()
      success(upload: self)
    } else {
      error(upload: self)
    }
  }

  func uploadFactory(type: String) -> (Uploader) {
    switch type {
    case "Amazon S3":
      return S3Uploader(account: account)
    case "SFTP":
      return SFTPUploader(account: account)
    case "Imgur":
      return ImgurUploader(account: account)
    case "Captured PHP":
      return PHPUploader(account: account)
    default:
      // TODO: Better Default
      return ImgurUploader(account: account)
    }
  }
}
