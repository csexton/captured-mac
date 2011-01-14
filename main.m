//
//  main.m
//  Captured
//
//  Created by Christopher Sexton on 1/13/11.
//  Copyright Codeography 2011. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DirEvents.h"
#import "EventsController.h"

int main(int argc, char *argv[])
{
	// XXX 
	// If I set up the events here, I get memory leak warnings about the autorelease pool.
	// Perhaps I could manually control the memory
//	EventsController *eventsController = [[[EventsController alloc] init] autorelease];
//	[eventsController setupEventListener];
	
    return NSApplicationMain(argc,  (const char **) argv);
}
