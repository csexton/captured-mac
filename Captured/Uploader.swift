//
//  Uploader.swift
//  Captured
//
//  Created by Christopher Sexton on 11/24/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Cocoa

protocol Uploader {
  init(account: Account)
  func upload(path: String) -> Bool
  func url() -> String?
}
