//
//  ViewBackground.m
//  Captured
//
//  Created by Christopher Sexton on 2/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
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
    [[NSColor magentaColor] set];
    NSRectFill(rect);
}

@end
