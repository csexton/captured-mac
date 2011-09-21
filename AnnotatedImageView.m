
#import "AnnotatedImageView.h"
#import "APoint.h"
#import "ABrushStroke.h"

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

- (CGPoint)rotate:(CGPoint) p by:(CGFloat) theta {
    CGPoint ret;
    ret.x = (p.x * cos(theta)) - (p.y * sin(theta));
    ret.y = (p.y * cos(theta)) + (p.x * sin(theta));
    return ret;
}

- (CGFloat) angleBetweenPoint: (CGPoint)p and: (CGPoint)o {
    CGFloat ret = atan2(p.y - o.y, p.x - o.x);
    return ret;
}

- (CGPoint) rotatePoint: (CGPoint)p to: (CGPoint)d around: (CGPoint)o {
    CGFloat theta = [self angleBetweenPoint:d and:o];
    return [self rotate:p by:theta];
}

- (CGFloat) distanceBetweenPoint: (CGPoint)p1 and: (CGPoint) p2 {
    CGFloat xDist = (p2.x - p1.x);
    CGFloat yDist = (p2.y - p1.y);
    return sqrt((xDist * xDist) + (yDist * yDist));
}

- (id)initWithFrame:(NSRect)frame {
    if ( !(self = [super initWithFrame:frame]) ) {
		return self;
	}
    
    arrayOfBrushStrokes	= [[NSMutableArray alloc]init];
    arrayOfHighlighterStrokes	= [[NSMutableArray alloc]init];
    brushColor = [NSColor redColor];

    return self;
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
    
    if (self.useArrow) {
        currentLocation	= l;
    }
    
    if (self.useBrush) {
        APoint * tvarAPointObj		= [[APoint alloc]initWithCGPoint:l];
        [currentStroke.points addObject:tvarAPointObj];

    }
    if (self.useHighlighter) {
        APoint * tvarAPointObj		= [[APoint alloc]initWithCGPoint:l];
        [arrayOfPoints addObject:tvarAPointObj];
        
    }
    [self setNeedsDisplay:YES];

}

- (void)mouseDown:(NSEvent *)event{
    
    CGPoint l	= NSPointToCGPoint([self convertPoint:[event locationInWindow] fromView:nil]);
    
    if (self.useArrow) {
        // For the arrow
        currentLocation	= l;
        downLocation =  l;
    }
    
    if (self.useBrush) {
        // For drawing the line
        currentStroke = [[ABrushStroke alloc]init];
        currentStroke.color = brushColor;
        [arrayOfBrushStrokes addObject:currentStroke];
        APoint * p	= [[APoint alloc]initWithCGPoint:l];
        [currentStroke.points addObject:p];
    }
    if (self.useHighlighter) {
        // For drawing the line
        arrayOfPoints	= [[NSMutableArray alloc]init];
        [arrayOfHighlighterStrokes addObject:arrayOfPoints];
        APoint * p	= [[APoint alloc]initWithCGPoint:l];
        [arrayOfPoints addObject:p];
    }
    
    
	[self setNeedsDisplay:YES];
}

-(void)mouseDragged:(NSEvent *)event {
    
    CGPoint l	= NSPointToCGPoint([self convertPoint:[event locationInWindow] fromView:nil]);

    if (self.useArrow) {
        currentLocation = l;
    }
    
    if (self.useBrush) {
        APoint * p	= [[APoint alloc]initWithCGPoint:l];
        [currentStroke.points addObject:p];
    }
    
    if (self.useHighlighter) {
        APoint * p	= [[APoint alloc]initWithCGPoint:l];
        [arrayOfPoints addObject:p];
    }
    
    
	[self setNeedsDisplay:YES];
}


- (void)drawArrowOn:(CGContextRef)context from:(CGPoint)p1 to:(CGPoint)p2 {
  
	CGFloat strokeColor[]	= {1.0,1.0,1.0,1.0};
    CGColorRef fillColor = CGColorCreateGenericRGB(0.986,0.419,1.0,1.0);

	CGContextSetStrokeColor(context, strokeColor);
	CGContextSetLineWidth(context, 3.0);
    [NSBezierPath setDefaultLineCapStyle:NSButtLineCapStyle];
    [NSBezierPath setDefaultLineJoinStyle:NSRoundLineJoinStyle];
    //CGColorRef fillColor = CGColorCreateGenericRGB(1.0,0.6,0.0,1.0);
    CGContextSetFillColorWithColor( context, fillColor);
    
    
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
    
    NSColor *startingColor = [[NSColor colorWithCalibratedRed:0.986 green:0.419 blue:1.0 alpha:1.000] retain];
	NSColor *endColor = [[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:1.000] retain];
	NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:startingColor endingColor:endColor];
    
    [gradient drawInBezierPath:bezierPath angle:-90];    
    CGContextRestoreGState(context);
}

-(void)drawBrushStrokesOn:(CGContextRef)context {
    for (id s in arrayOfBrushStrokes) {
        [s drawOn: context];
    }
}

-(void)drawHighlighterStrokesOn:(CGContextRef)context {
    if ([arrayOfHighlighterStrokes count] == 0) { return; }
    
    CGContextSaveGState(context);
    
	NSUInteger tvarIntNumberOfStrokes	= [arrayOfHighlighterStrokes count];
    
	NSUInteger i;
	for (i = 0; i < tvarIntNumberOfStrokes; i++) {
        CGContextSetRGBStrokeColor(context,1.0,1.0,0.0,0.5);
		CGContextSetLineWidth(context, 12.0 );
        CGContextSetLineJoin(context, NSRoundLineJoinStyle);
        CGContextSetLineCap(context, NSRoundLineCapStyle);

        //CGContextSetShadow(context, CGSizeMake(2, -2), 5);
        
		NSMutableArray * strokePts	= [arrayOfHighlighterStrokes objectAtIndex:i];
        
		NSUInteger tvarIntNumberOfPoints	= [strokePts count];				// always >= 2
		APoint * tvarLastPointObj			= [strokePts objectAtIndex:0];
		CGContextBeginPath(context);
		CGContextMoveToPoint(context,[tvarLastPointObj x],[tvarLastPointObj y]);
        
		NSUInteger j;
		for (j = 1; j < tvarIntNumberOfPoints; j++) {  // note the index starts at 1
			APoint * tvarCurPointObj			= [strokePts objectAtIndex:j];
			CGContextAddLineToPoint(context,[tvarCurPointObj x],[tvarCurPointObj y]);
		}
		CGContextDrawPath(context,kCGPathStroke);
	}
    CGContextRestoreGState(context);
}

- (void)drawRect:(NSRect)rect {
	
	NSGraphicsContext* graphicsContext = [NSGraphicsContext currentContext];
	CGContextRef context = (CGContextRef) [graphicsContext graphicsPort];
	
	CGContextSetFillColorSpace(context,colorSpace);	
	CGContextSetStrokeColorSpace(context,colorSpace);
    
    CGFloat fillColor[4] = {0.0,0.0,0.0,1.0};
	CGContextSetFillColor(context,fillColor);
    CGContextFillRect(context, CGRectMake (0.0, 0.0, rect.size.width, rect.size.height ));
    //if (imageRef) {
        
    if (image) {
        CGContextDrawImage(context, CGRectMake (0.0, 0.0, rect.size.width, rect.size.height ), imageRef);
    }

    [self drawArrowOn:context from:downLocation to:currentLocation];
    [self drawBrushStrokesOn:context];
    [self drawHighlighterStrokesOn:context];

}

@end
