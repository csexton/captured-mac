//
//  MainController.m
//  Captured
//
//  Created by Christopher Sexton on 1/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "ImgurController.h"

#import "MainController.h"


@implementation MainController

-(void) awakeFromNib
{
	NSLog(@"I am awake!");
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

	
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
	[statusItem setMenu:statusMenu];
	//[statusItem setTitle:@"Status"];
	[statusItem setImage:statusIcon];
	[statusItem setHighlightMode:YES];
	
	

}




@end
