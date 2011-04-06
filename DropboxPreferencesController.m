//
//  DropboxPreferences.m
//  Captured
//
//  Created by Christopher Sexton on 4/4/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import "DropboxPreferencesController.h"
#import "DropboxUploader.h"


@implementation DropboxPreferencesController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
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
    
    NSString *user = [dropboxUser stringValue];
    NSString *pass = [dropboxPassword stringValue];
    NSString *ret = [uploader linkAccount:user password:pass];
    
    if (ret != nil) {
        [errorLabel setStringValue:ret];
    }
    [self showApproprateView];
}
-(IBAction)unlinkAccounts:(id)sender {
    [box setContentView:loginView];
    [uploader unlinkAccount];
    
}


@end
