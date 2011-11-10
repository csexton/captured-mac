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

- (void)viewDidMoveToWindow {
    NSLogDebugMsg;
//    [self updateTrackingAreas];
}
- (void)updateTrackingAreas
{
    // This is called when the window is resized
    NSLogDebugMsg;
    // Setup a new tracking area when the view is added to the window.
    NSTrackingArea* trackingArea = [[NSTrackingArea alloc] initWithRect:[self frame] options: (NSTrackingMouseEnteredAndExited | NSTrackingActiveInActiveApp | NSTrackingCursorUpdate /*| NSTrackingMouseMoved*/) owner:self userInfo:nil];
    [self addTrackingArea:trackingArea];

    [trackingArea release];
}

- (BOOL)acceptsFirstResponder {return YES;}
- (BOOL)becomeFirstResponder {return YES;}

- (void)viewDidLoad {
    NSLog(@"<%p>%s:", self, __PRETTY_FUNCTION__);
    [NSCursor hide];
}


- (void)mouseEntered:(NSEvent *)theEvent {
    NSLog(@"<%p>%s:", self, __PRETTY_FUNCTION__);
    [[NSCursor crosshairCursor] push];

}

- (void)mouseExited:(NSEvent *)theEvent {
    NSLog(@"<%p>%s:", self, __PRETTY_FUNCTION__);
    [[NSCursor crosshairCursor] pop];
}

- (void)mouseMoved:(NSEvent *)theEvent {
//    NSLog(@"<%p>%s:", self, __PRETTY_FUNCTION__);
//    [[NSCursor crosshairCursor] set];
    
}
-(void)cursorUpdate:(NSEvent *)theEvent
{
    NSLog(@"<%p>%s:", self, __PRETTY_FUNCTION__);

    [[NSCursor crosshairCursor] set];
}

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
        CGContextSetRGBStrokeColor(context, 0, 0, 0, 1.0);
        CGContextSetRGBFillColor(context, 1, 1, 1, 0.3);
        CGContextSetLineWidth(context, 1.0);
//        CGContextSetLineJoin(context, NSBevelLineJoinStyle);
        CGContextSetLineCap(context, NSSquareLineCapStyle);
        CGContextSetShadow(context, CGSizeMake(2, -2), 5);
        CGContextBeginPath(context);
//        CGContextMoveToPoint(context,downLocation.x,downLocation.y);
//        CGContextAddLineToPoint(context,downLocation.x,currentLocation.y);
//        CGContextAddLineToPoint(context,currentLocation.x,currentLocation.y);
//        CGContextAddLineToPoint(context,currentLocation.x,downLocation.y);
//        CGContextAddLineToPoint(context,downLocation.x,downLocation.y);
        CGContextFillRect(context, rect);
        CGContextAddRect(context, rect);

        CGContextDrawPath(context,kCGPathStroke);
        CGContextRestoreGState(context);
    }
    
}

- (void)mouseUp:(NSEvent *)event {
    NSLog(@"<%p>%s:", self, __PRETTY_FUNCTION__);
    
    [self setNeedsDisplay:YES];
    
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
