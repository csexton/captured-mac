//
//  Created by Christopher Sexton on 7/16/16.
//  Copyright © 2016 Christopher Sexton. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  func applicationDidFinishLaunching(aNotification: NSNotification) {
    //
    // This helper lives in the main app bundle. So to launch the main app we
    // are going to get the path to this bundle, go up 4 directories and
    // attempt to Launch the parent app bundle.
    //
    // Go from:
    //
    //     /Applications/Captured.app/Contents/Library/LoginItems/Captured\ Helper.app
    // To:
    //
    //     /Applications/Captured.app
    //
    // Then just hope it is something we can launch with the workspace.
    //
    NSLog("Running Helper for \(Bundle.main.bundlePath)")
    var pathToMainApp: URL? = URL(fileURLWithPath: Bundle.main.bundlePath)
    for _ in 1...4 {
      pathToMainApp = pathToMainApp?.deletingLastPathComponent()
    }
    let appPath = pathToMainApp!.path
    if appPath == pathToMainApp!.path {
      NSLog("Launching Application at \(appPath)")
      NSWorkspace.shared.launchApplication(appPath)
    }

    NSApplication.shared.terminate(self)
  }
}

