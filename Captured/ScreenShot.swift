//
//  ScreenShot.swift
//  Captured
//
//  Created by Christopher Sexton on 6/29/16.
//  Copyright © 2016 Christopher Sexton. All rights reserved.
//

import Foundation

class ScreenShot {
  func run() {


    let activeDisplay = CGMainDisplayID()
    let screenY = CGDisplayPixelsHigh(activeDisplay)
    let screenX = CGDisplayPixelsWide(activeDisplay)

    let image = CGDisplayCreateImage(activeDisplay)
    let bbp = CGImageGetBitsPerPixel(image)

    writeToDisk(image!)
//    image = CGDisplayCreateImage(kCGDirectMainDisplay)
//    displays = CGDirectDisplayID
//    image = CGDisplayCreateImage(displays[displaysIndex])
  }

  func writeToDisk(image: CGImageRef?) {

    let url = NSURL.fileURLWithPath("/Users/csexton/Desktop/blargle.png")
    let destination = CGImageDestinationCreateWithURL(url, kUTTypePNG, 1, nil)
    CGImageDestinationAddImage(destination!, image!, nil)
    CGImageDestinationFinalize(destination!)

//    BOOL CGImageWriteToFile(CGImageRef image, NSString *path) {
//      CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:path];
//      CGImageDestinationRef destination = CGImageDestinationCreateWithURL(url, kUTTypePNG, 1, NULL);
//      if (!destination) {
//        NSLog(@"Failed to create CGImageDestination for %@", path);
//        return NO;
//      }
//
//      CGImageDestinationAddImage(destination, image, nil);
//
//      if (!CGImageDestinationFinalize(destination)) {
//        NSLog(@"Failed to write image to %@", path);
//        CFRelease(destination);
//        return NO;
//      }
//
//      CFRelease(destination);
//      return YES;
//    }
  }
}
