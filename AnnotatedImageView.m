
#import "AnnotatedImageView.h"
#import "APoint.h"

#import <math.h>

#define DEG2RAD(x)  ((x) * M_PI / 180.0)
#define RAD2DEG(x)  ((x) * 180 / M_PI)

static inline double radians (double degrees) {return degrees * M_PI/180;} // From Apple Docs

@implementation AnnotatedImageView

@synthesize useBrush;
@synthesize useArrow;


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

    return self;
}

- (void)awakeFromNib {
	colorSpace	= [self getRGBColorSpace];
	
    self.useBrush = NO;
    self.useArrow = NO;
}

- (CGColorSpaceRef) getRGBColorSpace  { 
    return CGColorSpaceCreateDeviceRGB();		
}

- (CGImageRef)nsImageToCGImageRef:(NSImage*)cgImage;
{
    NSData * imageData = [cgImage TIFFRepresentation];
    CGImageRef cgImageRef;
    if(imageData)
    {
        CGImageSourceRef imageSource =
        CGImageSourceCreateWithData((CFDataRef)imageData,  NULL);
        imageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
    }
    return cgImageRef;
}

- (IBAction)saveViewToDesktop:(id)sender
{
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Desktop/annotated.png"];    
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
    
    NSPoint l	= [self convertPoint:[event locationInWindow] fromView:nil];
    
    if (self.useArrow) {
        currentLocation	= l;
    }
    
    if (self.useBrush) {
        APoint * tvarAPointObj		= [[APoint alloc]initWithNSPoint:l];
        [arrayOfPoints addObject:tvarAPointObj];
        
        [self setNeedsDisplay:YES];
    }
    
    [self saveViewToDesktop: nil];
}

- (void)mouseDown:(NSEvent *)event{
    
    NSPoint locationInWindow = [event locationInWindow];
	NSPoint locationInView	= [self convertPoint:locationInWindow fromView:nil];
    NSPoint l = locationInView; // Not sure if this is view or window
    
    if (self.useArrow) {
        // For the arrow
        currentLocation	= l;
        downLocation =  l;
    }
    
    if (self.useBrush) {
        // For drawing the line
        arrayOfPoints	= [[NSMutableArray alloc]init];
        [arrayOfBrushStrokes addObject:arrayOfPoints];
        APoint * p	= [[APoint alloc]initWithNSPoint:l];
        [arrayOfPoints addObject:p];
    }
    
    
	[self setNeedsDisplay:YES];
}

