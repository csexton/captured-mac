//
//  ImgurAccount.swift
//  Captured
//
//  Created by Christopher Sexton on 12/2/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Cocoa

class ImgurAccount: Account {

  enum SecretKeys: String {
    case AccountID = "account_id"
    case AccessToken = "access_token"
    case refreshToken = "refresh_token"
    case AccountUsername = "account_username"
  }

  override func accountType() -> String {
    return "Imgur"
  }

  dynamic var accountID: String? {
    get { return self.secrets[SecretKeys.AccountID.rawValue] }
    set { self.secrets[SecretKeys.AccountID.rawValue] = newValue }
  }
  dynamic var accessToken: String? {
    get { return self.secrets[SecretKeys.AccessToken.rawValue] }
    set { self.secrets[SecretKeys.AccessToken.rawValue] = newValue }
  }

  dynamic var refreshToken: String? {
    get { return self.secrets[SecretKeys.refreshToken.rawValue] }
    set { self.secrets[SecretKeys.refreshToken.rawValue] = newValue }
  }

  dynamic var accountUsername: String? {
    get { return self.secrets[SecretKeys.AccountUsername.rawValue] }
    set { self.secrets[SecretKeys.AccountUsername.rawValue] = newValue }
  }

  func isAuthenticated() -> Bool {
    if secrets[SecretKeys.AccessToken.rawValue] != nil {
      return true
    } else {
      return false
    }
  }

  override func loadSecrets() {
    super.loadSecrets()

    if let cid = NSUserDefaults.standardUserDefaults().stringForKey("ImgurClientID") {
      secrets["client_id"] = cid
    }
  }
}
