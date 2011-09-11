//
//  AnnotatedImageController.m
//  Captured
//
//  Created by Christopher Sexton on 9/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AnnotatedImageController.h"

@implementation AnnotatedImageController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)windowWillClose
{
    // TODO: Clean up memory
    // http://www.cocoabuilder.com/archive/cocoa/304428-release-nswindowcontroller-after-the-window-is-closed.html
    
    // I don't think works at all
    [self autorelease];
}

- (void)setImage:(NSImage*) image {
    
    
    CGFloat originalX = annotateImageView.frame.origin.x;
    CGFloat originalY = annotateImageView.frame.origin.y;
    CGFloat originalWidth = annotateImageView.frame.size.width;
    CGFloat originalHeight = annotateImageView.frame.size.height;
    
    NSLog(@"orgx: %f orgy: %f", originalX, originalY);
    NSLog(@"orgw: %f orgh: %f", originalWidth, originalHeight);
    
    NSLog(@"Image Size: w: %f h: %f", image.size.width, image.size.height);
    
    CGFloat topY = originalY+100.f; // The view is 100 px tall in the nib
    
    topY = image.size.height-100+originalY;
    

    NSRect f = NSMakeRect(55, 55, image.size.width+55, image.size.height+55);
        
    NSRect frame = [self.window frame];
    float delta = image.size.height - frame.size.height;
    //frame.origin.y -= delta;
    frame.size.height = image.size.height + 100;
    frame.size.width = image.size.width + 55;
    

    [self.window setFrame: frame
             display: YES
             animate: NO];
    [self.window center];

    
    
    //[self.window setFrameOrigin:NSMakePoint(900, 900)];
    
    
    [annotateImageView setFrame: f];
    
    [annotateImageView setImage:image];
    //[self showWindow:nil];
    
}


-(IBAction)useArrow:(id)sender{
    annotateImageView.useArrow = YES;
    annotateImageView.useBrush = NO;
}

-(IBAction)useBrush:(id)sender{
    annotateImageView.useArrow = NO;
    annotateImageView.useBrush = YES;
}

@end
