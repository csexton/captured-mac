//
//  AppMode.swift
//  Captured
//
//  Created by Christopher Sexton on 7/18/16.
//  Copyright © 2016 Christopher Sexton. All rights reserved.
//

import Foundation

class AppMode {

  // Detect if we are running in "debug" mode. This is done by setting the
  // "CAPTURED_DEBUG" enviroment variable. In Xcode this can be set in the
  // scheme's Enviroment Variable:
  //
  // - Scheme -> Edit Scheme...
  // - Choose "Run"
  // - Add CAPTURED_DEBUG = 1 to the Enviroment Variable section
  //
  class func debug() -> Bool {
    return (NSProcessInfo.processInfo().environment["CAPTURED_DEBUG"] != nil)
  }

  // Detect if that app is running in a App Store Sandbox Container
  //
  // http://stackoverflow.com/questions/12177948/how-do-i-detect-if-my-app-is-sandboxed
  //
  class func sandbox() -> Bool {
    return (NSProcessInfo.processInfo().environment["APP_SANDBOX_CONTAINER_ID"] != nil)
  }
}
