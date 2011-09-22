

#import <Cocoa/Cocoa.h>
#import "ABrushStroke.h"

@interface AnnotatedImageView : NSView {
	CGColorSpaceRef colorSpace;
    CGPoint currentLocation;
    CGPoint downLocation;
    NSImage * image;
    CGImageRef imageRef;
    
    BOOL useBrush;
    BOOL useHighlighter;
    BOOL useArrow;
    
    NSColor * brushColor;

    NSMutableArray	* arrayOfBrushStrokes;
	NSMutableArray	* arrayOfPoints;
    
    ADrawable *currentStroke;

}

//- (CGPoint) rotate:(CGPoint) p by:(CGFloat) theta;
//- (CGFloat) angleBetweenPoint: (CGPoint)p and: (CGPoint)o;
//- (CGPoint) rotatePoint: (CGPoint)p to: (CGPoint)d around: (CGPoint)o;
//- (CGFloat) distanceBetweenPoint: (CGPoint)p1 and: (CGPoint) p2;

//- (void)drawArrowOn:(CGContextRef)context from:(CGPoint)p1 to:(CGPoint)p2;
- (void)drawBrushStrokesOn:(CGContextRef)context;

- (CGColorSpaceRef) getRGBColorSpace;
- (void)setImage:(NSImage*) i;

- (CGImageRef) nsImageToCGImageRef:(NSImage*)image;
- (void)saveViewToFile:(NSString *) path;
-(void)undoDraw;

@property (readwrite) BOOL useBrush;
@property (readwrite) BOOL useHighlighter;
@property (readwrite) BOOL useArrow;
@property (readwrite, retain) NSColor *brushColor;

@end
