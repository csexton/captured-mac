//
//  ImgurUploader.swift
//  Captured
//
//  Created by Christopher Sexton on 11/24/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Cocoa
import Just

class ImgurUploader : Uploader {

  let options : [String:String]

  private var linkURL : String?

  required init(account:Account) {
    options = account.options
  }

  func upload(path:String) -> Bool {

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
    if (r.ok) {

      if let data = r.json!["data"] as? [String:AnyObject], let link = data["link"] as? String {
        linkURL = link
      }
      NSLog("Response from Imgur: \(r.json!)")
    }
    else {
      NSLog("Response from Imgur: \(r)")
    }

    return r.ok
  }

  func url() -> String? {
    return linkURL
  }

  func authHeader() -> String {
    if (self.options["access_token"] != nil) {
      return "Client-Bearer \(options["access_token"]!)"
    }
    else {
      return "Client-ID \(options["client_id"]!)"
    }
  }


}
