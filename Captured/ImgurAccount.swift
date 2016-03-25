//
//  ImgurAccount.swift
//  Captured
//
//  Created by Christopher Sexton on 12/2/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Cocoa
import Just

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
    secrets["client_id"] = defaults("ImgurClientID")
  }

  func updateAttributes(jsonData: [String: AnyObject]) {
    accountID = jsonData["account_id"] as? String
    accessToken = jsonData["access_token"] as? String
    refreshToken = jsonData["refresh_token"] as? String
    accountUsername = jsonData["account_username"] as? String
    name = "\(jsonData["account_username"]!)'s Imgur"
    summary = "Upload to \(name)"
  }

  func requestNewToken() -> Bool {
    if let t = refreshToken {
      let r = Just.post(
        "https://api.imgur.com/oauth2/token",
        data: [
          "client_id": defaults("ImgurClientID"),
          "client_secret": defaults("ImgurClientSecret"),
          "grant_type": "refresh_token",
          "refresh_token": t,
        ]
      )

      if r.ok {
        if let jsonData = r.json as? [String:AnyObject] {
          updateAttributes(jsonData)
        }
        AccountManager.sharedInstance.update(self)
        return true
      }
    }
    return false
  }

  func defaults(key: String) -> String {
    return NSUserDefaults.standardUserDefaults().objectForKey(key) as! String
  }


}
