#import "APoint.h"

@implementation APoint

- (id) initWithNSPoint:(NSPoint)p {
	if ((self = [super init]) == nil) {
		return self;
	} // end if
	point.x	= p.x;
	point.y	= p.y;
    
    return self;
}

- (NSPoint) getNSPoint {
	return point;
}

- (float)x {
	return point.x;
}

- (float)y {
	return point.y;
} // end y





@end
