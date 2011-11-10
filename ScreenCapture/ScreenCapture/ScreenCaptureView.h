//
//  ScreenCaptureView.h
//  ScreenCapture
//
//  Created by Christopher Sexton on 11/8/11.
//  Copyright (c) 2011 Codeography. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ScreenCapture.h"

@interface ScreenCaptureView : NSView {
    CGColorSpaceRef colorSpace;
    CGPoint currentLocation;
    CGPoint downLocation;
    NSCursor *cursor;
    BOOL drawing;
}
@property (readwrite, assign) id<ScreenCaptureDelegate> delegate;


-(void)drawSelectionOn:(CGContextRef)context;



@end
