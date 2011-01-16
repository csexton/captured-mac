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
	BOOL uploadsEnabled;
}


@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet StatusMenuController *statusMenuController;
@property BOOL uploadsEnabled;


- (void)uploadSuccess: (NSString *) url;
- (void)uploadFailure;
- (void)statusProcessing;

- (void)initEventsController;

// May not need this since I have uploadSuccess/uploadFailure
//+ (void)statusNormal;
//- (void)setStatusNormal;




@end