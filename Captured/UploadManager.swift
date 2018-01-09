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

  func run(success:(_ upload: UploadManager) -> (Void), error:(_ upload: UploadManager) -> Void) {
    if let uploader = uploadFactory(account), uploader.upload(path!) {
      url = uploader.url()
      success(upload: self)
    } else {
      error(upload: self)
    }
  }

  func uploadFactory(type: Account) -> Uploader? {
    switch type {
    case let amazon as S3Account:
      return S3Uploader(account: amazon)
    case let sftp as SFTPAccount:
      return SFTPUploader(account: sftp)
    case let imgur as ImgurAccount:
      return ImgurUploader(account: imgur)
    case let php as PHPAccount:
      return PHPUploader(account: php)
    default:
      return nil
    }
  }
}
