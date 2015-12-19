//
//  AnonImgurAccount.swift
//  Captured
//
//  Created by Christopher Sexton on 12/3/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Foundation

class AnonImgurAccount : Account {

  override func accountType() -> String {
    return "Anonymous Imgur"
  }

}
