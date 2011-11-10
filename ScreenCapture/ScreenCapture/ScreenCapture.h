//
//  ScreenCapture.h
//  ScreenCapture
//
//  Created by Christopher Sexton on 11/8/11.
//  Copyright (c) 2011 Codeography. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScreenCapture : NSObject <NSWindowDelegate>

@property (retain) NSWindow *window;


- (void) takeScreenShot;

@end
