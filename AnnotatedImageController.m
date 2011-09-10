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
    [annotateImageView setImage:image];
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
