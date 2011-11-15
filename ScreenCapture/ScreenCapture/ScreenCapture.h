//
//  ScreenCapture.h
//  ScreenCapture
//
//  Created by Christopher Sexton on 11/8/11.
//  Copyright (c) 2011 Codeography. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ScreenCaptureDelegate <NSObject>
@required
-(void) rectWasSelected: (NSRect)rect;
@end

@interface ScreenCapture : NSObject <NSWindowDelegate, ScreenCaptureDelegate>
@property (retain) NSWindow *window;
- (void) takeScreenShot;

void CGImageWriteToFile(CGImageRef image, NSString *path);

@end
