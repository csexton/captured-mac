// wrapper for NSPoint
#import <Cocoa/Cocoa.h>

@interface APoint : NSObject {
	NSPoint point;
}
- (id) initWithNSPoint:(NSPoint)p;
- (NSPoint) getNSPoint;
- (float)x;
- (float)y;

@end
