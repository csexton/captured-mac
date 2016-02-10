//
//  PHPUploader.swift
//  Captured
//
//  Created by Christopher Sexton on 2/8/16.
//  Copyright © 2016 Christopher Sexton. All rights reserved.
//

import Cocoa
import Just

class PHPUploader: Uploader {

  let options: [String:String]

  private var linkURL: String?

  required init(account: Account) {
    options = account.secrets
  }
  func test() -> String {
    let token = options["api_token"]!
    let endpoint = options["endpoint_url"]!

    let r = Just.post(endpoint, data: ["token": token, "test": "true"])
    if r.ok {
      return "Success, everything looks good."
    }
    if let status = r.statusCode {
      return "Test failed with Status Code \"\(status)\"."

    }
    if let error = r.error {
      return "Error: \(error.localizedDescription)."
    }
    return "Error Connecting to Captured PHP Server."
  }

  func upload(path: String) -> Bool {
    let fileURL = NSURL.fileURLWithPath(path as String)
    let token = options["api_token"]!
    let endpoint = options["endpoint_url"]!

    let r = Just.post(
      endpoint,
      data: [ "token": token ],
      files: ["file": .URL(fileURL, nil)]
    )
    if r.ok {
      CapturedState.broadcastStateChange(.Success)

      if let link = r.json!["image_url"] as? String {
        linkURL = link
      }
      NSLog("Response from Captured PHP: \(r.json!)")
    } else {
      CapturedState.broadcastStateChange(.Error)
      NSLog("Response from Captured PHP: \(r)")
    }

    return r.ok
  }

  func url() -> String? {
    return linkURL
  }

}
