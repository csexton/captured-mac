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
#import "PreferencesController.h"

@interface CapturedAppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet BOOL *startAtLogin;
	EventsController *eventsController;
	StatusMenuController *statusMenuController;
    WelcomeWindowController *welcomeWindowController;
    PreferencesController *preferencesController;
	BOOL uploadsEnabled;
}

@property BOOL startAtLogin;
@property (assign) IBOutlet StatusMenuController *statusMenuController;
@property (assign) IBOutlet WelcomeWindowController *welcomeWindowController;
@property (retain) IBOutlet PreferencesController *preferencesController;


@property BOOL uploadsEnabled;

- (void)uploadSuccess: (ImgurURL *) url;
- (void)uploadFailure;
- (void)statusProcessing;
- (void)initEventsController;
- (IBAction)takeScreenCaptureAction:(id) sender;
- (IBAction)takeScreenCaptureWindowAction:(id) sender;
- (IBAction)showPreferencesWindow:(id) sender;

- (BOOL)isFirstRun;
- (void)showWelcomeWindow;

- (void) hotkeyWithEvent:(NSEvent *)hkEvent;
- (void) registerGlobalHotKey;



@end