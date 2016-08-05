//
//  SFTPUploader.swift
//  Captured
//
//  Created by Christopher Sexton on 1/15/16.
//  Copyright © 2016 Christopher Sexton. All rights reserved.
//

class SFTPUploader: Uploader {
  let account: SFTPAccount
  private var linkURL: String?

  required init(account: SFTPAccount) {
    self.account = account
  }

  func upload(path: String) -> Bool {
    var success = false
    let host = account.hostname!
    let username = account.username!
    let session = NMSSHSession(host: host, andUsername: username)

    if account.password != nil {
      if session.connect() {
        session.authenticateByPassword(account.password!)

        if session.authorized {
          let ftp = NMSFTP.connectWithSession(session)
          let name = createFileName(path, length: account.fileNameLength)
          let pathOnServer = account.pathOnServer!
          let publicURL = account.publicURL!
          let pathWithName = joinPathSegments(pathOnServer, part2: name)

          ftp.createDirectoryAtPath(pathOnServer)
          success = ftp.writeFileAtPath(path, toFileAtPath: pathWithName)
          linkURL = joinPathSegments(publicURL, part2: name)
        }
      }
      session.disconnect()
    }
    return success
  }

  func test() -> String {
    var message = "Success!"
    let host = account.hostname!
    let username = account.username!
    let session = NMSSHSession(host: host, andUsername: username)

    if session.connect() {
      if !session.authenticateByPassword(account.password!) {
        message = "Invalid credentials for \(username)"
      }
    } else {
      message = "Unable to connect to \(host)"
    }

    session.disconnect()
    return message
  }

  func url() -> String? {
    return linkURL
  }

  private func joinPathSegments(part1: String, part2: String) -> String {
    let token = (part1.characters.last! == "/") ? "" : "/"
    return "\(part1)\(token)\(part2)"
  }

  private func createFileName(path: String, length: Int) -> String {
    var ext = NSURL(fileURLWithPath: path).pathExtension!
    if !ext.isEmpty {
      ext = ".\(ext)"
    }
    return "\(randomName(length))\(ext)"
  }

  private func randomName(length: Int) -> String {
    let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let allowedCharsCount = UInt32(allowedChars.characters.count)
    var randomString = ""

    for _ in (0..<length) {
      let randomNum = Int(arc4random_uniform(allowedCharsCount))
      let newCharacter = allowedChars[allowedChars.startIndex.advancedBy(randomNum)]
      randomString += String(newCharacter)
    }

    return randomString
  }

}
