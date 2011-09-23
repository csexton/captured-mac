//
//  AArrow.m
//  Captured
//
//  Created by Christopher Sexton on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AArrow.h"

@implementation AArrow

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void)mouseUpAt: (CGPoint)point {

    p2 = point;
}
-(void)mouseDownAt: (CGPoint)point {
    p1 = point;
}
-(void)mouseDragAt: (CGPoint)point {
    p2 = point;
}

-(void)drawOn:(CGContextRef)context {
    
    CGFloat strokeColor[]	= {1.0,1.0,1.0,1.0};
    CGColorRef fillColor = CGColorCreateGenericRGB(0.986,0.419,1.0,1.0);
    
    CGContextSetStrokeColor(context, strokeColor);
    CGContextSetLineWidth(context, 3.0);
    [NSBezierPath setDefaultLineCapStyle:NSButtLineCapStyle];
    [NSBezierPath setDefaultLineJoinStyle:NSRoundLineJoinStyle];
    //CGColorRef fillColor = CGColorCreateGenericRGB(1.0,0.6,0.0,1.0);
    CGContextSetFillColorWithColor(context, fillColor);
    
    
    CGFloat theta = [self angleBetweenPoint:p2 and:p1];
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, p1.x, p1.y);
    CGContextRotateCTM (context, theta);
    
    //    CGSize myShadowOffset = CGSizeMake(4, -4);
    //    CGFloat myColorValues[] = {0, 0, 0, .8};
    
    CGContextSetShadow(context, CGSizeMake(2, -2), 5);
    
    CGFloat distance = [self distanceBetweenPoint: p1 and: p2];    
    if (distance == 0.0) {distance = 1;} //The is prolly not necessary 
    CGFloat scale = distance/100; // The Arrow is 100px long, so divide the distance by 100 to get the scale
    
    NSBezierPath *bezierPath = [NSBezierPath bezierPath];
    
    if (distance < 300) {
        [bezierPath setLineWidth:distance/100];
    } else {
        [bezierPath setLineWidth:3.0];
    }
    
    [bezierPath moveToPoint: NSMakePoint(0.0, 0.0)];
    [bezierPath lineToPoint: NSMakePoint(90.0, 3.0)];
    [bezierPath lineToPoint: NSMakePoint(90.0, 8.0)];
    [bezierPath lineToPoint: NSMakePoint(100.0, 0.0)];
    [bezierPath lineToPoint: NSMakePoint(90.0, -8.0)];
    [bezierPath lineToPoint: NSMakePoint(90.0, -3.0)];
    [bezierPath lineToPoint: NSMakePoint(0.0, 0.0)];
    [bezierPath closePath];
    
    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform scaleBy:scale];
    [bezierPath transformUsingAffineTransform: transform];
    
    //[bezierPath fill]; 
    [bezierPath stroke];
    
    NSColor *startingColor = [NSColor colorWithCalibratedRed:0.986 green:0.419 blue:1.0 alpha:1.000];
    NSColor *endColor = [NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:1.000];
    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:startingColor endingColor:endColor];
    
    [gradient drawInBezierPath:bezierPath angle:-90];  
    [gradient release];
    CGContextRestoreGState(context); 
}

- (CGFloat) angleBetweenPoint: (CGPoint)p and: (CGPoint)o {
    CGFloat ret = atan2(p.y - o.y, p.x - o.x);
    return ret;
}

- (CGFloat) distanceBetweenPoint: (CGPoint)pt1 and: (CGPoint) pt2 {
    CGFloat xDist = (pt2.x - pt1.x);
    CGFloat yDist = (pt2.y - pt1.y);
    return sqrt((xDist * xDist) + (yDist * yDist));
}

@end
