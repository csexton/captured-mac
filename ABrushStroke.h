//
//  ABrushStroke.h
//  Captured
//
//  Created by Christopher Sexton on 9/21/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADrawable.h"

@interface ABrushStroke : ADrawable {
    NSMutableArray * points;
    NSColor *color;
    CGFloat width;
}

-(id)initWithColor:(NSColor*)c andWidth: (CGFloat)w;
-(void)addPoint: (CGPoint)point;



@end
