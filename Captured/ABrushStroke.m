//
//  ABrushStroke.m
//  Captured
//
//  Created by Christopher Sexton on 9/21/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import "ABrushStroke.h"
#import "APoint.h"
#import <CoreGraphics/CoreGraphics.h>

@implementation ABrushStroke


- (id)initWithColor:(NSColor*)c andWidth: (CGFloat)w
{
    self = [super init];
    if (self) {
        // Initialization code here.
        points = [[NSMutableArray alloc] init];
        color = [c copy];
        width = w;
    }
    
    return self;
}

-(void)addPoint: (CGPoint)point {
    APoint * p = [[APoint alloc]initWithCGPoint:point];
    [points addObject:p]; 
}

-(void)mouseUpAt: (CGPoint)point {
    [self addPoint:point];

}
-(void)mouseDownAt: (CGPoint)point {
    [self addPoint:point];
}
-(void)mouseDragAt: (CGPoint)point {
    [self addPoint:point];
}

-(void)drawOn:(CGContextRef)context {
    if ([points count] == 0) { return; }
    
    CGContextSaveGState(context);
    
    //CGContextSetRGBStrokeColor(context,0.886, 0.294, 0.223, 0.9);
    CGContextSetRGBStrokeColor(context, [color redComponent], [color greenComponent], [color blueComponent], [color alphaComponent]);
    CGContextSetLineWidth(context, width );
    CGContextSetLineJoin(context,kCGLineJoinRound);
    CGContextSetLineCap(context, kCGLineCapRound);
    
    CGContextSetShadow(context, CGSizeMake(2, -2), 5);
        
    NSUInteger tvarIntNumberOfPoints	= [points count];				// always >= 2
    APoint * tvarLastPointObj			= [points objectAtIndex:0];
    CGContextBeginPath(context);
    CGContextMoveToPoint(context,[tvarLastPointObj x],[tvarLastPointObj y]);
    
    NSUInteger j;
    for (j = 1; j < tvarIntNumberOfPoints; j++) {  // note the index starts at 1
        APoint * tvarCurPointObj			= [points objectAtIndex:j];
        CGContextAddLineToPoint(context,[tvarCurPointObj x],[tvarCurPointObj y]);
    }
    CGContextDrawPath(context,kCGPathStroke);
	
    CGContextRestoreGState(context);
}

@end
