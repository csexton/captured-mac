//
//  MainController.h
//  Captured
//
//  Created by Christopher Sexton on 1/13/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface StatusMenuController : NSObject {
    IBOutlet NSMenu *statusMenu;
    IBOutlet BOOL *startAtLogin;
	
    NSStatusItem * statusItem;
	IBOutlet NSMenuItem *copyURLMenuItem;
	ImgurURL *lastUploadedURL;

    NSImage * statusIcon;
    NSImage * statusIconColor;
	NSImage * statusIconSuccess;
    NSImage * statusIconDisabled;
    NSImage * statusIconError;


}

@property BOOL startAtLogin;
@property (readwrite, retain) ImgurURL *lastUploadedURL;
@property (assign) IBOutlet NSMenuItem *copyURLMenuItem;

-(BOOL) isURLAvaliable;

-(void) setStatusDisabled;
-(void) setStatusProcessing;
-(void) setStatusSuccess: (ImgurURL*)url;
-(void) setStatusFailure;
-(void) setStatusNormal;
-(void) setStatusIcon: (NSImage*)icon;

-(IBAction) quitItemAction:(id) sender;
-(IBAction) copyURLItemAction:(id) sender;
-(IBAction) openURLInBrowserAction:(id) sender;




@end
