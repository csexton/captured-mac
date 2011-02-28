//
//  MainController.m
//  Captured
//
//  Created by Christopher Sexton on 1/13/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import <Growl/Growl.h>
#import "Imgur.h"
#import "ImgurURL.h"

#import "StatusMenuController.h"
#import "CapturedAppDelegate.h"
#import "Utilities.h"

@implementation StatusMenuController
@synthesize lastUploadedURL;
@synthesize lastUploadedDeleteURL;
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
    [GrowlApplicationBridge notifyWithTitle:@"Captured"
                                description:@"Uploading Screenshot"
                           notificationName:@"Upload Started"
                                   iconData:nil
                                   priority:0
                                   isSticky:NO
                               clickContext:[NSDate date]];
}
-(void) setStatusFailure {
	[self setStatusIcon: statusIconError];
    
    [GrowlApplicationBridge notifyWithTitle:@"Captured"
                                description:@"Failed to Upload Screenshot"
                           notificationName:@"Upload Failed"
                                   iconData:nil
                                   priority:0
                                   isSticky:NO
                               clickContext:[NSDate date]];
}
-(void) setStatusSuccess: (ImgurURL*)url {
	[self setStatusIcon: statusIconSuccess];
	self.lastUploadedURL = [NSString stringWithString:url.imageURL];;
	self.lastUploadedDeleteURL = [NSString stringWithString:url.imageDeleteURL];;

	[copyURLMenuItem setEnabled:YES];
	[Utilities copyToPasteboard:self.lastUploadedURL];
	[self performSelector: @selector(setStatusNormal) withObject: nil afterDelay: 5.0];
    
    [GrowlApplicationBridge notifyWithTitle:@"Captured"
                                description:@"Successfully Uploaded Screenshot and Copied the URL to the Clipboard"
                           notificationName:@"Upload Finished"
                                   iconData:nil
                                   priority:0
                                   isSticky:NO
                               clickContext:[NSDate date]];

    //NSSound *systemSound = [NSSound soundNamed:@"Pop"];
	//[systemSound play];
}

-(void) awakeFromNib
{
    
    
    NSBundle *myBundle = [NSBundle bundleForClass:[CapturedAppDelegate class]];
	NSString *growlPath = [[myBundle privateFrameworksPath] stringByAppendingPathComponent:@"Growl.framework"];
	NSBundle *growlBundle = [NSBundle bundleWithPath:growlPath];
    
	if (growlBundle && [growlBundle load]) {
		// Register ourselves as a Growl delegate
		[GrowlApplicationBridge setGrowlDelegate:self];
	}
	else {
		NSLog(@"ERROR: Could not load Growl.framework");
	}
    
//    [GrowlApplicationBridge
//      notifyWithTitle:@"title"
//      description:@"description"
//      notificationName:@"UploadFailed"
//      //iconData:(NSData *)iconData
//      //priority:0
//      //isSticky:false
//      //clickContext:(id)clickContext
//     ];        
        
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
	[Utilities copyToPasteboard:self.lastUploadedURL];
}


-(IBAction) openURLInBrowserAction:(id) sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:lastUploadedURL]];
}

-(IBAction) openDeleteURLInBrowserAction:(id) sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:lastUploadedDeleteURL]];
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
