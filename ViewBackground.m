//
//  ViewBackground.m
//  Captured
//
//  Created by Christopher Sexton on 2/10/11.
//  Copyright 2011 Christopher Sexton. All rights reserved.
//

#import "ViewBackground.h"


@implementation ViewBackground

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

-(void)drawRect:(NSRect)rect
{
    //NSLog(@"Drawing...");
    // Load the image.
    NSImage *anImage = [[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"WelcomeWindowBackground" ofType:@"png"]] retain];
    
    // Find the point at which to draw it.
    NSPoint backgroundCenter;
    backgroundCenter.x = [self bounds].size.width / 2;
    backgroundCenter.y = [self bounds].size.height / 2;
    
    NSPoint drawPoint = backgroundCenter;
    drawPoint.x -= [anImage size].width / 2;
    drawPoint.y -= [anImage size].height / 2;
    
    // Draw it.
    [anImage drawAtPoint:drawPoint
                fromRect:NSZeroRect
               operation:NSCompositeSourceOver
                fraction:1.0];

}

@end
