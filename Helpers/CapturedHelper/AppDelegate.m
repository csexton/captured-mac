//
//  AppDelegate.m
//  CapturedHelper
//
//  Created by Christopher Sexton on 1/21/16.
//  Copyright © 2016 Christopher Sexton. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  // Check if main app is already running; if yes, do nothing and terminate helper app
  BOOL alreadyRunning = NO;
  NSArray *running = [[NSWorkspace sharedWorkspace] runningApplications];
  for (NSRunningApplication *app in running) {
    if ([[app bundleIdentifier] isEqualToString:@"com.codeography.Captured"]) {
      alreadyRunning = YES;
    }
  }
  
  if (alreadyRunning) {
    NSLog(@"Captured is already running.");
  } else {
    NSLog(@"Starting Captured.");
    NSArray *pathComponents = [[[NSBundle mainBundle] bundlePath] pathComponents];
    pathComponents = [pathComponents subarrayWithRange:NSMakeRange(0, [pathComponents count] - 4)];
    NSString *path = [NSString pathWithComponents:pathComponents];
    [[NSWorkspace sharedWorkspace] launchApplication:path];
  }
  [NSApp terminate:nil];
}

//- (void)applicationWillTerminate:(NSNotification *)aNotification {
//  // Insert code here to tear down your application
//}

@end
