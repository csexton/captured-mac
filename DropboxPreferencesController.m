//
//  DropboxPreferences.m
//  Captured
//
//  Created by Christopher Sexton on 4/4/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import "DropboxPreferencesController.h"
#import "DropboxUploader.h"
#import <DropboxOSX/DropboxOSX.h>

@implementation DropboxPreferencesController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authHelperStateChangedNotification:) name:DBAuthHelperOSXStateChangedNotification object:[DBAuthHelperOSX sharedHelper]];
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)authHelperStateChangedNotification:(NSNotification *)notification {
    if ([[DBSession sharedSession] isLinked]) {
        // You can now start using the API!
        [uploader getAccountInfo];
        [self showApproprateView];
    }
}

-(void)awakeFromNib {
    uploader = [[DropboxUploader alloc] init];
    
    [self showApproprateView];
    

}

-(void)showApproprateView{
    if ([uploader isAccountLinked]) {
        NSString* name = [[NSUserDefaults standardUserDefaults] stringForKey:@"DropboxDisplayName"];
        [displayName setStringValue:[NSString stringWithFormat:@"This computer is linked to %@'s Dropbox Account.",name]];
        [box setContentView:linkedView];
    } else {
        [box setContentView:loginView];
    }
}

-(IBAction)linkAccounts:(id)sender {
    [uploader linkAccount];
    
    [self showApproprateView];
}
-(IBAction)unlinkAccounts:(id)sender {
    [box setContentView:loginView];
    [uploader unlinkAccount];
    
}


@end
