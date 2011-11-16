//
//  ScreenCaptureView.m
//  ScreenCapture
//
//  Created by Christopher Sexton on 11/8/11.
//  Copyright (c) 2011 Codeography. All rights reserved.
//

#define NSLogDebugMsg NSLog(@"<%p>%s:", self, __PRETTY_FUNCTION__)


#import "ScreenCaptureView.h"

@implementation ScreenCaptureView
@synthesize delegate;


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        downLocation = CGPointMake(0, 0);
        downLocation = CGPointMake(0, 0);
        drawing = NO;
    }
    return self;
}
- (BOOL)acceptsFirstResponder {return YES;}
- (BOOL)becomeFirstResponder {return YES;}

- (void) resetCursorRects
{
    NSLog(@"<%p>%s:", self, __PRETTY_FUNCTION__);

    [super resetCursorRects];
    [self addCursorRect: [self bounds]
                 cursor: [NSCursor crosshairCursor]];
    
} 


- (void)drawRect:(NSRect)rect {
	NSGraphicsContext* graphicsContext = [NSGraphicsContext currentContext];
	CGContextRef context = (CGContextRef) [graphicsContext graphicsPort];
	
	CGContextSetFillColorSpace(context,colorSpace);	
	CGContextSetStrokeColorSpace(context,colorSpace);
    
//    CGFloat fillColor[4] = {0.0,1.0,0.0,0.5};
//	CGContextSetFillColor(context,fillColor);
//    CGContextFillRect(context, CGRectMake (0.0, 0.0, rect.size.width, rect.size.height ));
    
    [self drawSelectionOn:context];

    
}


-(void)drawSelectionOn:(CGContextRef)context {
    if (drawing) {
        CGRect rect = CGRectMake(downLocation.x, downLocation.y, currentLocation.x-downLocation.x, currentLocation.y-downLocation.y);
        CGContextSaveGState(context);
        CGContextSetRGBStrokeColor(context, 1, 1, 1, 0.8);
        CGContextSetRGBFillColor(context, 1, 1, 1, 0.2);
        CGContextSetLineWidth(context, 1.0);
        CGContextSetLineCap(context, NSSquareLineCapStyle);
        CGContextSetShadow(context, CGSizeMake(2, -2), 5);
        CGContextBeginPath(context);
        CGContextFillRect(context, rect);
        CGContextAddRect(context, rect);
        CGContextDrawPath(context,kCGPathStroke);
        CGContextRestoreGState(context);
    }
}

- (void)mouseUp:(NSEvent *)event {
    NSLog(@"<%p>%s:", self, __PRETTY_FUNCTION__);
    [self setNeedsDisplay:YES];

    NSRect r = NSMakeRect(downLocation.x, downLocation.y, currentLocation.x-downLocation.x, currentLocation.y-downLocation.y);
    
    drawing = NO;
    
    if (delegate && [delegate conformsToProtocol:@protocol(ScreenCaptureDelegate)]) {
        [delegate rectWasSelected:r];
    }
    
}

- (void)mouseDown:(NSEvent *)event{
    downLocation = [self convertPoint:[event locationInWindow] fromView:[[self window] contentView]];
    currentLocation = [self convertPoint:[event locationInWindow] fromView:[[self window] contentView]];

    drawing = YES;
       
	[self setNeedsDisplay:YES];
}

-(void)mouseDragged:(NSEvent *)event {   
    currentLocation = [self convertPoint:[event locationInWindow] fromView:[[self window] contentView]];

	[self setNeedsDisplay:YES];
}






@end
