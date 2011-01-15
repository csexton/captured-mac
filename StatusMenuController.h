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
    NSStatusItem * statusItem;
    NSImage * statusIcon;
    NSImage * statusIconColor;
	NSImage * statusIconSuccess;
    NSImage * statusIconDisabled;
    NSImage * statusIconError;

}

-(void) setStatusProcessing;
-(void) setStatusSuccess;
-(void) setStatusFailure;
-(void) setStatusNormal;
-(void) setStatusIcon: (NSImage*)icon;



@end
