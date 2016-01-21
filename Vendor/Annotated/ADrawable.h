//
//  ADrawable.h
//  Captured
//
//  Created by Christopher Sexton on 9/21/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADrawable : NSObject

- (void)drawOn:(CGContextRef)context;
- (void)mouseDownAt:(CGPoint)point;
- (void)mouseDragAt:(CGPoint)point;
- (void)mouseUpAt:(CGPoint)point;

@end