//
//  WelcomeWindowController.m
//  Captured
//
//  Created by Christopher Sexton on 2/10/11.
//  Copyright 2011 Christopher Sexton. All rights reserved.
//

#import "WelcomeWindowController.h"

#import "NSButton+TextColor.h"
#import "Utilities.h"
#import "CapturedAppDelegate.h"



@implementation WelcomeWindowController
@synthesize window;
@synthesize startCheckBox;


- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
        
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

-(void) awakeFromNib
{
    //[window setBackgroundColor:[NSColor orangeColor]];
    //NSImage *theImage = [NSImage imageNamed:@"background"];
    NSImage *theImage = [[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"WelcomeWindowBackground" ofType:@"png"]] retain];
    
    NSColor *theColor = [NSColor colorWithPatternImage:theImage];
    [window setBackgroundColor:theColor];
    [startCheckBox setTextColor:[NSColor colorWithDeviceRed:1.0f green:1.0f blue:1.0f alpha:0.8f]];
}

-(IBAction) closeWindowAction:(id) sender
{
    //[[window animator] setAlphaValue:0.0];
    [window close];
}

- (BOOL)startAtLogin
{
    return [[AppDelegate valueForKey:@"startAtLogin"] boolValue] ;
}

- (void)setStartAtLogin:(BOOL)enabled
{
    [self willChangeValueForKey:@"startAtLogin"];
    CapturedAppDelegate *cap = [[NSApplication sharedApplication] delegate];
    cap.startAtLogin = enabled;
    [self didChangeValueForKey:@"startAtLogin"];
}

@end
