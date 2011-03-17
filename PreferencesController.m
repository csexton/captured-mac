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
    [uploaderBox addSubview:sftpPreferences];
}

-(IBAction) selectUploader:(id) sender
{
    NSComboBox *combo = (NSComboBox*)sender;
    NSString* type = [combo stringValue];
    NSView *currentView = [[uploaderBox subviews] objectAtIndex:0];

    [uploaderBox setTitle:  [NSString stringWithFormat: @"%@ Settings", type]];

    //Deletes all subviews
    //[uploaderBox setSubviews:[NSArray array]];

    if ([type isEqualToString: @"Imgur"]) {
        NSLog(@"Using type imgur");
    }
    if ([type isEqualToString: @"SFTP"]) {
        [uploaderBox replaceSubview:currentView with:sftpPreferences];
    }
    if ([type isEqualToString: @"Amazon S3"]) {
        //Y U NO CHANGE THE VIEW?
        [uploaderBox replaceSubview:currentView with:s3Preferences];
    }





}


@end
