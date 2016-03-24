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

  let account: Account
  var retries = 0

  private var linkURL: String?

  required init(account: Account) {
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
    if r.ok {
      CapturedState.broadcastStateChange(.Success)

      if let data = r.json!["data"] as? [String:AnyObject], let link = data["link"] as? String {
        linkURL = link
      }

      NSLog("Response from Imgur: \(r.json!)")
    } else if r.statusCode == 403 && retries < 1 {
      NSLog("Response from Imgur: \(r)")
      retries = retries + 1
      if requestNewToken() {
        upload(path)
      }
    } else {
      CapturedState.broadcastStateChange(.Error)
      NSLog("Response from Imgur: \(r)")
    }

    return r.ok
  }

  func requestNewToken() -> Bool {
    if let a = account as? ImgurAccount {
      return a.requestNewToken()
    }
    return false
  }

  func url() -> String? {
    return linkURL
  }

  func authHeader() -> String {
    var ret = ""
    if let a = account as? ImgurAccount {
      if let accessToken = a.accessToken {
        ret = "Client-Bearer \(accessToken)"
      } else {
        if let clientID = account.secrets["client_id"] {
          ret = "Client-ID \(clientID)"
        }
      }
    }
    return ret
  }


}
