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
#import "DDHotKeyCenter.h"


#define AppDelegate (CapturedAppDelegate *)[[NSApplication sharedApplication] delegate]

@interface CapturedAppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet BOOL *startAtLogin;
	EventsController *eventsController;
	StatusMenuController *statusMenuController;
    WelcomeWindowController *welcomeWindowController;
	BOOL uploadsEnabled;
    NSWindow *window;
    DDHotKeyCenter *hotKeyCenter;

}

@property BOOL startAtLogin;
//@property (retain) IBOutlet NSWindow *window;

@property (assign) IBOutlet StatusMenuController *statusMenuController;
@property (assign) IBOutlet WelcomeWindowController *welcomeWindowController;
@property (assign) IBOutlet NSWindow *window;

@property BOOL uploadsEnabled;

- (void)uploadSuccess: (NSDictionary *) url;
- (void)uploadFailure;
- (void)statusProcessing;
- (void)initEventsController;
- (void)processFileEvent: (NSString *)path;
- (IBAction)takeScreenCaptureAction:(id) sender;
- (IBAction)takeAnnotatedScreenCaptureAction:(id) sender;
- (IBAction)takeScreenCaptureWindowAction:(id) sender;
- (IBAction)showPreferencesWindow:(id) sender;

- (BOOL)isFirstRun;
- (void)showWelcomeWindow;
- (void)showAnnotateImageWindow;
- (void)showAnnotateImageWindowWithFile: (NSString*) file;

- (void) hotkeyWithEvent:(NSEvent *)hkEvent;
- (void) registerGlobalHotKey;
- (DDHotKeyCenter*) getHotKeyCenter;



@end