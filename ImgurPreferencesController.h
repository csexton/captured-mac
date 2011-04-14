//
//  ImgurPreferencesController.h
//  Captured
//
//  Created by Christopher Sexton on 4/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ImgurUploader.h"


@interface ImgurPreferencesController : NSViewController {
@private
    
    IBOutlet NSBox *box;
    IBOutlet NSTextField *user;
    IBOutlet NSTextField *password;
    IBOutlet NSView *linkedView;
    IBOutlet NSView *loginView;
    IBOutlet NSTextField *linkedAccountLabel;
    IBOutlet NSTextField *errorLabel;
    IBOutlet NSTextField *displayName;
    
    
    ImgurUploader *uploader;
    
}


-(void)showApproprateView;
-(IBAction)linkAccounts:(id)sender;
-(IBAction)unlinkAccounts:(id)sender;

@end
