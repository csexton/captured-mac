//
//  ImgurUploader.swift
//  Captured
//
//  Created by Christopher Sexton on 11/24/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Cocoa
import Just

class ImgSafeUploader {

  let options: [String:String]

  init(withOptions opts: [String:String]) {
    options = opts
  }


//  let anonOpts = ["hi":"mom"]
//  let i = "/Users/csexton/src/captured-mac/Captured/Assets.xcassets/AppIcon.appiconset/icon_128x128@2x.png"
//  let u = ImgSafeUploader(withOptions: anonOpts)
//  let b = u.upload(i as String)

  func upload(filePath: String) -> Bool {

    let fileURL = NSURL.fileURLWithPath(filePath as String)

    let r = Just.post(
      "http://imgsafe.org/upload",
      files: ["image": .URL(fileURL, nil)]
    )

    if r.ok {
      /* success! */
    }

    return r.ok

  }

}
