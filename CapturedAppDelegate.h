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
#import "WelcomeWindowController.h"

@interface CapturedAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    IBOutlet BOOL *startAtLogin;
	EventsController *eventsController;
	StatusMenuController *statusMenuController;
    WelcomeWindowController *welcomeWindowController;
	BOOL uploadsEnabled;
}

@property BOOL startAtLogin;
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet StatusMenuController *statusMenuController;
@property (assign) IBOutlet WelcomeWindowController *welcomeWindowController;


@property BOOL uploadsEnabled;

- (void)uploadSuccess: (NSString *) url;
- (void)uploadFailure;
- (void)statusProcessing;
- (void)initEventsController;
- (IBAction)takeScreenCaptureAction:(id) sender;
- (IBAction)takeScreenCaptureWindowAction:(id) sender;


@end