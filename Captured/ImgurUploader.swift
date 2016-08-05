//
//  ImgurUploader.swift
//  Captured
//
//  Created by Christopher Sexton on 11/24/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Cocoa
import Just

class ImgurUploader: Uploader {

  let account: ImgurAccount
  var retries = 0

  private var linkURL: String?

  required init(account: ImgurAccount) {
    self.account = account
  }

  func upload(path: String) -> Bool {

    let fileURL = NSURL.fileURLWithPath(path as String)

    let r = Just.post(
      "https://api.imgur.com/3/image",
      headers: [ "Authorization": authHeader() ],
      data: [
        "title": "Screen Capture",
        "description": "Uploaded by Captured for Mac",
      ],
      files: ["image": .URL(fileURL, nil)]
    )
    NSLog("Response from Imgur: \(r.json!)")
    if r.ok {
      if let data = r.json!["data"] as? [String:AnyObject], link = data["link"] as? String {
        linkURL = link
      }
      return true
    } else if r.statusCode == 403 && retries < 1 {
      retries = retries + 1
      if requestNewToken() {
        return upload(path)
      }

    }
    return false
  }

  func requestNewToken() -> Bool {
    return account.requestNewToken()
  }

  func url() -> String? {
    return linkURL
  }

  func authHeader() -> String {
    if let accessToken = account.accessToken {
      return "Client-Bearer \(accessToken)"
    } else if let clientID = account.secrets["client_id"] {
      return "Client-ID \(clientID)"
    }
    return ""
  }


}
