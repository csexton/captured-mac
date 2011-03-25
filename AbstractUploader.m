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

- (void) uploadFile:(NSString*)filename 
{
    NSLog(@"uploadFile Not Implemented");
}
- (void) uploadStarted 
{
	[(CapturedAppDelegate *)[[NSApplication sharedApplication] delegate] statusProcessing];
}

- (void) uploadSuccess: (NSDictionary *) dict
{
    [(CapturedAppDelegate *)[[NSApplication sharedApplication] delegate] uploadSuccess:dict];
}
- (void) uploadFailed: (NSDictionary *) dict
{
    [(CapturedAppDelegate *)[[NSApplication sharedApplication] delegate] uploadFailure];
}
- (NSInteger)testConnection
{
    return 0;
}

@end
