//
//  AppDelegate.m
//  ScreenCapture
//
//  Created by Christopher Sexton on 11/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "ScreenCapture.h"

@implementation AppDelegate

@synthesize window;
@synthesize screenCapture;

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
//    // Insert code here to initialize your application
//		ProcessSerialNumber psn = { 0, kCurrentProcess };
//		TransformProcessType(&psn, kProcessTransformToBackgroundApplication);


    self.screenCapture = [[ScreenCapture alloc] init];
    [self.screenCapture takeScreenShot];    
    
    
}

@end
