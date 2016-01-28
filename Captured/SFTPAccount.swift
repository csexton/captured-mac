//
//  SFTPAccount.swift
//  Captured
//
//  Created by Christopher Sexton on 1/15/16.
//  Copyright © 2016 Christopher Sexton. All rights reserved.
//

import Cocoa

class SFTPAccount: Account {

  enum SecretKeys: String {
    case Username = "username"
    case Password = "password"
    case Hostname = "hostname"
    case PathOnServer = "path_on_server"
    case PublicURL = "public_url"
    case FileNameLength = "file_name_length"
  }

  override func accountType() -> String {
    return "SFTP"
  }

  dynamic var username: String? {
    get { return self.secrets[SecretKeys.Username.rawValue] }
    set { self.secrets[SecretKeys.Username.rawValue] = newValue }
  }

  dynamic var password: String? {
    get { return self.secrets[SecretKeys.Password.rawValue] }
    set { self.secrets[SecretKeys.Password.rawValue] = newValue }
  }

  dynamic var hostname: String? {
    get { return self.secrets[SecretKeys.Hostname.rawValue] }
    set { self.secrets[SecretKeys.Hostname.rawValue] = newValue }
  }

  dynamic var pathOnServer: String? {
    get { return self.secrets[SecretKeys.PathOnServer.rawValue] }
    set { self.secrets[SecretKeys.PathOnServer.rawValue] = newValue }
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

}
