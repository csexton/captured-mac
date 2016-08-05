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

  let account: PHPAccount

  private var linkURL: String?

  required init(account: PHPAccount) {
    self.account = account
  }
  func test() -> String {
    let token = account.apiToken!
    let endpoint = account.endpointURL!

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
    let token = account.apiToken!
    let endpoint = account.endpointURL!

    let r = Just.post(
      endpoint,
      data: [ "token": token ],
      files: ["file": .URL(fileURL, nil)]
    )
    NSLog("Response from Captured PHP: \(r)")
    if r.ok {
      if let link = r.json!["public_url"] as? String {
        linkURL = link
        return true
      }
    }

    return false
  }

  func url() -> String? {
    return linkURL
  }

}
