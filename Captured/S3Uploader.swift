//
//  S3Uploader.swift
//  Captured
//
//  Created by Christopher Sexton on 1/4/16.
//  Copyright © 2016 Christopher Sexton. All rights reserved.
//

import Foundation

class S3Uploader: Uploader {
  private var linkURL: String?

  private var accessKey: String?
  private var secretKey: String?
  private var bucketName: String?
  private var regionName: String?
  private var fileNameLength: Int?

  required init(account: Account) {
    if let s3 = account as? S3Account {
      accessKey = s3.accessKey!
      secretKey = s3.secretKey!
      bucketName = s3.bucketName!
      regionName = s3.regionName!
      if (regionName ?? "").isEmpty {
        regionName = "us-east-1"
      }
      fileNameLength = Int(s3.fileNameLength)
    }
  }

  func test() -> String {
    let bodyDigest = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
    let url = NSURL(string: "https://\(bucketName!).s3-\(regionName!).amazonaws.com")!

    let signer = S3V4Signer(accessKey: accessKey!, secretKey: secretKey!, regionName: regionName!)
    let headers = signer.signedHeaders(url, bodyDigest: bodyDigest, httpMethod: "GET")

    let request = NSMutableURLRequest(URL: url)
    request.HTTPMethod = "GET"
    for (key, value) in headers {
      request.addValue(value, forHTTPHeaderField: key)
    }

    do {
      var response: NSURLResponse?
      try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
      print(response?.description)
      if let httpResponse = response as? NSHTTPURLResponse {
        if httpResponse.statusCode == 200 {
          return "Success!"
        } else {
          return "Failed with HTTP status code \(httpResponse.statusCode)"
        }
      }
    } catch (let e) {
      return "Failed with error \(e)"
    }
    return "Error Connecting to \(bucketName)"
  }

  func upload(path: String) -> Bool {
    let bodyDigest = FileHash.sha256HashOfFileAtPath(path)!
    let resourcePath = "/\(randomStringWithLength(fileNameLength!))"
    let url = NSURL(string: "https://\(bucketName!).s3-\(regionName!).amazonaws.com\(resourcePath)")!
    let request = NSMutableURLRequest(URL: url)
    let fileStream = NSInputStream(fileAtPath: path)!

    request.HTTPMethod = "PUT"
    request.HTTPBodyStream = fileStream

    let signer = S3V4Signer(accessKey: accessKey!, secretKey: secretKey!, regionName: regionName!)
    let headers = signer.signedHeaders(url, bodyDigest: bodyDigest)

    for (key, value) in headers {
      request.addValue(value, forHTTPHeaderField: key)
    }

    request.addValue(sizeForPath(path), forHTTPHeaderField: "Content-Length")
    request.addValue("image/png", forHTTPHeaderField: "Content-Type")

    var response: NSURLResponse?

    do {
      let data = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
      print(response?.description)
      if let httpResponse = response as? NSHTTPURLResponse {
        let text = NSString(data:data, encoding:NSUTF8StringEncoding) as? String
        NSLog("Response from AWS S3: \(httpResponse.description)\n\(text!)")

        if httpResponse.statusCode == 200 {
          linkURL = url.absoluteString
          return true
        }
      }
    } catch (let e) {
      print(e)
    }
    return false
  }

  func url() -> String? {
    return linkURL
  }

  // MARK: Utilities

  private func randomStringWithLength(len: Int) -> NSString {
    let letters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let randomString: NSMutableString = NSMutableString(capacity: len)
    for _ in 0 ..< len {
      let length = UInt32 (letters.length)
      let rand = arc4random_uniform(length)
      randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
    }
    return randomString
  }

  private func sizeForPath(filePath: String) -> String {
    var size: UInt64 = 0
    do {
      let fileAttributes = try NSFileManager.defaultManager().attributesOfItemAtPath(filePath)
      if let fileSize = fileAttributes[NSFileSize] {
        size = (fileSize as! NSNumber).unsignedLongLongValue
      } else {
        print("Failed to get a size attribute from path: \(filePath)")
      }
    } catch {
      print("Failed to get file attributes for local path: \(filePath) with error: \(error)")
    }
    return "\(size)"
  }

}
