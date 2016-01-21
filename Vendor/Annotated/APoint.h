// wrapper for NSPoint
#import <Cocoa/Cocoa.h>

@interface APoint : NSObject {
  CGPoint point;
}
- (id)initWithCGPoint:(CGPoint)p;
- (CGPoint)getCGPoint;
- (float)x;
- (float)y;

@end