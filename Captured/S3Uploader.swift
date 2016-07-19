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
  private var bucketURL: String?
  private var publicURL: String?
  private var fileNameLength: Int?

  required init(account: Account) {
    if let s3 = account as? S3Account {
      accessKey = s3.accessKey!
      secretKey = s3.secretKey!
      bucketName = s3.bucketName!
      bucketURL = "http://\(bucketName!).s3.amazonaws.com"
      if (s3.regionName ?? "").isEmpty {
        regionName = "us-east-1"
      } else {
        regionName = s3.regionName!
      }
      if (s3.publicURL ?? "").isEmpty {
        publicURL = bucketURL
      } else {
        publicURL = s3.publicURL
      }
      fileNameLength = Int(s3.fileNameLength)
    }
  }

  func test() -> String {
    let bodyDigest = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
    let url = NSURL(string: bucketURL!)!
    let semaphore = dispatch_semaphore_create(0)

    let signer = S3V4Signer(accessKey: accessKey!, secretKey: secretKey!, regionName: regionName!)
    let headers = signer.signedHeaders(url, bodyDigest: bodyDigest, httpMethod: "GET")

    let request = NSMutableURLRequest(URL: url)
    request.HTTPMethod = "GET"
    for (key, value) in headers {
      request.addValue(value, forHTTPHeaderField: key)
    }

    let session = NSURLSession.sharedSession()
    var statusMessage = "Unknown Error."
    let task = session.dataTaskWithRequest(request) {data, response, error -> Void in
      if error != nil {
        statusMessage = (error?.localizedDescription)!
      } else {
        if let httpResponse = response as? NSHTTPURLResponse {
          if httpResponse.statusCode == 200 {
            statusMessage = "Success!"
          } else {
            statusMessage = "Failed with HTTP status code \(httpResponse.statusCode)"
          }
        }
      }
      dispatch_semaphore_signal(semaphore)
    }

    task.resume()
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    return statusMessage
  }

  func upload(path: String) -> Bool {
    let bodyDigest = FileHash.sha256HashOfFileAtPath(path)!
    var fileExt = NSURL(fileURLWithPath: path).pathExtension!
    if !fileExt.isEmpty {
      fileExt = ".\(fileExt)"
    }
    let resourcePath = "\(randomStringWithLength(fileNameLength!))\(fileExt)"
    let url = NSURL(string: joinPathSegments(bucketURL!, part2: resourcePath))!
    let publicLink = NSURL(string: joinPathSegments(publicURL!, part2: resourcePath))!
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
    let mime = MimeType(path: path).mimeType
    request.addValue(mime, forHTTPHeaderField: "Content-Type")

    let session = NSURLSession.sharedSession()
    let semaphore = dispatch_semaphore_create(0)
    var status = false
    let task = session.dataTaskWithRequest(request) {data, response, error -> Void in
      if let httpResponse = response as? NSHTTPURLResponse {
        let text = NSString(data:data!, encoding:NSUTF8StringEncoding) as? String
        NSLog("Response from AWS S3: \(httpResponse.description)\n\(text!)")

        if httpResponse.statusCode == 200 {
          self.linkURL = publicLink.absoluteString
          status = true
        }
      }
      dispatch_semaphore_signal(semaphore)
    }

    task.resume()
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)

    return status
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
        NSLog("Failed to get a size attribute from path: \(filePath)")
      }
    } catch {
      NSLog("Failed to get file attributes for local path: \(filePath) with error: \(error)")
    }
    return "\(size)"
  }

  private func joinPathSegments(part1: String, part2: String) -> String {
    let token = (part1.characters.last! == "/") ? "" : "/"
    return "\(part1)\(token)\(part2)"
  }
}
