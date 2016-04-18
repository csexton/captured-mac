//
//  DropboxUploader.swift
//  Captured
//
//  Created by Christopher Sexton on 4/16/16.
//  Copyright © 2016 Christopher Sexton. All rights reserved.
//

import Cocoa

class DropboxUploader: NSObject, Uploader, DBRestClientOSXDelegate {

  let options: [String:String]
  let semaphore = dispatch_semaphore_create(0)

  private var linkURL: String?

  required init(account: Account) {
    options = account.secrets
  }

  func upload(path: String) -> Bool {
    // Welp. This is not implmented, obvs.
    //
    // Dropbox has kinda made Captured a feature in their app. So I am thinking
    // I drop supporr for this service anyway. It seemed like it was going to be
    // pretty easy to support, but since their SDK only handles one account at a
    // time AND couldn't get the `uploadFile` API to work after an hour or two of
    // swearing.




    // let session = DBSession.sharedSession()
    // let client = DBRestClient.init(session: session)
    // client.delegate = self
    //
    // /* Uploads a file that will be named filename to the given path on the server. sourcePath is the
    //  full path of the file you want to upload. If you are modifying a file, parentRev represents the
    //  rev of the file before you modified it as returned from the server. If you are uploading a new
    //  file set parentRev to nil. */
    // //public func uploadFile(filename: String!, toPath path: String!, withParentRev parentRev: String!, fromPath sourcePath: String!)
    // client.uploadFile("blargle.png", toPath: "toPath", withParentRev: nil, fromPath: path)
    // // I think this is async, so wait for the upload to finish
    // dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)

    return false
  }

  func url() -> String? {
    return linkURL
  }

  // MARK: DBRestClientOSXDelegate

  // - (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath from:(NSString*)srcPath metadata:(DBMetadata*)metadata;
  func restClient(client: DBRestClient!, uploadedFile destPath: String!, from srcPath: String!) {
    print("uploaded!!!")
    dispatch_semaphore_signal(semaphore)
  }
  // - (void)restClient:(DBRestClient*)client uploadProgress:(CGFloat)progress forFile:(NSString*)destPath from:(NSString*)srcPath;
  // - (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error;
  func restClient(client: DBRestClient!, uploadFileFailedWithError error: NSError!) {
    print("ERROR")
    dispatch_semaphore_signal(semaphore)
  }


}