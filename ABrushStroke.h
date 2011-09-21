//
//  ABrushStroke.h
//  Captured
//
//  Created by Christopher Sexton on 9/21/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABrushStroke : NSObject {
    NSMutableArray * points;
    NSColor *color;
}

@property (readwrite, retain) NSMutableArray *points;
@property (readwrite, retain) NSColor *color;

-(void)drawOn:(CGContextRef)context;



@end
