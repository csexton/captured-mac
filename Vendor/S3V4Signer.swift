//
//  S3V4Uploader.swift
//  Captured
//
//  Created by Christopher Sexton on 2/22/16.
//  Copyright © 2016 Christopher Sexton. All rights reserved.
//

import Foundation

class S3V4Signer {
  let accessKey: String
  let secretKey: String
  let regionName: String
  let serviceName: String
  
  required init(accessKey: String, secretKey: String, regionName: String, serviceName: String = "s3") {
    self.accessKey = accessKey
    self.secretKey = secretKey
    self.regionName = regionName
    self.serviceName = serviceName
  }
  
  func signedHeaders(url: NSURL, bodyDigest: String, httpMethod: String = "PUT", date: NSDate = NSDate()) -> [String: String] {
    let datetime = timestamp(date)

    var headers = [
      "x-amz-content-sha256": bodyDigest,
      "x-amz-date": datetime,
      "x-amz-acl" : "public-read",
      "Host": url.host!,
    ]
    headers["Authorization"] = authorization(url, headers: headers, datetime: datetime, httpMethod: httpMethod, bodyDigest: bodyDigest)

    return headers
  }
  
  // MARK: Utilities

  private func pathForURL(url: NSURL) -> String {
    if let path = url.path, !path.isEmpty {
      return path
    } else {
      return "/"
    }
  }
  
  func sha256(str: String) -> String {
    let data = str.dataUsingEncoding(NSUTF8StringEncoding)!
    var hash = [UInt8](count: Int(CC_SHA256_DIGEST_LENGTH), repeatedValue: 0)
    CC_SHA256(data.bytes, CC_LONG(data.length), &hash)
    let res = NSData(bytes: hash, length: Int(CC_SHA256_DIGEST_LENGTH))
    return hexdigest(res)
  }

  private func hmac(string: NSString, key: NSData) -> NSData {
    let keyBytes = UnsafePointer<CUnsignedChar>(key.bytes)
    let data = string.cStringUsingEncoding(NSUTF8StringEncoding)
    let dataLen = Int(string.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
    let digestLen = Int(CC_SHA256_DIGEST_LENGTH)
    let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
    CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), keyBytes, key.length, data, dataLen, result);
    return NSData(bytes: result, length: digestLen)
  }

  private func hexdigest(data: NSData) -> String {
    var hex = String()
    let bytes =  UnsafePointer<CUnsignedChar>(data.bytes)

    for i in 0 ..< data.length {
      hex += String(format: "%02x", bytes[i])
    }
    return hex
  }

  private func timestamp(date: NSDate) -> String {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
    formatter.timeZone = NSTimeZone(name: "UTC")
    formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    return formatter.stringFromDate(date)
  }
  
  // MARK: Methods Ported from AWS SDK

  // http://docs.aws.amazon.com/general/latest/gr/signature-version-4.html
  //
  // Carefully, nay, painstakingly ported from ruby:
  // https://github.com/aws/aws-sdk-ios/blob/440d3141/AWSCore/Authentication/AWSSignature.m
  
  private func authorization(url: NSURL, headers: Dictionary<String, String>, datetime: String, httpMethod: String, bodyDigest: String) -> String {
    let cred = credential(datetime)
    let shead = signedHeaders(headers)
    let sig = signature(url, headers: headers, datetime: datetime, httpMethod: httpMethod, bodyDigest: bodyDigest)
    
    return [
      "AWS4-HMAC-SHA256 Credential=\(cred)",
      "SignedHeaders=\(shead)",
      "Signature=\(sig)",
      ].joinWithSeparator(", ")
  }
  
  private func credential(datetime: String) -> String {
    return "\(accessKey)/\(credentialScope(datetime))"
  }
  
  private func signedHeaders(headers: [String:String]) -> String {
    var list = Array(headers.keys).map { $0.lowercaseString }.sort()
    if let itemIndex = list.indexOf("authorization") {
      list.removeAtIndex(itemIndex)
    }
    return list.joinWithSeparator(";")
  }
  
  private func canonicalHeaders(headers: [String: String]) -> String {
    var list = [String]()
    let keys = Array(headers.keys).sort {$0.localizedCompare($1) == NSComparisonResult.OrderedAscending}
    
    for key in keys {
      if key.caseInsensitiveCompare("authorization") != NSComparisonResult.OrderedSame {
        // Note: This does not strip whitespace, but the spec says it should
        list.append("\(key.lowercaseString):\(headers[key]!)")
      }
    }
    return list.joinWithSeparator("\n")
  }

  private func signature(url: NSURL, headers: [String: String], datetime: String, httpMethod: String, bodyDigest: String) -> String {
    let secret = NSString(format: "AWS4%@", secretKey).dataUsingEncoding(NSUTF8StringEncoding)!
    let date = hmac(datetime.substringToIndex(datetime.startIndex.advancedBy(8)), key: secret)
    let region = hmac(regionName, key: date)
    let service = hmac(serviceName, key: region)
    let credentials = hmac("aws4_request", key: service)
    let string = stringToSign(datetime, url: url, headers: headers, httpMethod: httpMethod, bodyDigest: bodyDigest)
    let sig = hmac(string, key: credentials)
    return hexdigest(sig)
  }
  
  private func credentialScope(datetime: String) -> String {
    return [
      datetime.substringToIndex(datetime.startIndex.advancedBy(8)),
      regionName,
      serviceName,
      "aws4_request"
      ].joinWithSeparator("/")
  }
  
  private func stringToSign(datetime: String, url: NSURL, headers: [String: String], httpMethod: String, bodyDigest: String) -> String {
    return [
      "AWS4-HMAC-SHA256",
      datetime,
      credentialScope(datetime),
      sha256(canonicalRequest(url, headers: headers, httpMethod: httpMethod, bodyDigest: bodyDigest)),
      ].joinWithSeparator("\n")
  }
  
  private func canonicalRequest(url: NSURL, headers: [String: String], httpMethod: String, bodyDigest: String) -> String {
    return [
      httpMethod,                       // HTTP Method
      pathForURL(url),                  // Resource Path
      url.query ?? "",                  // Canonicalized Query String
      "\(canonicalHeaders(headers))\n", // Canonicalized Header String (Plus a newline for some reason)
      signedHeaders(headers),           // Signed Headers String
      bodyDigest,                       // Sha265 of Body
      ].joinWithSeparator("\n")
  }
}
