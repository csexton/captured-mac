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
  
  var shortcut : Shortcut
  
  init(shortcut:Shortcut) {
    self.shortcut = shortcut
  }
  
  private func run(){
    ScreenCapture().run(shortcut.screenCaptureOptions()) { path in
      CapturedState.broadcastStateChange(.Active)

      if (self.shortcut.scaleImage) {
        self.scaleImageFileInPlace3(path)
      }

      if let account = self.shortcut.getAccount() {
        Upload(account: account, path: path).run() { upload in
          if let url = upload.url {
            self.copyToPasteboard(url)
          }
        }
      }
      self.resetGlobalStateAfterDelay()
    }
  }
  
  func runAsync(){
    dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {
      self.run()
    }
  }
  
  private func resetGlobalStateAfterDelay() {
    // Delay 5 seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(5.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
      CapturedState.broadcastStateChange(.Normal)
    }
  }

  private func copyToPasteboard(text: String) {
      let pasteboard = NSPasteboard.generalPasteboard()
      pasteboard.clearContents()
      pasteboard.setString(text, forType: NSPasteboardTypeString)
  }


  private func scaleImageFileInPlace(path:String) -> Bool {
    
    // get an image ref for the existing file
    let dataProvider = CGDataProviderCreateWithFilename(path)
    let imageRef = CGImageCreateWithPNGDataProvider(dataProvider, nil, false, .RenderingIntentDefault)
    
    // calculate the new size
    let width = CGImageGetWidth(imageRef) / 2
    let height = CGImageGetHeight(imageRef) / 2
    
    // create a new context for the resized image
    let context = CGBitmapContextCreate(nil, width, height,
      CGImageGetBitsPerComponent(imageRef),
      CGImageGetBytesPerRow(imageRef),
      CGImageGetColorSpace(imageRef),
      CGImageAlphaInfo.PremultipliedLast.rawValue)
    
    // if the above step failed, we're done
    if (context == nil) {
      NSLog("Failed to create context for resized image")
      return false
    }
    
    CGContextSetInterpolationQuality(context, .High)
    
    // draw image to context, effectively resizing it
    CGContextDrawImage(context, CGRectMake(0, 0, CGFloat(width), CGFloat(height)), imageRef)
    
    // extract resulting image from context
    let imgRef = CGBitmapContextCreateImage(context)
    
    // write it out to png
    let url = NSURL(fileURLWithPath: path)
    let dest = CGImageDestinationCreateWithURL(url, kUTTypePNG, 1, nil);
    CGImageDestinationAddImage(dest!, imgRef!, nil);
    CGImageDestinationFinalize(dest!);
    
    return true;
  }

  func scaleImageFileInPlace2(path:String) {
    let org = NSImage(contentsOfFile: path)!
    let width = org.size.width / 2
    let height = org.size.height / 2

    let img = NSImage(size: CGSizeMake(width, height))

    img.lockFocus()
    let ctx = NSGraphicsContext.currentContext()
    ctx?.imageInterpolation = .High
    org.drawInRect(NSMakeRect(0, 0, width, height), fromRect: NSMakeRect(0, 0, org.size.width, org.size.height), operation: .CompositeCopy, fraction: 1)
    img.unlockFocus()


//    if let imgRep = img.representations[0] as? NSBitmapImageRep
//    {
//      if let data = imgRep.representationUsingType(NSBitmapImageFileType.NSPNGFileType, properties: [:])
//      {
//        data.writeToFile(path, atomically: false)
//      }
//    }

//    CGImageRef cgRef = [image CGImageForProposedRect:NULL
//      context:nil
//      hints:nil];

    let cgr = img.CGImageForProposedRect(nil, context: ctx, hints: nil)
//    NSBitmapImageRep *newRep = [[NSBitmapImageRep alloc] initWithCGImage:cgRef];
    let bir = NSBitmapImageRep(CGImage: cgr!)
//    [newRep setSize:[image size]];   // if you want the same resolution
    bir.size = img.size
//    NSData *pngData = [newRep representationUsingType:NSPNGFileType properties:nil];
    let data = bir.representationUsingType(.NSBMPFileType, properties: [:])
//    [pngData writeToFile:path atomically:YES];
    data?.writeToFile(path, atomically: false)
//    [newRep autorelease];



  }

  private func scaleImageFileInPlace3(path:String) {
    let image = NSImage(contentsOfFile: path)!
    
    let h = Int(image.size.height / 2)
    let w = Int(image.size.width / 2)
    
    let bir = NSBitmapImageRep(
      bitmapDataPlanes: nil,
      pixelsWide: w,
      pixelsHigh: h,
      bitsPerSample: 8,
      samplesPerPixel: 4,
      hasAlpha: true,
      isPlanar: false,
      colorSpaceName: NSCalibratedRGBColorSpace,
      bytesPerRow: 0,
      bitsPerPixel: 0)

    NSGraphicsContext.saveGraphicsState()
    let ctx = NSGraphicsContext(bitmapImageRep: bir!)
    NSGraphicsContext.setCurrentContext(ctx)
    image.drawInRect(NSRect(x: 0, y: 0, width: w, height: h))
    NSGraphicsContext.restoreGraphicsState()
    
    if let resizedRep = bir!.representationUsingType(.NSPNGFileType, properties: [:]) {
      resizedRep.writeToFile(path, atomically: true)
    }
  }
  
  

}

