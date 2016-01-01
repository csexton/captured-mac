//
//  S3Account.swift
//  Captured
//
//  Created by Christopher Sexton on 12/9/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Cocoa

class S3Account: Account {
  override func accountType() -> String {
    return "Amazon S3"
  }

  dynamic var accessKey: String? {
    get { return self.secrets["access_key"] }
    set { self.secrets["access_key"] = newValue }
  }

  dynamic var secretKey: String? {
    get { return self.secrets["secret_key"] }
    set { self.secrets["secret_key"] = newValue }
  }

  dynamic var bucketName: String? {
    get { return self.secrets["bucket_name"] }
    set { self.secrets["bucket_name"] = newValue }
  }

  dynamic var publicURL: String? {
    get { return self.secrets["public_url"] }
    set { self.secrets["public_url"] = newValue }
  }

  dynamic var fileNameLengthIndex: UInt {
    get {
      if let len = self.secrets["file_name_length"] {
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
        self.secrets["file_name_length"] = "8"
      case 2:
        self.secrets["file_name_length"] = "34"
      default:
        self.secrets["file_name_length"] = "5"
      }
    }
  }

  dynamic var reducedRedundancyStorage: Bool {
    get {
      if self.secrets["reduced_redundancy_storage"] == "YES" {
        return true
      } else {
        return false
      }
    }
    set { self.secrets["reduced_redundancy_storage"] = newValue ? "YES" : "NO"}
  }
}
