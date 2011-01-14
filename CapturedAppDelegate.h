//
//  Captured_AppDelegate.h
//  Captured
//
//  Created by Christopher Sexton on 1/13/11.
//  Copyright Codeography 2011 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EventsController.h"


@interface CapturedAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	EventsController *eventsController;
}


@property (assign) IBOutlet NSWindow *window;

- (void)initEventsController;


@end