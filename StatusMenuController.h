//
//  MainController.h
//  Captured
//
//  Created by Christopher Sexton on 1/13/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>


@interface StatusMenuController : NSObject <GrowlApplicationBridgeDelegate> {
    IBOutlet NSMenu *statusMenu;
    IBOutlet BOOL *startAtLogin;
	
    NSStatusItem * statusItem;
	IBOutlet NSMenuItem *copyURLMenuItem;
	NSString *lastUploadedURL;
	NSString *lastUploadedDeleteURL;

    NSImage * statusIcon;
    NSImage * statusIconColor;
	NSImage * statusIconSuccess;
    NSImage * statusIconDisabled;
    NSImage * statusIconError;
    
    NSMenu * historyMenu;


}

@property BOOL startAtLogin;
@property (readwrite, retain) NSString *lastUploadedURL;
@property (readwrite, retain) NSString *lastUploadedDeleteURL;
@property (assign) IBOutlet NSMenuItem *copyURLMenuItem;
@property (assign) IBOutlet NSMenu *historyMenu;

-(BOOL) isURLAvaliable;

-(void) setStatusDisabled;
-(void) setStatusProcessing;
-(void) setStatusSuccess: (NSDictionary*)dict;
-(void) setStatusFailure;
-(void) setStatusNormal;
-(void) setStatusIcon: (NSImage*)icon;

-(IBAction) quitItemAction:(id) sender;
-(IBAction) copyURLItemAction:(id) sender;
-(IBAction) openURLInBrowserAction:(id) sender;
-(IBAction) openDeleteURLInBrowserAction:(id) sender;
-(IBAction) historyMenuItemAction: (id) sender;
-(void) createHistoryMenuItem: (NSDictionary *) dict;





@end
