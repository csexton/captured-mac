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
#import "AbstractUploader.h"


#define AppDelegate (CapturedAppDelegate *)[[NSApplication sharedApplication] delegate]

@interface CapturedAppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet BOOL *startAtLogin;
	EventsController *eventsController;
	StatusMenuController *statusMenuController;
    WelcomeWindowController *welcomeWindowController;
	BOOL uploadsEnabled;
    NSWindow *window;
    DDHotKeyCenter *hotKeyCenter;
    NSMutableArray *annotatedWindows;

}

@property BOOL startAtLogin;
//@property (retain) IBOutlet NSWindow *window;

@property (assign) IBOutlet StatusMenuController *statusMenuController;
@property (assign) IBOutlet WelcomeWindowController *welcomeWindowController;
@property (assign) IBOutlet NSWindow *window;

@property BOOL uploadsEnabled;

- (void)uploadSuccess: (AbstractUploader*) uploader with:(NSDictionary *) details;
- (void)uploadFailure: (AbstractUploader*) uploader with:(NSDictionary *) details;
- (void)statusProcessing;
- (void)initEventsController;
- (void)processFileEvent: (NSString *)path;
- (IBAction)takeScreenCaptureAction:(id) sender;
- (IBAction)takeAnnotatedScreenCaptureAction:(id) sender;
- (IBAction)takeScreenCaptureWindowAction:(id) sender;
- (IBAction)showPreferencesWindow:(id) sender;
- (IBAction)toggleStatusMenuItem:(id)sender;

- (BOOL)isFirstRun;
- (void)showWelcomeWindow;
- (void)showAnnotateImageWindow;
- (void)showAnnotateImageWindowWithFile: (NSString*) file;
- (void)removeAnnotatedWindow: (id) controller;

- (void) primaryHotkeyWithEvent:(NSEvent *)hkEvent;
- (void) annotateHotkeyWithEvent:(NSEvent *)hkEvent;
- (void) registerGlobalHotKeys;
- (BOOL) registerPrimaryHotKeyWithKeyCode:(unsigned short)keyCode modifierFlags:(NSUInteger)flags;
- (BOOL) registerAnnotateHotKeyWithKeyCode:(unsigned short)keyCode modifierFlags:(NSUInteger)flags;
- (DDHotKeyCenter*) getHotKeyCenter;



@end