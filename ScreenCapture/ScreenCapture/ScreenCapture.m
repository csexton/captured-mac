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
                                                     styleMask:NSBorderlessWindowMask
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
    [self.window setBackgroundColor:[NSColor colorWithDeviceRed:0.2 green:0.2 blue:0.2 alpha:0.2]];
    
    // Little hack to prevent resizing
    [self.window setMinSize:[window frame].size];
    [self.window setMaxSize:[window frame].size];
    
//    [self.window setBackgroundColor:[NSColor clearColor]];
//    [NSCursor setHiddenUntilMouseMoves:YES];

//    [window setFrame:[[NSScreen mainScreen] frame] display:YES]; //TODO: for each screen
    
    // Create the subview
    NSRect viewFrame = NSMakeRect(0, 0,  0,  0);
    
    ScreenCaptureView *subview = [[ScreenCaptureView alloc] initWithFrame:viewFrame ];
    subview.delegate = self;

    [[self.window contentView] addSubview:subview];
    [self.window setContentView:subview];

    [self.window makeFirstResponder:subview];
//    [self.window makeKeyAndOrderFront:NSApp];
    [self.window orderFrontRegardless];

    
}

void CGImageWriteToFile(CGImageRef image, NSString *path) {
    CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:path];
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL(url, kUTTypePNG, 1, NULL);
    CGImageDestinationAddImage(destination, image, nil);
    
    bool success = CGImageDestinationFinalize(destination);
    if (!success) {
        NSLog(@"Failed to write image to %@", path);
    }
    
    CFRelease(destination);
}

-(void) rectWasSelected: (NSRect)rect {

    // This is a bit of a hack, because I need the event loop to finish redrawing the 
    // window (well, not drawing it) before calling my selector. Otherwise I get the selected area in focus.
    [self performSelector:@selector(captureRect:) withObject:NSStringFromRect(rect) afterDelay:0.01];
    
}
-(void) captureRect: (NSString *)rectStr {
    
    NSRect rect = NSRectFromString(rectStr);
    
    //yFromBottom = screenHeight - windowHeight - yFromTop
    float screenHeight = [[NSScreen mainScreen] frame].size.height;
    float newy = screenHeight - rect.origin.y - rect.size.height;
    CGRect invertedRect = CGRectMake(rect.origin.x, newy, rect.size.width, rect.size.height);
    
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Desktop/caps.png"];  
    
    //[[[[NSScreen mainScreen] deviceDescription] @"NSScreenNumber"] unsignedIntValue]
    CGDirectDisplayID display = (CGDirectDisplayID) [[[[NSScreen mainScreen] deviceDescription] objectForKey:@"NSScreenNumber"] unsignedIntValue] ;
    CGImageRef cgImg = CGDisplayCreateImageForRect(display,invertedRect);
    
    CGImageWriteToFile(cgImg, path);
    if (cgImg) { CFRelease(cgImg); }
    
//    [window orderFrontRegardless];
    
    
}

@end
