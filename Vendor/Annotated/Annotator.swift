//
//  Annotater.swift
//  Captured
//
//  Created by Christopher Sexton on 12/23/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import Foundation
import Cocoa

class Annotator {
  var userCanceled = true
  var annotatedWindow : AnnotatedImageController?

  // This will pop up a window to let the user annotate the image. It is a 
  // "modal" style window and this method will block until the user 
  // finishes.
  func annotateImageFileInPlace(path:String) {
    let semaphore = dispatch_semaphore_create(0)
    dispatch_async(dispatch_get_main_queue()) {

      // ARC requires an ivar for the window controller or the window will never display.
      self.annotatedWindow = AnnotatedImageController(windowNibName: "AnnotatedImage")
      self.annotatedWindow!.semaphore = semaphore
      self.annotatedWindow!.showWindowAndAnnotateImageInPlace(path)
    }
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)

    userCanceled = self.annotatedWindow!.userCanceled
  }
  
}
