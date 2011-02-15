//
//  MainController.m
//  Captured
//
//  Created by Christopher Sexton on 1/13/11.
//  Copyright 2011 Codeography. All rights reserved.
//
#import "Imgur.h"

#import "StatusMenuController.h"
#import "CapturedAppDelegate.h"
#import "Utilities.h"

@implementation StatusMenuController
@synthesize lastUploadedURL;
@synthesize copyURLMenuItem;


-(void) setStatusIcon: (NSImage*)icon {
	// Seems that a crash occurs if you try to set the menu title from a thread other than the main thread.
	if ([NSThread isMainThread])
	{
		[statusItem setImage:icon];
	}
	else
	{
		[self performSelectorOnMainThread:@selector(setStatusIcon:) withObject:icon waitUntilDone:YES];
	}
}

-(void) setStatusNormal {
	[self setStatusIcon: statusIcon];
}
-(void) setStatusDisabled {
	[self setStatusIcon: statusIconDisabled];
}
-(void) setStatusProcessing {
	[self setStatusIcon: statusIconColor];
}
-(void) setStatusFailure {
	[self setStatusIcon: statusIconError];
}
-(void) setStatusSuccess: (NSString*)url {
	[self setStatusIcon: statusIconSuccess];
	self.lastUploadedURL = [NSString stringWithString:url];;
	[copyURLMenuItem setEnabled:YES];
	[Utilities copyToPasteboard:url];
	[self performSelector: @selector(setStatusNormal) withObject: nil afterDelay: 5.0];
}

-(void) awakeFromNib
{
	//ImgurController *controller = [[ImgurController alloc] init];

	//[controller parseResponseForURL:@""];
	
	//NSImage *image = [[NSImage alloc] initWithContentsOfFile: @"/Users/csexton/Desktop/horsehead-nebula.jpg"];
	
	//NSString *filename = @"/Users/csexton/Desktop/horsehead-nebula.jpg";
	
/*	
    NSString *filename = @"/Users/csexton/Desktop/screen.png";
    NSData *data;
    data = [NSData dataWithContentsOfFile: filename];
	ImgurController *controller = [[ImgurController alloc] init];
	[controller uploadImage:data];
*/
	
	statusIcon = [[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"StatusMenuIcon" ofType:@"png"]] retain];
	statusIconSuccess = [[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"StatusMenuIconSuccess" ofType:@"png"]] retain];
	statusIconColor = [[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"StatusMenuIconColor" ofType:@"png"]] retain];
	statusIconDisabled = [[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"StatusMenuIconDisabled" ofType:@"png"]] retain];
	statusIconError = [[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"StatusMenuIconError" ofType:@"png"]] retain];

	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
	[statusItem setMenu:statusMenu];
	//[statusItem setTitle:@"Status"];
	[statusItem setImage:statusIcon];
	[statusItem setHighlightMode:YES];
}


-(IBAction) quitItemAction:(id) sender
{
	NSLog(@"%@", @"Exiting");
	[[NSApplication sharedApplication] terminate:self];	
}

-(IBAction) copyURLItemAction:(id) sender
{
	[self setStatusSuccess:lastUploadedURL];
}

-(IBAction) openURLInBrowserAction:(id) sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:lastUploadedURL]];
}


- (BOOL)startAtLogin
{
    return [Utilities willStartAtLogin:[Utilities appURL]];
}

- (void)setStartAtLogin:(BOOL)enabled
{
    [self willChangeValueForKey:@"startAtLogin"];
    [Utilities setStartAtLogin:[Utilities appURL] enabled:enabled];
    [self didChangeValueForKey:@"startAtLogin"];
}

-(BOOL) isURLAvaliable
{
	if ([self.lastUploadedURL length] == 0) {
		return NO;
	} else {
		return YES;
	}
}

@end
