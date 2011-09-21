//
//  ADrawable.m
//  Captured
//
//  Created by Christopher Sexton on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ADrawable.h"

@implementation ADrawable

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void)drawOn:(CGContextRef)context{}

-(void)addPoint: (CGPoint)point{}
-(void)mouseDownAt: (CGPoint)point{}
-(void)mouseDragAt: (CGPoint)point{}
-(void)mouseUpAt: (CGPoint)point{}

@end
