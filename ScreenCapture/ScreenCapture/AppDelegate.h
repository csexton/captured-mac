//
//  AppDelegate.h
//  ScreenCapture
//
//  Created by Christopher Sexton on 11/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ScreenCapture.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (retain) ScreenCapture *screenCapture;

@end
