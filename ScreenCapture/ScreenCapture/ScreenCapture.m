//
//  ScreenCapture.m
//  ScreenCapture
//
//  Created by Christopher Sexton on 11/8/11.
//  Copyright (c) 2011 Codeography. All rights reserved.
//

#import "ScreenCapture.h"
#import "ScreenCaptureView.h"

@implementation ScreenCapture
@synthesize window;

-(void) takeScreenShot {
    
    // Create the window
    NSRect frame = [[NSScreen mainScreen] frame];
    self.window  = [[NSWindow alloc] initWithContentRect:frame
                                                     styleMask:NSResizableWindowMask
                                                       backing:NSBackingStoreBuffered
                                                         defer:NO];
    
//    NSRect frame = NSMakeRect(200, 200, 200, 200);
//    self.window  = [[NSWindow alloc] initWithContentRect:frame
//                                               styleMask:NSResizableWindowMask
//                                                 backing:NSBackingStoreBuffered
//                                                   defer:NO];
    [self.window setDelegate:self];
    [self.window setAcceptsMouseMovedEvents:YES];
    [self.window setOpaque:NO];
    [self.window setLevel:CGShieldingWindowLevel()];
    [self.window setBackgroundColor:[NSColor colorWithDeviceRed:0.2 green:0.2 blue:0.2 alpha:0.5]];
    
    // Little hack to prevent resizing
    [self.window setMinSize:[window frame].size];
    [self.window setMaxSize:[window frame].size];
    
//    [self.window setBackgroundColor:[NSColor clearColor]];
//    [NSCursor setHiddenUntilMouseMoves:YES];

//    [window setFrame:[[NSScreen mainScreen] frame] display:YES]; //TODO: for each screen
    
    // Create the subview
    NSRect viewFrame = NSMakeRect(0, 0,  0,  0);
    
    NSView *subview = [[ScreenCaptureView alloc] initWithFrame:viewFrame];  

    [[self.window contentView] addSubview:subview];
    [self.window setContentView:subview];

    [self.window makeFirstResponder:subview];
//    [self.window makeKeyAndOrderFront:NSApp];
    [self.window orderFrontRegardless];

    
}


@end
