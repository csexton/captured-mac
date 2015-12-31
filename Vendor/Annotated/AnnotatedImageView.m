#import "AnnotatedImageView.h"
#import "APoint.h"
#import "ABrushStroke.h"
#import "AArrow.h"

#import <math.h>


@implementation AnnotatedImageView

#pragma mark -
#pragma mark Getters and Setters
@synthesize brushColor;


#pragma mark -
#pragma mark Drawing Tool Selector
- (void)selectBrushTool {
  useBrush = YES;
  useArrow = NO;
  useHighlighter = NO;
  [self discardCursorRects];
  [self resetCursorRects];
}

- (void)selectHighlighterTool {
  useHighlighter = YES;
  useBrush = NO;
  useArrow = NO;
  [self discardCursorRects];
  [self resetCursorRects];
}

- (void)selectArrowTool {
  useArrow = YES;
  useBrush = NO;
  useHighlighter = NO;
  [self discardCursorRects];
  [self resetCursorRects];
}

- (id)initWithFrame:(NSRect)frame {
  if (!(self = [super initWithFrame:frame])) {
    return self;
  }
  arrayOfBrushStrokes = [[NSMutableArray alloc]init];
  brushColor = [NSColor redColor];


  return self;
}

- (void)setImage:(NSImage *)i {
  image = i;
  imageRef = [self nsImageToCGImageRef:i];

  [self setNeedsDisplay:YES];
}

- (void)awakeFromNib {
  colorSpace  =  CGColorSpaceCreateDeviceRGB();

  useBrush = NO;
  useHighlighter = NO;
  useArrow = NO;
  NSImage *i = [NSImage imageNamed:@"BrushCursor"];
  pencilCursor = [[NSCursor alloc] initWithImage:i
                                         hotSpot:NSMakePoint(0.0, 15.0)];

  NSImage *j = [NSImage imageNamed:@"HighlighterCursor"];
  highlighterCursor = [[NSCursor alloc] initWithImage:j
                                              hotSpot:NSMakePoint(0.0, 10.0)];
}

- (CGImageRef)nsImageToCGImageRef:(NSImage *)nsImage;
{
  NSData *imageData = [nsImage TIFFRepresentation];
  CGImageRef cgImageRef = nil;
  if (imageData) {
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)imageData,  NULL);
    cgImageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
    CFRelease(imageSource);
  }
  return cgImageRef;
}

- (void)saveViewToFile:(NSString *)path {
  [self lockFocus];
  NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:[self bounds]];
  [self unlockFocus];
  NSData *data = [rep representationUsingType:(NSBitmapImageFileType)NSPNGFileType
                                   properties:(NSDictionary *)nil];

  [data writeToFile:path
         atomically:YES];
}

- (void)mouseUp:(NSEvent *)event {
//	NSPoint mousePointInView	= [self convertPoint:tvarMousePointInWindow fromView:nil];
//	APoint * APointObj		= [[APoint alloc]initWithNSPoint:mousePointInView];
//
//    NsPoint *fontLocation = [NSpoint all
//
//	[myMutaryOfPoints addObject:APointObj];

  CGPoint l = NSPointToCGPoint([self convertPoint:[event locationInWindow]
                                         fromView:nil]);

  if (useArrow || useBrush || useHighlighter) {
    [currentStroke mouseUpAt:l];
  }
  [self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)event {
  CGPoint l = NSPointToCGPoint([self convertPoint:[event locationInWindow]
                                         fromView:nil]);

  if (useArrow) {
    currentStroke = [[AArrow alloc] init];
    [currentStroke mouseDownAt:l];
    [currentStroke mouseDragAt:l];
    [arrayOfBrushStrokes addObject:currentStroke];
  }
  if (useBrush || useHighlighter) {
    if (useHighlighter) {
      // A highlighter is just a brush stroke with a specific size and color
      currentStroke = [[ABrushStroke alloc] initWithColor:[NSColor colorWithDeviceRed:1.0
                                                                                green:0.9
                                                                                 blue:0.0
                                                                                alpha:0.3]
                                                 andWidth:12.0];
    } else {
      currentStroke = [[ABrushStroke alloc] initWithColor:brushColor
                                                 andWidth:3.0];
    }
    [arrayOfBrushStrokes addObject:currentStroke];
    [currentStroke mouseDownAt:l];
  }
  SEL selector = NSSelectorFromString(@"undoDraw:");
  [[self undoManager] registerUndoWithTarget:self
                                    selector:selector
                                      object:currentStroke];
  [self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)event {
  CGPoint l = NSPointToCGPoint([self convertPoint:[event locationInWindow]
                                         fromView:nil]);

  if (useArrow || useBrush || useHighlighter) {
    [currentStroke mouseDragAt:l];
  }
  [self setNeedsDisplay:YES];
}

- (void)resetCursorRects {
  [super resetCursorRects];
  if (useArrow) {
    [self addCursorRect:[self bounds]
                 cursor:[NSCursor crosshairCursor]];
  } else if (useHighlighter) {
    [self addCursorRect:[self bounds]
                 cursor:highlighterCursor];
  } else {
    [self addCursorRect:[self bounds]
                 cursor:pencilCursor];
  }
}

- (void)undoDraw {
  [arrayOfBrushStrokes removeLastObject];
  [self setNeedsDisplay:YES];
}

- (void)drawBrushStrokesOn:(CGContextRef)context {
  for (id s in arrayOfBrushStrokes) {
    [s drawOn:context];
  }
}

- (void)drawRect:(NSRect)rect {
  NSGraphicsContext *graphicsContext = [NSGraphicsContext currentContext];
  CGContextRef context = (CGContextRef)[graphicsContext graphicsPort];

  CGContextSetFillColorSpace(context, colorSpace);
  CGContextSetStrokeColorSpace(context, colorSpace);

  CGFloat fillColor[4] = { 0.0, 0.0, 0.0, 1.0 };
  CGContextSetFillColor(context, fillColor);
  CGContextFillRect(context, CGRectMake(0.0, 0.0, rect.size.width, rect.size.height));

  if (image) {
    CGContextDrawImage(context, CGRectMake(0.0, 0.0, rect.size.width, rect.size.height), imageRef);
  }
  [self drawBrushStrokesOn:context];
}

@end