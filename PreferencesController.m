//
//  PreferencesController.m
//  Captured
//
//  Created by Christopher Sexton on 3/16/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import "PreferencesController.h"


@implementation PreferencesController

@synthesize window;
@synthesize uploaderBox;
@synthesize sftpPreferences;
@synthesize s3Preferences;
@synthesize imgurPreferences;
@synthesize dropboxPreferences;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }

    return self;
}

- (void)dealloc
{
    [super dealloc];
}

-(void) awakeFromNib
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSString * type = [defaults stringForKey:@"UploadType"];

    [self selectUploaderViewWithType:type];
}


-(IBAction) selectUploader:(id) sender
{
    NSComboBox *combo = (NSComboBox*)sender;
    NSString* type = [combo stringValue];
    //NSView *currentView = [[uploaderBox subviews] objectAtIndex:0];

    //Deletes all subviews
    //[uploaderBox setSubviews:[NSArray array]];
    
    [self selectUploaderViewWithType: type];

}

-(void) selectUploaderViewWithType: (NSString *) type {
    
    [uploaderBox setTitle:  [NSString stringWithFormat: @"%@ Settings", type]];
    
    if ([type isEqualToString: @"Imgur"]) {
        [uploaderBox setContentView:imgurPreferences];
    }
    if ([type isEqualToString: @"SFTP"]) {
        [uploaderBox setContentView:sftpPreferences];
    }
    if ([type isEqualToString: @"Amazon S3"]) {
        [uploaderBox setContentView:s3Preferences];
        
    }
    if ([type isEqualToString: @"Amazon S3"]) {
        [uploaderBox setContentView:s3Preferences];
    }
    if ([type isEqualToString: @"Dropbox"]) {
        [uploaderBox setContentView:dropboxPreferences];
    }
}


@end
