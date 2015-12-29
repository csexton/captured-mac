#import <Cocoa/Cocoa.h>
#import "ABrushStroke.h"

@interface AnnotatedImageView : NSView {
  CGColorSpaceRef colorSpace;
  CGPoint currentLocation;
  CGPoint downLocation;
  NSImage *image;
  CGImageRef imageRef;

  BOOL useBrush;
  BOOL useHighlighter;
  BOOL useArrow;

  NSColor *brushColor;
  NSCursor *pencilCursor;
  NSCursor *highlighterCursor;

  NSMutableArray *arrayOfBrushStrokes;
  NSMutableArray *arrayOfPoints;

  ADrawable *currentStroke;
}

//- (CGPoint) rotate:(CGPoint) p by:(CGFloat) theta;
//- (CGFloat) angleBetweenPoint: (CGPoint)p and: (CGPoint)o;
//- (CGPoint) rotatePoint: (CGPoint)p to: (CGPoint)d around: (CGPoint)o;
//- (CGFloat) distanceBetweenPoint: (CGPoint)p1 and: (CGPoint) p2;

- (void)selectBrushTool;
- (void)selectHighlighterTool;
- (void)selectArrowTool;

//- (void)drawArrowOn:(CGContextRef)context from:(CGPoint)p1 to:(CGPoint)p2;
- (void)drawBrushStrokesOn:(CGContextRef)context;

- (void)setImage:(NSImage *)i;

- (CGImageRef)nsImageToCGImageRef:(NSImage *)image;
- (void)saveViewToFile:(NSString *)path;
- (void)undoDraw;

@property (readwrite, retain) NSColor *brushColor;

@end