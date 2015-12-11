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
    return "S3"
  }

  dynamic var accessKey : String? {
    get { return self.options["access_key"] }
    set { self.options["access_key"] = newValue }
  }

  dynamic var secretKey : String? {
    get { return self.options["secret_key"] }
    set { self.options["secret_key"] = newValue }
  }

  dynamic var bucketName: String? {
    get { return self.options["bucket_name"] }
    set { self.options["bucket_name"] = newValue }
  }

  dynamic var publicURL: String? {
    get { return self.options["public_url"] }
    set { self.options["public_url"] = newValue }
  }

  dynamic var fileNameLengthIndex: UInt {
    get {

      if let len = self.options["file_name_length"] {
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
      switch (newValue) {
      case 1:
        self.options["file_name_length"] = "8"
      case 2:
        self.options["file_name_length"] = "34"
      default:
        self.options["file_name_length"] = "5"
      }
      
    }
  }

  dynamic var reducedRedundancyStorage: Bool {
    get {
      if (self.options["reduced_redundancy_storage"] == "YES") {
        return true
      }
      else {
        return false
      }

    }
    set { self.options["reduced_redundancy_storage"] = newValue ? "YES" : "NO"}
  }

}