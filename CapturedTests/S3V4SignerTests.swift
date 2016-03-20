//
//  S3V4SignerTests.swift
//  Captured
//
//  Created by Christopher Sexton on 3/17/16.
//  Copyright © 2016 Christopher Sexton. All rights reserved.
//

import XCTest
@testable import Captured

class S3V4SignerTests: XCTestCase {
  
  let accessKey = "AKIAJODU6PESZF6ENZ2A"
  let secretKey = "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"
  let regionName = "eu-central-1"
  let bodyDigest = "96fe862bffd24748621f5e6b1938c3f7a8a18569c82b68dccad1e22b20533440"
  
  func testAuthorizationHeader() {
    let now = parseDate("20160318T003250Z")
    let url = NSURL(string: "https://capturedeu.s3-eu-central-1.amazonaws.com/xrQ77e9S")!
    let signer = S3V4Signer(accessKey: accessKey, secretKey: secretKey, regionName: regionName)
    let headers = signer.signedHeaders(url, bodyDigest: bodyDigest, httpMethod: "PUT", date: now)
    
    let expected = "AWS4-HMAC-SHA256 Credential=AKIAJODU6PESZF6ENZ2A/20160318/eu-central-1/s3/aws4_request, SignedHeaders=host;x-amz-acl;x-amz-content-sha256;x-amz-date, Signature=1d83730c0ad27d6b50864f770a6cac8467053d14fb7381cf6f123b2d21f1ae03"
    
    XCTAssert(expected == headers["Authorization"])
    
  }

  func parseDate(date: String) -> NSDate {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
    formatter.timeZone = NSTimeZone(name: "UTC")
    formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    return formatter.dateFromString(date)!
  }
}
