//
//  ScreenCaptureWindow.m
//  ScreenCapture
//
//  Created by Christopher Sexton on 11/15/11.
//  Copyright (c) 2011 Codeography. All rights reserved.
//

#import "ScreenCaptureWindow.h"

#define DebugWhereAmI NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd))

@implementation ScreenCaptureWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)windowStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)deferCreation {
	DebugWhereAmI;
    NSRect screenRect = [[NSScreen mainScreen] frame];
	if ((self = [super initWithContentRect:NSMakeRect(screenRect.origin.x, screenRect.origin.y, NSWidth(screenRect), NSHeight(screenRect))
                                 styleMask:NSBorderlessWindowMask
                                   backing:NSBackingStoreBuffered defer:deferCreation])) {
		[self setOpaque:NO];
        self.backgroundColor = [NSColor clearColor];
		[self setLevel:CGShieldingWindowLevel()];
	}
	return self;
}


// Windows created with NSBorderlessWindowMask normally can't be key, but we want ours to be
- (BOOL)canBecomeKeyWindow { return YES; }


@end
