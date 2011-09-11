

#import <Cocoa/Cocoa.h>

@interface AnnotatedImageView : NSView {
	CGColorSpaceRef colorSpace;
    NSPoint currentLocation;
    NSPoint downLocation;
    NSImage * image;
    CGImageRef imageRef;
    
    NSMutableArray	* arrayOfBrushStrokes;
	NSMutableArray	* arrayOfPoints;

}

- (CGPoint) rotate:(CGPoint) p by:(CGFloat) theta;
- (CGFloat) angleBetweenPoint: (CGPoint)p and: (CGPoint)o;
- (CGPoint) rotatePoint: (CGPoint)p to: (CGPoint)d around: (CGPoint)o;
- (CGFloat) distanceBetweenPoint: (CGPoint)p1 and: (CGPoint) p2;

- (void)drawArrowOn:(CGContextRef)context from:(CGPoint)p1 to:(CGPoint)p2;
- (void)drawBrushStrokesOn:(CGContextRef)context;

- (CGColorSpaceRef) getRGBColorSpace;
- (void)setImage:(NSImage*) i;

- (CGImageRef) nsImageToCGImageRef:(NSImage*)image;
- (IBAction)saveViewToDesktop:(id)sender;


@property (readwrite) BOOL useBrush;
@property (readwrite) BOOL useArrow;



@end
