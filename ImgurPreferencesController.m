//
//  ImgurPreferencesController.m
//  Captured
//
//  Created by Christopher Sexton on 4/13/11.
//  Copyright 2011 Codeography. All rights reserved.
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
    
//    [box setHidden:YES]; // TODO: put this back when we get OAuth and Imgur
    [self showApproprateView];
}

-(void)showApproprateView{
    if ([uploader isAccountLinked]) {
			[displayName setStringValue:[NSString stringWithFormat:@"This computer is linked to an Imgur Account."]];
        [box setContentView:linkedView];
    } else {
        [box setContentView:loginView];
    }
}

-(IBAction)linkAccounts:(id)sender {
    
    [uploader linkAccount:self withSelector:@selector(linkAccountsCallback:)];
    

    [box setContentView:verifyView];
}

-(void)linkAccountsCallback:(NSString*)status {
    if (status != nil) {
        [errorLabel setStringValue:status];
    } else {
        [box setContentView:verifyView];
    }

}

-(IBAction)verifyAccounts:(id)sender {
    
    NSString *vc = [verificationCode stringValue];
    
//    NSString *ret = [uploader authorizeAccount:vc];
//    
//    if (ret != nil) {
//        [verifyErrorLabel setStringValue:ret];
//    }
//    [self showApproprateView];
    // Until we get a delegete for the uploader to call back with, just trust it worked
    [uploader authorizeAccount:vc delegate:self withSelector:@selector(verifyAccountsCallback:)];
}
-(void)verifyAccountsCallback:(NSString*)status {
    
    if (status != nil) {
        [verifyErrorLabel setStringValue:status];
    } else {
        [box setContentView:linkedView];
    }
//    [self showApproprateView];
//    NSLog(@"Called back with %@", status);
//    [box setContentView:linkedView];
    
}
-(IBAction)unlinkAccounts:(id)sender {
    [box setContentView:loginView];
    [uploader unlinkAccount];
    
}


@end
