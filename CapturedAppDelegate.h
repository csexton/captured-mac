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

+ (void)uploadSuccess: (NSString *)url;
- (void)setUploadSuccess: (NSString *) url;

//+ (void)uploadFailed: (NSString *)errorMsg;

+ (void)statusProcessing;
- (void)setStatusProcessing;

// May not need this since I have uploadSuccess/uploadFailure
//+ (void)statusNormal;
//- (void)setStatusNormal;

- (void)initEventsController;




@end