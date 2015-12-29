//
//  AArrow.h
//  Captured
//
//  Created by Christopher Sexton on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ADrawable.h"

@interface AArrow : ADrawable {
  CGPoint p1;
  CGPoint p2;
}

- (CGFloat)distanceBetweenPoint:(CGPoint)p1 and:(CGPoint)p2;
- (CGFloat)angleBetweenPoint:(CGPoint)p and:(CGPoint)o;

@end