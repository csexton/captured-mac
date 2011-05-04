//
//  ImgurPreferencesController.m
//  Captured
//
//  Created by Christopher Sexton on 4/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImgurPreferencesController.h"


@implementation ImgurPreferencesController

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
    uploader = [[ImgurUploader alloc] init];
    
    [box setHidden:YES]; // TODO: put this back when we get OAuth and Imgur
    [self showApproprateView];
}

-(void)showApproprateView{
    if (YES){//([uploader isAccountLinked]) {
        //NSString* name = [[NSUserDefaults standardUserDefaults] stringForKey:@"ImgurDisplayName"];
        //[displayName setStringValue:[NSString stringWithFormat:@"This computer is linked to %@'s Imgur Account.",name]];
        [box setContentView:linkedView];
    } else {
        [box setContentView:loginView];
    }
}

-(IBAction)linkAccounts:(id)sender {
    
    NSString *user = [user stringValue];
    NSString *pass = [password stringValue];
    
    NSString *ret = [uploader linkAccount:user password:pass];
    
    if (ret != nil) {
        [errorLabel setStringValue:ret];
    }
    [self showApproprateView];
}
-(IBAction)unlinkAccounts:(id)sender {
    [password setStringValue:@""];
    [box setContentView:loginView];
    [uploader unlinkAccount];
    
}


@end
