//
//  DropboxUploader.m
//  Captured for Mac
//
//  Created by Jorge Velázquez on 3/16/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import "Utilities.h"
#import "JSON/JSON.h"
#import "DropboxUploader.h"
#import <DropboxOSX/DropboxOSX.h>

@implementation DropboxUploader

- (id)init
{
    self = [super init];
    if (self) {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    
    return self;
}

- (void)dealloc
{
	[restClient release];
	
    [super dealloc];
}

- (void)uploadFile:(NSString*)sourceFile
{
    [self setFilePath:sourceFile];
    
    // generate a unique filename
    NSString* tempNam = [Utilities createUniqueFilename:5];
    
    // if we're not linked, we can't do anything yet, log it and exit
    if (![[DBSession sharedSession] isLinked])
    {
        [self uploadFailed:nil];
        NSLog(@"Cannot upload to Dropbox, account is not linked");
        return;
    }
    
    // do the upload
    [restClient uploadFile:tempNam toPath:@"/Captured/" withParentRev:nil fromPath:sourceFile];
	[self uploadStarted];
}

- (void)linkAccount {
    // call the authenticator, which will link the account
    [[DBAuthHelperOSX sharedHelper] authenticate];
}

- (void)getAccountInfo {
    // create the session, must already be linked
    if (![[DBSession sharedSession] isLinked])
        return;
    
    // create the rest client so we can load the account info
    [restClient loadAccountInfo];
}

- (void)restClient:(DBRestClient*)client loadedAccountInfo:(DBAccountInfo*)info
{
    // store the display name from the account
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:[info displayName] forKey:@"DropboxDisplayName"];
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath from:(NSString*)srcPath metadata:(DBMetadata*)metadata
{
    [restClient loadSharableLinkForFile:destPath];
    //[restClient loadStreamableURLForFile:destPath]; //this is if we want to support direct links
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error
{
    [self uploadFailed:nil];
}

// the link generated from this call leads to a Dropbox-hosted page, with share options
- (void)restClient:(DBRestClient*)restClient loadedSharableLink:(NSString*)link forFile:(NSString*)path
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"DropboxProvider", @"Type",
                          link, @"ImageURL",
                          link, @"DeleteImageURL",
                          filePath, @"FilePath",
                          nil];
    [self uploadSuccess:dict];
}

// the link generated from this call points directly to the image
- (void)restClient:(DBRestClient*)restClient loadedStreamableURL:(NSURL*)url forFile:(NSString*)path;
{
    NSString* link = [url absoluteString];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"DropboxProvider", @"Type",
                          link, @"ImageURL",
                          path, @"DeleteImageURL",
                          filePath, @"FilePath",
                          nil];
    [self uploadSuccess:dict];
}

- (BOOL)isAccountLinked
{
    return [[DBSession sharedSession] isLinked];
}

- (void)unlinkAccount
{
    // must be linked in order to unlink
    if (![[DBSession sharedSession] isLinked])
        return;
    
    // unlink the account
    [[DBSession sharedSession] unlinkAll];
}

@end
