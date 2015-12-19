//
//  ImgurUploader.swift
//  Captured
//
//  Created by Christopher Sexton on 11/24/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Cocoa
import Just

class ImgurUploader {

  let options : [String:String]

  init(withOptions opts:[String:String]) {
    options = opts
  }

  func upload(filePath: String) -> Bool {

    let fileURL = NSURL.fileURLWithPath(filePath as String)

    let r = Just.post(
      "https://api.imgur.com/3/image",
      headers: [ "Authorization": authHeader() ],
      data: [
        "title": "Screen Capture",
        "description": "Uploaded by Captured for Mac",
      ],
      files: ["image": .URL(fileURL, nil)]
    )

    if (r.ok) { /* success! */ }

    return r.ok

  }

  func authHeader() -> String {
    if (options["access_token"] != nil) {
      return "Client-Bearer \(options["access_token"]!)"
    }
    else {
      return "Client-ID \(options["client_id"]!)"
    }
  }


}
