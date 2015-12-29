//
//  GradientView.m
//  Captured
//
//  Created by Christopher Sexton on 9/20/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import "GradientView.h"

@implementation GradientView

- (id)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code here.
  }
  return self;
}

//- (void)drawRect:(NSRect)rect {
//    NSGraphicsContext* graphicsContext = [NSGraphicsContext currentContext];
//	CGContextRef context = (CGContextRef) [graphicsContext graphicsPort];
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//
//	CGContextSetFillColorSpace(context,colorSpace);
//	CGContextSetStrokeColorSpace(context,colorSpace);
//
//    CGGradientRef glossGradient;
//    size_t num_locations = 2;
//    CGFloat locations[2] = { 0.0, 1.0 };
//    CGFloat components[8] = { 0.65625, 0.65625, 0.65625, 1.0,  // Start color
//        0.78515625, 0.78515625, 0.78515625, 1.0 }; // End color
//
//    glossGradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, num_locations);
//
//    CGRect currentBounds =  NSRectToCGRect(self.bounds);
//    CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
////    CGPoint midCenter = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMidY(currentBounds));
//    CGPoint midCenter = CGPointMake(CGRectGetMidX(currentBounds), currentBounds.size.height);
////    CGContextDrawLinearGradient(context, glossGradient, topCenter, midCenter, 0);
//    CGContextDrawLinearGradient(context, glossGradient, topCenter, midCenter, 0);
//
//    CGGradientRelease(glossGradient);
//    CGColorSpaceRelease(colorSpace);
//}

@end