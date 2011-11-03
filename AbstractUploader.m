//
//  AbstractUploader.m
//  Captured
//
//  Created by Christopher Sexton on 3/25/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import "AbstractUploader.h"
#import "CapturedAppDelegate.h"


@implementation AbstractUploader

@synthesize filePath;
@synthesize uploadUrl;
@synthesize deleteUrl;

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
	[filePath release];
	[uploadUrl release];
	[deleteUrl release];
	
    [super dealloc];
}

- (void) uploadFile:(NSString*)filename 
{
    NSLog(@"uploadFile Not Implemented");
}

- (void) deleteImage:(NSString*)deleteImageURL
{
    NSLog(@"deleteImage Not Implemented");
}

- (void) uploadStarted 
{
	[AppDelegate statusProcessing];
}

- (void) uploadSuccess: (NSDictionary *) dict
{
    [AppDelegate uploadSuccess: self with:dict];

    // Auto selfdestruct, this could cause some weirdness since this class kills itself after an upload
    // The alternative would be to have the app track it in an array and when the upload is complete call
    // back to the app and have it remove this from that array
    [self release];
}
- (void) uploadFailed: (NSDictionary *) dict
{
    [AppDelegate uploadFailure: self with: dict];

    // Auto selfdestruct, this could cause some weirdness since this class kills itself after an upload
    // The alternative would be to have the app track it in an array and when the upload is complete call
    // back to the app and have it remove this from that array
    [self release];
}
- (NSString*)testConnection
{
    NSLog(@"testConnection Not Implemented");
    return @"Not Implemented";
}

@end