-(void)mouseDragged:(NSEvent *)event {
    
    NSPoint l	= [self convertPoint:[event locationInWindow] fromView:nil];

    if (self.useArrow) {
        currentLocation = l;
    }
    
    if (self.useBrush) {
        APoint * p	= [[APoint alloc]initWithNSPoint:l];
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
    if ([arrayOfBrushStrokes count] == 0) { return; }

    CGContextSaveGState(context);

	NSUInteger tvarIntNumberOfStrokes	= [arrayOfBrushStrokes count];
    
	NSUInteger i;
	for (i = 0; i < tvarIntNumberOfStrokes; i++) {
        CGContextSetRGBStrokeColor(context,1.0,0.0,1.0,0.5);
		CGContextSetLineWidth(context, 3.0 );
        CGContextSetShadow(context, CGSizeMake(2, -2), 5);

		NSMutableArray * strokePts	= [arrayOfBrushStrokes objectAtIndex:i];
        
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
        CGContextDrawImage(context, CGRectMake (0.0, 0.0, rect.size.width, rect.size.height ), imageRef);
    //}
    
    if (self.useArrow) {
        [self drawArrowOn:context from:downLocation to:currentLocation];
    }
    
    if (self.useBrush) {
        [self drawBrushStrokesOn:context];
    }
	
}
//- (void)drawRect:(NSRect)rect {
//	
//	NSGraphicsContext	*	graphicsContext	= [NSGraphicsContext currentContext];
//	CGContextRef			context		= (CGContextRef) [graphicsContext graphicsPort];
//	
//	CGContextSetFillColorSpace(context,colorSpace);	
//	CGContextSetStrokeColorSpace(context,colorSpace);
//	
//	CGFloat zFillColour1[4]	= {0.98,0.9,0.88,1.0};
//	CGContextSetFillColor (context,zFillColour1);
//    CGContextFillRect (context, CGRectMake (0.0, 0.0, rect.size.width, rect.size.height ));
//    CGContextDrawImage(context, CGRectMake (0.0, 0.0, rect.size.width, rect.size.height ), [self getImage]);
//    
//    
//    
//    
//    
//    //    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
//    //    CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
//    //    CGContextSelectFont(context, "Helvetica", 12, kCGEncodingMacRoman);
//    //    //CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
//    //    CGContextSetTextDrawingMode(context, kCGTextFill);
//    //    char *str="Bunny";
//    //    //CGContextShowTextAtPoint(context,50.0,80.0,str,strlen(str));
//    //    CGContextShowTextAtPoint(context, clickLocation.x, clickLocation.y, str,strlen(str));
//	
//    //	CGContextBeginPath(context);
//    //	CGFloat strokeColour1[4]	= {0.0,0.0,1.0,1.0};
//    //	CGContextSetStrokeColor(context, strokeColour1);
//    //	CGContextSetLineWidth(context, 2.0);
//    //    CGContextAddArc (context, 50.0, 150.0, 10.0, 0.0, 2.0 * 3.142, YES);
//    //	CGContextDrawPath(context,kCGPathStroke);
//    //	
//    //	// another way of specifying the colour
//    //	CGContextSetRGBStrokeColor(context,0.0,0.0,0.6,1.0);
//    //	CGContextBeginPath(context);	
//    //	CGContextMoveToPoint(context,180.0,180.0);
//    //	CGContextAddCurveToPoint(context, 60.0, 180, 50.0, 170.0, 100.0, 100.0);
//    //	CGContextAddCurveToPoint(context, 130.0, 80.0, 120.0, 60.0, 80.0, 80.0);
//    //	CGContextDrawPath(context, kCGPathStroke);
//    //	
//    //	
//    //	CGContextBeginPath(context);	
//    //	CGContextMoveToPoint(context,170.0,150.0);
//    //	CGContextAddQuadCurveToPoint(context, 145.0, 110.0, 120.0, 150.0);
//    //	CGFloat strokeColour2[]	= {0.0, 0.0, 0.4, 1.0};
//    //	CGContextSetStrokeColor(context, strokeColour2);
//    //	CGContextDrawPath(context, kCGPathStroke);
//    //	
//    //	CGContextBeginPath(context);	
//    //	CGContextMoveToPoint(context,40.0,100.0);
//    //	CGContextAddQuadCurveToPoint(context, 30.0, 10.0, 170.0, 60.0);
//    //	CGFloat strokeColour3[]	= {1.0,0.0,0.0,1.0};
//    //	CGContextSetStrokeColor(context, strokeColour3);
//    //	CGContextSetLineWidth(context, 3.0);
//    //	CGContextDrawPath(context, kCGPathStroke);
//    
//    //    NSBezierPath* bPath = [NSBezierPath bezierPath];
//    //    [bPath moveToPoint:NSMakePoint(0.0, 0.0)];
//    //    [bPath lineToPoint:NSMakePoint(10.0, 10.0)];
//    //    [bPath lineToPoint:NSMakePoint(10.0, 0.0)];
//    //    [bPath setLineJoinStyle:NSRoundLineJoinStyle];
//    //    [bPath stroke];
//    //    
//    //     [NSBezierPath setDefaultLineCapStyle:NSButtLineCapStyle];
//    //     
//    //     // Customize the line cap style for the new object.
//    //     NSBezierPath* aPath = [NSBezierPath bezierPath];
//    //     [aPath moveToPoint:NSMakePoint(0.0, 0.0)];
//    //     [aPath lineToPoint:NSMakePoint(10.0, 10.0)];
//    //     [aPath setLineCapStyle:NSSquareLineCapStyle];
//    //     [aPath stroke];
//    
// 	//CGContextBeginPath(context);	
//	//CGContextMoveToPoint(context,40.0,100.0);
//	//CGContextAddQuadCurveToPoint(context, 30.0, 10.0, 170.0, 60.0);
//	CGFloat strokeColor[]	= {1.0,1.0,1.0,1.0};
//	CGContextSetStrokeColor(context, strokeColor);
//	CGContextSetLineWidth(context, 3.0);
//    [NSBezierPath setDefaultLineCapStyle:NSButtLineCapStyle];
//    [NSBezierPath setDefaultLineJoinStyle:NSRoundLineJoinStyle];
//    //CGColorRef fillColor = CGColorCreateGenericRGB(0.986,0.419,1.0,1.0);
//    CGColorRef fillColor = CGColorCreateGenericRGB(1.0,0.6,0.0,1.0);
//    
//    CGContextSetFillColorWithColor( context, fillColor);
//    
//    
//    
//    //	//CGContextDrawPath(context, kCGPathStroke);roke
//    //    NSBezierPath* aPath = [NSBezierPath bezierPath];
//    //    [aPath moveToPoint:NSMakePoint(0.0, 97.0)];
//    //    [aPath lineToPoint:NSMakePoint(100.0, 90.0)];
//    //    [aPath lineToPoint:NSMakePoint(100.0, 80.0)];
//    //    [aPath lineToPoint:NSMakePoint(120.0, 100.0)];
//    //    [aPath lineToPoint:NSMakePoint(100.0, 120.0)];
//    //    [aPath lineToPoint:NSMakePoint(100.0, 110.0)];
//    //    [aPath lineToPoint:NSMakePoint(0.0, 103.0)];
//    //    [aPath moveToPoint:NSMakePoint(0.0, 97.0)];
//    //    [aPath setLineCapStyle:NSSquareLineCapStyle];
//    //    [aPath stroke];
//    //    
//    
//    
//    CGFloat theta = [self angleForPoint:clickLocation withOrigin:downLocation];
//    
//    CGContextSaveGState(context);
//    CGContextTranslateCTM(context, downLocation.x, downLocation.y);
//    CGContextRotateCTM (context, theta);
//    
//    
//    //    //Draw and arrow at an angle
//    //    //CGContextTranslateCTM(context, 50.0, 50.0);
//    //    //CGContextRotateCTM (context, radians(-45.));
//    //    
//    //    CGPoint addLines[] =
//    //    {
//    ////        CGPointMake(0.0, 97.0),
//    ////        CGPointMake(100.0, 90.0),
//    ////        CGPointMake(100.0, 80.0),
//    ////        CGPointMake(120.0, 100.0),
//    ////        CGPointMake(100.0, 120.0),
//    ////        CGPointMake(100.0, 110.0),
//    ////        CGPointMake(0.0, 103.0),
//    ////        CGPointMake(0.0, 97.0)
//    //        
//    //        
//    //        
//    //        CGPointMake(-120.0, -3.0),
//    //        CGPointMake(-20.0, -10.0),
//    //        CGPointMake(-20.0, -20.0),
//    //        CGPointMake(0.0, 0.0),
//    //        CGPointMake(-20.0, 20.0),
//    //        CGPointMake(-20.0, 10.0),
//    //        CGPointMake(-120.0, 3.0),
//    //        CGPointMake(-120.0, -3.0)
//    //
//    //    };
//    //    CGContextAddLines(context, addLines, sizeof(addLines)/sizeof(addLines[0]));
//    //    
//    
//    
//    CGFloat d = [self distanceBetween: downLocation and: clickLocation];
//    [self drawArrowWithLength:d];
//    
//    
//    //    CGContextClosePath(context);   
//    //    CGContextStrokePath(context);
//    //    CGContextFillPath(context);
//    
//    
//    CGContextRestoreGState(context);
//    
//    
//    
//    
//    //    NSPoint arrowLoc = clickLocation;
//    //    arrowLoc.x = arrowLoc.x-120;
//    //    arrowLoc.y = arrowLoc.y-100;
//    //    
//    //    CGPoint addLines[] =
//    //    {
//    //        CGPointMake(0.0 + arrowLoc.x, 97.0 + arrowLoc.y),
//    //        CGPointMake(100.0 + arrowLoc.x, 90.0 + arrowLoc.y),
//    //        CGPointMake(100.0 + arrowLoc.x, 80.0 + arrowLoc.y),
//    //        CGPointMake(120.0 + arrowLoc.x, 100.0 + arrowLoc.y),
//    //        CGPointMake(100.0 + arrowLoc.x, 120.0 + arrowLoc.y),
//    //        CGPointMake(100.0 + arrowLoc.x, 110.0 + arrowLoc.y),
//    //        CGPointMake(0.0 + arrowLoc.x, 103.0 + arrowLoc.y),
//    //        CGPointMake(0.0 + arrowLoc.x, 97.0 + arrowLoc.y)
//    //    };
//    //
//    //    // Bulk call to add lines to the current path.
//    //    // Equivalent to MoveToPoint(points[0]); for(i=1; i<count; ++i) AddLineToPoint(points[i]);
//    //    CGContextAddLines(context, addLines, sizeof(addLines)/sizeof(addLines[0]));
//    //    CGContextClosePath(context);
//    
//    
//    // calculate slope
//    //    CGFloat m = 0.0;
//    //    if (clickLocation.x != downLocation.y) {
//    //      m = (clickLocation.y - downLocation.y)/(clickLocation.x - downLocation.x);
//    //    }
//    //    
//    //    NSLog(@"click %f", m);
//    //    NSLog(@"cosine %.f", cos(m));
//    
//    
//    
//    // Draw user line
//    //    CGContextMoveToPoint(context, downLocation.x, downLocation.y);
//    //    CGContextAddLineToPoint(context, clickLocation.x, clickLocation.y);
//    //    CGContextStrokePath(context);
//    
//    // Calculate angle for line at origin
//    //    CGPoint origin;
//    //    origin.x = 0;
//    //    origin.y = 0;
//    //    CGPoint end;
//    //    end.x = 100;
//    //    end.y = 0;
//    //    CGFloat theta2 = [self angleForPoint:clickLocation withOrigin:origin];
//    //    CGPoint rot = [self rotate:end by:theta2];
//    //        
//    
//    //Rotation  
//    //    CGFloat strokeColour4[]	= {0.6,0.6,0.0,1.0};
//    //	CGContextSetStrokeColor(context, strokeColour4);
//    //	CGContextSetLineWidth(context, 3.0);
//    //    
//    //
//    //    
//    //    
//    //    //Try to calculate the new line by rotating the point to the click location
//    //    CGPoint rot = [self rotatePoint:clickLocation to:clickLocation around:downLocation];
//    //    CGContextRotateCTM (context, M_PI/4);
//    //    
//    //     CGContextSetTextMatrix(context, CGAffineTransformMakeRotation( -M_PI/4 ));
//    //    
//    //    
//    //    
//    //    CGContextMoveToPoint(context, downLocation.x, downLocation.y);
//    //    CGContextAddLineToPoint(context, rot.x, rot.y);
//    //    CGContextStrokePath(context);
//    
//    
//    
//	
//}
//
//



@end
