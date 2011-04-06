//
//  DropboxPreferences.h
//  Captured
//
//  Created by Christopher Sexton on 4/4/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DropboxUploader.h"


@interface DropboxPreferencesController : NSViewController {
@private
    IBOutlet NSBox *box;
    IBOutlet NSTextField *dropboxUser;
    IBOutlet NSTextField *dropboxPassword;
    IBOutlet NSView *linkedView;
    IBOutlet NSView *loginView;
    IBOutlet NSTextField *linkedAccountLabel;
    
    DropboxUploader *uploader;

}

-(void)showApproprateView;
-(IBAction)linkAccounts:(id)sender;
-(IBAction)unlinkAccounts:(id)sender;

@end
