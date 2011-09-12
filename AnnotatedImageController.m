//
//  AnnotatedImageController.m
//  Captured
//
//  Created by Christopher Sexton on 9/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AnnotatedImageController.h"
#import "CapturedAppDelegate.h"


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
    
    [self.window setBackgroundColor:[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:0.7]];
}

- (void)windowWillClose
{
    // TODO: Clean up memory
    // http://www.cocoabuilder.com/archive/cocoa/304428-release-nswindowcontroller-after-the-window-is-closed.html
    
    // I don't think works at all
    [self autorelease];
}

- (void)keyDown:(NSEvent *)event {
    [self interpretKeyEvents:[NSArray arrayWithObject:event]];
    NSLog(@"Event %@", event);
    if ([event keyCode] == 36) {
        [self closeButton:nil];
    }
}

- (void)setImage:(NSImage*) image {
    
    
    CGFloat originalX = annotateImageView.frame.origin.x;
    CGFloat originalY = annotateImageView.frame.origin.y;
//    CGFloat originalWidth = annotateImageView.frame.size.width;
//    CGFloat originalHeight = annotateImageView.frame.size.height;

    NSRect f = NSMakeRect(0, /* Button Bar Height */ 55, image.size.width, image.size.height + /* Button Bar Height */ 55);
        
    NSRect frame = [self.window frame];
    frame.size.height = image.size.height + /* Button Bar Height */ 55 + /* Window Frame (70 for full title bar) */ 55;
    frame.size.width = image.size.width;
    
    [self.window setFrame: frame display: YES animate: NO];
    [self.window center];

    [annotateImageView setFrame: f];
    
    [annotateImageView setImage:image];
    //[self showWindow:nil];
    [[self window] makeKeyAndOrderFront:self];

    
}


-(IBAction)useArrow:(id)sender{
    annotateImageView.useArrow = YES;
    annotateImageView.useBrush = NO;
}

-(IBAction)useBrush:(id)sender{
    annotateImageView.useArrow = NO;
    annotateImageView.useBrush = YES;
}

-(IBAction)closeButton:(id)sender{
    [self close];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd-HH-mm-ss-SSSSSS"];
	NSDate *now = [[NSDate alloc] init];
	NSString *timestamp = [dateFormat stringFromDate:now];
    [dateFormat release];
    [now release];
    NSString* path = [NSString stringWithFormat:@"%@captured-%@.png", NSTemporaryDirectory(), timestamp];
    
    NSLog(@"Saving Annotated Image to %@", path);
    
    [annotateImageView saveViewToFile:path];
    
    [AppDelegate processFileEvent:path];
    

     //[self.window orderOut:nil]; // to hide it
     //[window makeKeyAndOrderFront:nil]; // to show it
}

@end
