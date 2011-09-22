
#import "AnnotatedImageView.h"
#import "APoint.h"
#import "ABrushStroke.h"
#import "AArrow.h"

#import <math.h>

#define DEG2RAD(x)  ((x) * M_PI / 180.0)
#define RAD2DEG(x)  ((x) * 180 / M_PI)

static inline double radians (double degrees) {return degrees * M_PI/180;} // From Apple Docs

@implementation AnnotatedImageView

@synthesize useBrush;
@synthesize useHighlighter;
@synthesize useArrow;
@synthesize brushColor;



- (void)setImage:(NSImage *)i {
    image = i;
    imageRef = [self nsImageToCGImageRef:i];

    [self setNeedsDisplay:YES];    
}

//- (CGPoint)rotate:(CGPoint) p by:(CGFloat) theta {
//    CGPoint ret;
//    ret.x = (p.x * cos(theta)) - (p.y * sin(theta));
//    ret.y = (p.y * cos(theta)) + (p.x * sin(theta));
//    return ret;
//}
//
//- (CGFloat) angleBetweenPoint: (CGPoint)p and: (CGPoint)o {
//    CGFloat ret = atan2(p.y - o.y, p.x - o.x);
//    return ret;
//}
//
//- (CGPoint) rotatePoint: (CGPoint)p to: (CGPoint)d around: (CGPoint)o {
//    CGFloat theta = [self angleBetweenPoint:d and:o];
//    return [self rotate:p by:theta];
//}
//
//- (CGFloat) distanceBetweenPoint: (CGPoint)p1 and: (CGPoint) p2 {
//    CGFloat xDist = (p2.x - p1.x);
//    CGFloat yDist = (p2.y - p1.y);
//    return sqrt((xDist * xDist) + (yDist * yDist));
//}

- (id)initWithFrame:(NSRect)frame {
    if ( !(self = [super initWithFrame:frame]) ) {
		return self;
	}
    
    arrayOfBrushStrokes	= [[NSMutableArray alloc]init];
    brushColor = [NSColor redColor];

    return self;
}

- (void) dealloc
{
    [brushColor release];
    [super dealloc];
}

- (void)awakeFromNib {
	colorSpace	= [self getRGBColorSpace];
	
    self.useBrush = NO;
    self.useHighlighter = NO;
    self.useArrow = NO;
}

- (CGColorSpaceRef) getRGBColorSpace  { 
    return CGColorSpaceCreateDeviceRGB();		
}

- (CGImageRef)nsImageToCGImageRef:(NSImage*)nsImage;
{
    NSData * imageData = [nsImage TIFFRepresentation];
    CGImageRef cgImageRef;
    if(imageData)
    {
        CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)imageData,  NULL);
        cgImageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
    }
    return cgImageRef;
}

- (void)saveViewToFile:(NSString *) path
{
    //NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Desktop/annotated.png"];    
    [self lockFocus];
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:[self bounds]];
    [self unlockFocus];    
    NSData *data = [rep representationUsingType:(NSBitmapImageFileType) NSPNGFileType
                             properties:(NSDictionary *)nil];
    
    [data writeToFile:path atomically:YES];
}

- (void)mouseUp:(NSEvent *)event {
    
//	NSPoint mousePointInView	= [self convertPoint:tvarMousePointInWindow fromView:nil];
//	APoint * APointObj		= [[APoint alloc]initWithNSPoint:mousePointInView];
//    
//    NsPoint *fontLocation = [NSpoint all
//	
//	[myMutaryOfPoints addObject:APointObj];	
    
    CGPoint l	= NSPointToCGPoint([self convertPoint:[event locationInWindow] fromView:nil]);
    
    if (self.useArrow || self.useBrush || self.useHighlighter) {
        [currentStroke mouseUpAt: l];
    }

    [self setNeedsDisplay:YES];

}

- (void)mouseDown:(NSEvent *)event{
    
    CGPoint l	= NSPointToCGPoint([self convertPoint:[event locationInWindow] fromView:nil]);
    
    if (self.useArrow) {
        currentStroke = [[AArrow alloc] init];
        [currentStroke mouseDownAt:l];
        [currentStroke mouseDragAt:l];
        [arrayOfBrushStrokes addObject:currentStroke];
    }
    
    if (self.useBrush || self.useHighlighter) {
        if (self.useHighlighter) {
            // A highlighter is just a brush stroke with a specific size and color
            currentStroke = [[ABrushStroke alloc] initWithColor:[NSColor colorWithDeviceRed:1.0 green:1.0 blue:0.0 alpha:0.5] 
                                                       andWidth:12.0];
            
        } else {
            currentStroke = [[ABrushStroke alloc] initWithColor:brushColor 
                                                       andWidth:3.0];
        }
        [arrayOfBrushStrokes addObject:currentStroke];
        [currentStroke mouseDownAt:l];
    }
    [[self undoManager] registerUndoWithTarget:self 
                                      selector:@selector(undoDraw:) 
                                        object:currentStroke];    
	[self setNeedsDisplay:YES];
}

-(void)mouseDragged:(NSEvent *)event {
    
    CGPoint l	= NSPointToCGPoint([self convertPoint:[event locationInWindow] fromView:nil]);
    
    if (self.useArrow || self.useBrush || self.useHighlighter) {
        [currentStroke mouseDragAt:l];
    }

	[self setNeedsDisplay:YES];
}

-(void)undoDraw {
    [arrayOfBrushStrokes removeLastObject];
    [self setNeedsDisplay:YES];
}

-(void)drawBrushStrokesOn:(CGContextRef)context {
    for (id s in arrayOfBrushStrokes) {
        [s drawOn: context];
    }
}

- (void)drawRect:(NSRect)rect {
	
	NSGraphicsContext* graphicsContext = [NSGraphicsContext currentContext];
	CGContextRef context = (CGContextRef) [graphicsContext graphicsPort];
	
	CGContextSetFillColorSpace(context,colorSpace);	
	CGContextSetStrokeColorSpace(context,colorSpace);
    
    CGFloat fillColor[4] = {0.0,0.0,0.0,1.0};
	CGContextSetFillColor(context,fillColor);
    CGContextFillRect(context, CGRectMake (0.0, 0.0, rect.size.width, rect.size.height ));
        
    if (image) {
        CGContextDrawImage(context, CGRectMake (0.0, 0.0, rect.size.width, rect.size.height ), imageRef);
    }

    //[self drawArrowOn:context from:downLocation to:currentLocation];
    [self drawBrushStrokesOn:context];
}

@end
