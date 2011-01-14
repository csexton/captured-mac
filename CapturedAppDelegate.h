//
//  Captured_AppDelegate.h
//  Captured
//
//  Created by Christopher Sexton on 1/13/11.
//  Copyright Codeography 2011 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EventsController.h"
#import "StatusMenuController.h"


@interface CapturedAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	EventsController *eventsController;
	StatusMenuController *statusMenuController;
}


@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet StatusMenuController *statusMenuController;


+ (void)statusProcessing;
+ (void)statusNormal;
- (void)setStatusProcessing;
- (void)setStatusNormal;
- (void)initEventsController;




@end