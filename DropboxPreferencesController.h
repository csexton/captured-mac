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
    IBOutlet NSView *linkedView;
    IBOutlet NSView *loginView;
    IBOutlet NSTextField *linkedAccountLabel;
    IBOutlet NSTextField *errorLabel;
    IBOutlet NSTextField *displayName;

    
    DropboxUploader *uploader;

}

-(void)showApproprateView;
-(IBAction)linkAccounts:(id)sender;
-(IBAction)unlinkAccounts:(id)sender;

@end
