//
//  S3Account.swift
//  Captured
//
//  Created by Christopher Sexton on 12/9/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Cocoa

class S3Account: Account {

  enum SecretKeys: String {
    case AccessKey = "access_key"
    case SecretKey = "secret_key"
    case BucketName = "bucket_name"
    case PublicURL = "public_url"
    case FileNameLength = "file_name_length"
    case PrivateUpload = "private_upload"
    case ReducedRedundancyStorage = "reduced_redundancy_storage"
  }

  override func accountType() -> String {
    return "Amazon S3"
  }

  dynamic var accessKey: String? {
    get { return self.secrets[SecretKeys.AccessKey.rawValue] }
    set { self.secrets[SecretKeys.AccessKey.rawValue] = newValue }
  }

  dynamic var secretKey: String? {
    get { return self.secrets[SecretKeys.SecretKey.rawValue] }
    set { self.secrets[SecretKeys.SecretKey.rawValue] = newValue }
  }

  dynamic var bucketName: String? {
    get { return self.secrets[SecretKeys.BucketName.rawValue] }
    set { self.secrets[SecretKeys.BucketName.rawValue] = newValue }
  }

  dynamic var publicURL: String? {
    get { return self.secrets[SecretKeys.PublicURL.rawValue] }
    set { self.secrets[SecretKeys.PublicURL.rawValue] = newValue }
  }

  dynamic var fileNameLengthIndex: UInt {
    get {
      if let len = self.secrets[SecretKeys.FileNameLength.rawValue] {
        switch len {
        case "8":
          return 1
        case "34":
          return 2
        default:
          return 0
        }
      }
      return 0
    }
    set {
      switch newValue {
      case 1:
        self.secrets[SecretKeys.FileNameLength.rawValue] = "8"
      case 2:
        self.secrets[SecretKeys.FileNameLength.rawValue] = "34"
      default:
        self.secrets[SecretKeys.FileNameLength.rawValue] = "5"
      }
    }
  }

  dynamic var privateUpload: Bool {
    get {
      if self.secrets[SecretKeys.PrivateUpload.rawValue] == "YES" {
        return true
      } else {
        return false
      }
    }
    set { self.secrets[SecretKeys.PrivateUpload.rawValue] = newValue ? "YES" : "NO"}
  }

  dynamic var reducedRedundancyStorage: Bool {
    get {
      if self.secrets[SecretKeys.ReducedRedundancyStorage.rawValue] == "YES" {
        return true
      } else {
        return false
      }
    }
    set { self.secrets[SecretKeys.ReducedRedundancyStorage.rawValue] = newValue ? "YES" : "NO"}
  }
}


