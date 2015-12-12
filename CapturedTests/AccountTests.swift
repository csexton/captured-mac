//
//  AccountTests.swift
//  Captured
//
//  Created by Christopher Sexton on 12/4/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import XCTest
@testable import Captured


class AccountTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testInitOverridesType() {
    XCTAssertEqual(Account().type, "None")
    XCTAssertEqual(ImgurAccount().type, "Imgur")
    XCTAssertEqual(AnonImgurAccount().type, "Anonymous Imgur")

  }
  

}
