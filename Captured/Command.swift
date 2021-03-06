//
//  Command.swift
//  Captured
//
//  Created by Christopher Sexton on 12/18/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Foundation
import Cocoa
import CoreGraphics
import ImageIO

class Command {

  func run(account: Account, path: String) {
    CapturedState.broadcastStateChange(.Active)

    UploadManager(account: account, path: path).run({ upload in
        if let url = upload.url {
          CapturedState.broadcastStateChange(.Success)
          self.copyToPasteboard(url)
          self.postSuccessNotification(account, url: url, path: path)
        }
      },
      error: { upload in
        CapturedState.broadcastStateChange(.Error)
      })
    self.resetGlobalStateAfterDelay()
  }

  func run(shortcut: Shortcut) {
    ScreenCapture().run(shortcut.screenCaptureOptions()) { path in
      if shortcut.annotateImage {
        let a = Annotator()
        a.annotateImageFileInPlace(path)
        if a.userCanceled { return }
      }

      if shortcut.scaleImage {
        self.scaleImageFileInPlace(path)
      }

      self.run(shortcut.getAccount()!, path: path)
    }
  }

  private func resetGlobalStateAfterDelay() {
    // Delay 5 seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
      Int64(5.0 * Double(NSEC_PER_SEC))),
      dispatch_get_main_queue()) { () -> Void in
      CapturedState.broadcastStateChange(.Normal)
    }
  }

  private func copyToPasteboard(text: String) {
    let pasteboard = NSPasteboard.generalPasteboard()
    pasteboard.clearContents()
    pasteboard.setString(text, forType: NSPasteboardTypeString)
  }

  private func postSuccessNotification(account: Account, url: String, path: String) {
    if NSUserDefaults.standardUserDefaults().boolForKey("EnableNotifications") {
      let notification = NSUserNotification()
      notification.title = "Uploaded to \(account.name)"
      notification.subtitle = "Link added to Clipboard"
      notification.informativeText = url
      notification.userInfo = ["url": url]
      notification.soundName = NSUserNotificationDefaultSoundName

      // Not confinced this is a good idea. May prefer not to load this into memory
      // just to stay light on the system resources.
      notification.contentImage = NSImage(contentsOfFile: path)

      NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
    }
  }


  private func scaleImageFileInPlace(path: String) -> Bool {

    // Get an image ref for the existing file
    let dataProvider = CGDataProviderCreateWithFilename(path)

    let imageRef = CGImageCreateWithPNGDataProvider(dataProvider!,
                                                    nil, false, .RenderingIntentDefault)

    // Calculate the new size
    let width = CGImageGetWidth(imageRef!) / 2
    let height = CGImageGetHeight(imageRef!) / 2

    // Create a new context for the resized image
    let context = CGBitmapContextCreate(nil, width, height,
                                        CGImageGetBitsPerComponent(imageRef!),
                                        CGImageGetBytesPerRow(imageRef!),
                                        CGImageGetColorSpace(imageRef!)!,
                                        CGImageAlphaInfo.PremultipliedLast.rawValue)

    // if the above step failed, we're done
    if context == nil {
      NSLog("Failed to create context for resized image")
      return false
    }

    CGContextSetInterpolationQuality(context!, .High)

    // draw image to context, effectively resizing it
    CGContextDrawImage(context!, CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)), imageRef!)

    // extract resulting image from context
    let imgRef = CGBitmapContextCreateImage(context!)

    // write it out to png
    let url = NSURL(fileURLWithPath: path)
    let dest = CGImageDestinationCreateWithURL(url, kUTTypePNG, 1, nil)
    CGImageDestinationAddImage(dest!, imgRef!, nil)
    CGImageDestinationFinalize(dest!)

    return true
  }
}
